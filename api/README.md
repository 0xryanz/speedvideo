# SpeedVideo API

SpeedVideo 的后端服务：Go 1.26 模块化单体，提供观看侧 API 和采集控制面。
它不抓取外部站点，也不内置影视数据；片库由独立的 `collector` 进程写入。

- 观看接口：认证、个人资料、首页、目录、搜索、详情、片单、进度、播放/下载签名地址
- 控制面接口：采集源、任务、执行记录、采集条目（`/v1/admin/*`，需要管理令牌）
- 全库 schema 的唯一所有者：采集相关表也由本服务的迁移创建

## 技术栈

Go 1.26、chi v5、GORM 2、gormigrate、
PostgreSQL 16、Argon2id、JWT v5、Prometheus、slog、httprate、validator。

## 目录

```
cmd/api/                  进程入口，含容器 healthcheck 子命令
cmd/migrate/              只执行迁移的入口，适合生产一次性 Job
internal/app/             组合根：模块装配、路由、中间件
internal/modules/
  identity/               账号、登录、刷新令牌、个人资料
  catalog/                影片、分类、搜索、详情、可播来源
  library/                片单与观看进度
  playback/               播放会话与签名流地址
  download/               下载授权与签名文件地址
  home/                   Billboard 与首页货架
  source/                 采集源注册、授权确认、启用/停用、分类缓存
  collector/              采集任务队列的读写（入队、重试、查询）
  admin/                  运维控制面 HTTP 接口
internal/platform/        config / database / security / media / httpx / logger / apperr / model
internal/migrations/      gormigrate 版本化迁移
```

模块之间只通过窄接口依赖，HTTP 层只依赖 service，service 只依赖 repository 接口；
GORM 只出现在 repository 和 domain 中。

## 本地运行

```bash
# 在仓库根目录
make db          # 只启动 Postgres，宿主端口 5433
make migrate     # 应用迁移
make api         # API 监听 :8080
```

也可以直接在本目录运行：

```bash
DATABASE_URL='postgres://speedvideo:speedvideo-local-only@localhost:5433/speedvideo?sslmode=disable' \
  go run ./cmd/api
```

Docker Compose 会构建本目录并以 `api` 服务运行，宿主默认端口 `8091`：

```bash
docker compose up -d --build api
```

## 配置

配置来自环境变量，开发环境全部有默认值；生产模式启动时会做严格校验。

| 变量 | 说明 | 默认 |
|---|---|---|
| `APP_ENV` | `development` / `production` | `development` |
| `HTTP_ADDR` | 监听地址 | `:8080` |
| `DATABASE_URL` | PostgreSQL 连接串 | 本地 `speedvideo` 库 |
| `AUTO_MIGRATE` | 启动时自动迁移 | `true` |
| `JWT_SECRET` | 访问令牌签名密钥，至少 32 字符 | 开发默认值 |
| `JWT_ISSUER` | JWT issuer | `speedvideo-api` |
| `ACCESS_TOKEN_TTL` | 访问令牌有效期 | `15m` |
| `REFRESH_TOKEN_TTL` | 刷新令牌有效期 | `720h` |
| `MEDIA_SIGNING_KEY` | 媒体地址 HMAC 密钥，至少 32 字符 | 开发默认值 |
| `PLAYBACK_TOKEN_TTL` | 播放地址有效期 | `1h` |
| `DOWNLOAD_TOKEN_TTL` | 下载地址有效期 | `2h` |
| `PUBLIC_BASE_URL` | 对外地址，生产必须 HTTPS | `http://localhost:8080` |
| `CORS_ALLOWED_ORIGINS` | 允许的来源，逗号分隔 | `*` |
| `TRUST_PROXY_HEADERS` | 是否信任反向代理头 | `false` |
| `MAX_PROFILES` | 单账号资料上限 | `5` |
| `ALLOWED_MEDIA_HOSTS` | 额外允许的媒体域名 | 示例 CDN |
| `ADMIN_API_TOKEN` | 控制面令牌；为空时不挂载 `/v1/admin/*` | 空 |
| `SOURCE_ALLOW_INSECURE` | 仅开发：允许 http 源站 | `false` |
| `LOG_LEVEL` | 日志级别 | `info` |

另外支持 `HTTP_READ_TIMEOUT`、`HTTP_WRITE_TIMEOUT`、`HTTP_IDLE_TIMEOUT`、
`HTTP_SHUTDOWN_TIMEOUT`、`DB_MAX_OPEN_CONNS`、`DB_MAX_IDLE_CONNS`、
`DB_CONN_MAX_LIFETIME`。

生产校验会拒绝开发默认密钥、非 HTTPS 的 `PUBLIC_BASE_URL`、
`CORS_ALLOWED_ORIGINS=*` 以及 `SOURCE_ALLOW_INSECURE=true`。

## 接口

完整契约见 [`../docs/openapi.yaml`](../docs/openapi.yaml)。主要路由：

```
POST /v1/auth/register | login | refresh | logout
GET  /v1/me
GET/POST/PATCH/DELETE /v1/profiles...
POST /v1/profiles/{id}/select
GET  /v1/home
GET  /v1/titles?kind=&genre=&sort=&page=
GET  /v1/titles/{id} | /similar
GET  /v1/search?q=
GET/PUT/DELETE /v1/watchlist...
PUT  /v1/progress/{titleID}
GET  /v1/playback/{titleID}?episode_id=
GET  /v1/playback/stream/{signed-token}    # 302 → CDN
GET  /v1/downloads/{titleID}?episode_id=
GET  /v1/downloads/file/{signed-token}     # 302 → CDN
GET  /healthz /readyz /metrics
```

控制面（`ADMIN_API_TOKEN`，由控制台的反向代理注入）：

```
GET   /v1/admin/stats
GET   /v1/admin/adapters
GET/POST/PATCH/DELETE /v1/admin/sources...
POST  /v1/admin/sources/{id}/sync | /preview | /types/discover
GET   /v1/admin/sources/{id}/types
GET   /v1/admin/jobs | /jobs/{id}
POST  /v1/admin/jobs/{id}/retry
POST  /v1/admin/titles/{id}/refresh
GET   /v1/admin/runs | /items
```

游客可以直接访问浏览与播放接口；带有效令牌时会附带个人资料上下文，
用于个性化货架和续播位置。

## 认证与媒体安全

- Argon2id 密码哈希，登录失败执行等时校验，避免邮箱枚举。
- 访问令牌 15 分钟；刷新令牌只保存 SHA-256 哈希，每次刷新旋转，
  检测到复用即吊销整个 token family。
- 访问令牌按个人资料作用域，儿童资料在 JWT 中带 `kids=true`，
  仓储层强制内容分级白名单。
- 播放/下载地址使用 HMAC-SHA256 短时签名 + 域名白名单，
  `playback` 与 `download` 作用域不能互换。
- 统一错误契约、请求 ID、1 MiB 请求体限制、安全头和速率限制。

## 数据库

迁移位于 `internal/migrations/`，使用 gormigrate 的 Go 回调和 `AutoMigrate`。
`make migrate` 或 `go run ./cmd/migrate` 应用迁移；Compose 中 `AUTO_MIGRATE=true`
会在 API 启动时自动执行。采集任务、执行记录、采集条目等表也由这里创建。

## 测试

```bash
go vet ./...
go test -race ./...
go build ./...
```

测试覆盖密码哈希、JWT 过期/篡改、刷新令牌复用、媒体签名过期/篡改、
生产配置校验以及 catalog/library 业务规则。
