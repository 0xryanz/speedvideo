# SpeedVideo Collector

独立的数据面进程：从已授权的片库拉取条目，归一化、校验、去重后写入 PostgreSQL。

控制面（登记来源、入队任务、查看结果）在 API 的 `/v1/admin/*` 中，控制台见 `../admin`。

## 工作方式

```
admin 控制台 ──▶ API（控制面）──▶ PostgreSQL ◀──领取任务── collector ──▶ 片库
```

- 启动后轮询 `collect_jobs`，支持并发消费（`COLLECTOR_CONCURRENCY`）。
- 内置调度器按 `COLLECTOR_SYNC_INTERVAL` 为每个启用的来源入队增量任务。
- 全库 schema 由 API 的迁移创建；collector 只读写数据，不负责建表。
- 容器健康检查直接 ping 数据库，不依赖 HTTP。

## 任务类型

| 类型 | 行为 |
|---|---|
| `full` | 从头翻页抓完（受页数上限限制），结束后把未再出现的条目标记为下架 |
| `incremental` | 只抓最新几页；窗口内已抓过且未变化的条目跳过详情请求 |
| `title` | 单条重采集，用于修正某一部影片/剧集，不改变目录 id |
| `preview` | 只读抓取一页，把快照写入任务 `result`，不写目录 |
| `types` | 只读读取片库分类，缓存到来源，供控制台勾选采集范围 |

## 采集规则

- **变更才写库**：对「名称 + 年份 + 简介 + 海报 + 全部集地址」做 SHA-256，
  哈希一致直接跳过。
- **单条重采集不换 id**：片单、进度、下载记录全部保留。
- **下架即隐藏**：上游消失的条目写 `removed_at`，API 立刻过滤，但行保留以便恢复。
- **媒体域名自动学习**：播放域名写入该来源白名单，播放兑换时逐个校验。
- **多来源同一影片**：按「名称 + 年份 + 类型」生成 `work_key`，
  目录只展示一条 canonical，详情页列出全部可播来源；某个源停用或下架时
  canonical 自动移交给仍在线的条目。
- **分类范围**：父分类自动展开为子分类分别采集；分类数量由子级汇总。
  不勾选任何类型表示采集全部。
- **全量即范围**：带类型选择的全量扫描会把未选中的旧条目标记为下架，
  因此切换类型后跑一次「全量」即可让片库只保留目标类型。
  抓取结果为 0 时跳过了下架步骤，避免误清空。

## 目录

```
cmd/collector/            进程入口，含 healthcheck 子命令与 COLLECTOR_ONCE
internal/adapter/         片库协议适配器（apple_cms_v10）
internal/pipeline/        抓取 → 归一化 → 校验 → 去重 → 写入
internal/store/           队列领取、运行记录、目录写入
internal/worker/          并发消费任务
internal/scheduler/       定时入队增量任务
internal/model/           与 API 侧共享的表结构定义
internal/config/          环境变量
```

## 本地运行

```bash
# 在仓库根目录
make db
make migrate
make collector       # 持续运行
make collector-once  # 跑一轮后退出
```

也可以直接在本目录运行：

```bash
DATABASE_URL='postgres://speedvideo:speedvideo-local-only@localhost:5433/speedvideo?sslmode=disable' \
  go run ./cmd/collector
```

Docker Compose 会构建本目录并以 `collector` 服务运行，无宿主端口。

## 配置

| 变量 | 说明 | 默认 |
|---|---|---|
| `APP_ENV` | 运行环境 | `development` |
| `DATABASE_URL` | PostgreSQL 连接串 | 必填 |
| `LOG_LEVEL` | 日志级别 | `info` |
| `COLLECTOR_CONCURRENCY` | 并发任务数 | `2` |
| `COLLECTOR_POLL_INTERVAL` | 队列轮询间隔 | `10s` |
| `COLLECTOR_SYNC_INTERVAL` | 每个来源的自动增量周期 | `6h` |
| `COLLECTOR_MAX_PAGES` | 全量扫描页数上限（每个类型） | `50` |
| `COLLECTOR_INCREMENTAL_PAGES` | 增量扫描页数 | `3` |
| `COLLECTOR_UNCHANGED_WINDOW` | 窗口内已抓条目跳过详情 | `12h` |
| `COLLECTOR_ALLOW_INSECURE` | 仅开发：允许 http 源站 | `false` |
| `COLLECTOR_ONCE` | 跑完当前队列后退出 | `false` |

`COLLECTOR_MAX_PAGES=50`、AppleCMS 每页约 20 条，默认一轮约 1000 条。
需要更深的历史内容时调大页数，或在控制台的「采集类型」里按类型设置上限。

## 测试

```bash
go vet ./...
go test -race ./...
go build ./...
```

测试覆盖 AppleCMS 协议解析（多线路/分集/HTTPS 升级）和内容哈希变更检测。

## 边界

- 不内置片源列表，不提供订阅链接或采集站发现/分享机制。
- `apple_cms_v10` 只是协议实现；指向的必须是有权分发的内容。
- 采集内容默认分级 `18+`，避免未分级内容进入儿童资料。
