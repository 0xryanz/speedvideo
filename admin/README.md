# SpeedVideo Admin

采集控制台前端。React 19 + TypeScript + Vite，数据层 TanStack Query，
表单 react-hook-form + zod，样式 Tailwind CSS 4，测试 Vitest。

## 功能

- **总览**：来源、队列、片库、条目统计，最近任务与执行记录
- **采集源**：注册（含授权确认）、编辑、启用/停用、全量/增量同步、预检、删除
- **采集类型**：读取片库分类并勾选采集范围，显示每个分类的数量与估算页数
- **任务**：按来源/状态/类型筛选，失败任务重试，查看错误
- **执行记录**：抓取/新增/更新/跳过/失败统计与耗时
- **采集条目**：搜索、来源筛选、在架/下架筛选，单条重新采集

## 开发

```bash
npm ci
API_UPSTREAM=http://localhost:8080 ADMIN_API_TOKEN=dev-admin-token npm run dev
# http://localhost:5173
```

`vite.config.ts` 把 `/api/*` 代理到 `${API_UPSTREAM}/v1/admin/*`，
并在代理层注入 `Authorization`。这两个变量**不要**加 `VITE_` 前缀，
否则会被打进浏览器包。

## 生产

```bash
docker compose up -d --build admin
# http://localhost:8096
```

镜像里是 nginx：托管 `dist/`，用 `envsubst` 把 `${ADMIN_API_TOKEN}`
注入到 `/api/` 的反向代理请求头。浏览器只看到同源的 `/api/*`，
永远拿不到管理令牌。

| 变量              | 说明                        | 默认              |
| ----------------- | --------------------------- | ----------------- |
| `API_UPSTREAM`    | 反向代理目标                | `http://api:8080` |
| `ADMIN_API_TOKEN` | 控制面令牌，必须与 API 一致 | 无                |

控制台自身没有登录页，必须放在内网或额外的访问控制之后，不要直接暴露公网。

## 命令

```bash
npm run dev          # 开发服务器 + 代理
npm run build        # tsc -b + vite build
npm run preview      # 预览构建产物
npm run lint         # ESLint（flat config）
npm run test         # Vitest
npm run test:watch   # Vitest watch
npm run format       # Prettier
npm run format:check # 校验格式
```

## 目录

```
src/api/         fetch 客户端、wire 类型、TanStack Query hooks
src/components/  按钮、表格、弹窗、Toast 等基础组件
src/layout/      侧边栏外壳
src/lib/         格式化与文案映射
src/pages/       总览 / 采集源 / 任务 / 执行记录 / 采集条目
nginx/           生产静态托管与令牌注入模板
```

## 预检流程

「预检」不是同步请求：控制台把一次只读抓取入队（`kind=preview`），
collector 抓取后把快照写进任务的 `result`，控制台轮询任务直到完成。
这样 API 进程永远不访问外部站点。
