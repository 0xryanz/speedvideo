# SpeedVideo

流媒体系统：Flutter 客户端 + Go API + 独立采集器 + React 控制台 + PostgreSQL。

仓库不内置任何影视数据。新部署的片库是空的，由采集器从运营方有权使用的片库写入；
**上线前必须替换为已授权素材与自有 CDN/DRM**。

## 组成

| 目录 | 说明 | 文档 |
|---|---|---|
| [`app/`](app/README.md) | Flutter 客户端，iOS / Android / Android TV / macOS / Windows / Web，访客可浏览播放 | [客户端说明](app/README.md) |
| [`api/`](api/README.md) | Go 模块化单体，观看接口 + 采集控制面 + 数据库迁移 | [API 说明](api/README.md) |
| [`collector/`](collector/README.md) | 独立采集进程，无 HTTP，从数据库领取任务 | [采集器说明](collector/README.md) |
| [`admin/`](admin/README.md) | React 运营控制台，管理来源、任务与条目 | [控制台说明](admin/README.md) |
| [`docs/`](docs/openapi.yaml) | OpenAPI 3.1 契约 | [openapi.yaml](docs/openapi.yaml) |
| [`icon/`](icon/README.md) | 图标生成与多平台铺设工具 | [图标说明](icon/README.md) |

数据流：

```
Flutter app ──────────────▶ API ──────────────▶ PostgreSQL
admin 控制台 ──▶ API 控制面 ──▶ 采集任务队列 ──▶ collector ──▶ 片库
```

- API 不发起外部请求；采集慢或源站故障不影响观看。
- collector 不监听端口，只消费任务并写目录表。
- 数据库 schema 由 API 的迁移统一管理。

## 快速启动

```bash
cp .env.example .env        # 修改 JWT_SECRET / MEDIA_SIGNING_KEY
docker compose up --build
```

| 服务 | 地址 |
|---|---|
| API | <http://localhost:8091> |
| 管理控制台 | <http://localhost:8096> |
| PostgreSQL | `localhost:5433` |

启动时自动迁移。打开控制台登记采集源并触发同步，片库才会有内容；
账号通过客户端注册创建。控制台默认令牌 `dev-admin-token` 仅用于开发。

## 本地开发

```bash
make db          # 只启动 Postgres（宿主端口 5433）
make migrate     # 应用迁移
make api         # API: :8080
make collector   # 采集进程（无 HTTP 端口）
make admin       # 控制台开发服务器: http://localhost:5173
make app         # macOS 客户端，API 默认 http://localhost:8080
```

`make help` 查看全部目标，包括 `collector-once`、`test`、`lint`、`fmt`。

## 测试

```bash
make test    # Go（API + collector）+ admin Vitest + Flutter
make lint    # go vet + ESLint + flutter analyze
```

CI 还会在真实 Postgres 上执行迁移、跑 Go `-race`、构建 Web 与三个容器镜像。

## 发布

推送 `v` 开头的语义化版本标签会触发 [`.github/workflows/release.yml`](.github/workflows/release.yml)，
构建并上传四个平台的安装包到 GitHub Release：

```bash
git tag v1.0.0
git push origin v1.0.0
```

| 平台 | 产物 |
|---|---|
| Android | APK，配置签名 Secrets 时使用正式证书，否则退回 debug 签名 |
| iOS | 未签名 IPA，需要 AltStore / Sideloadly / Xcode 重签 |
| macOS | DMG + ZIP，未公证 |
| Windows | x64 ZIP，解压后运行 `speedvideo.exe` |

构建时的 API 地址取仓库变量 `API_BASE_URL`（默认 `https://api.speedvideo.example`）。
Android 正式签名在仓库 Secrets 中配置：

- `ANDROID_KEYSTORE_BASE64`：keystore 文件的 base64
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_ALIAS`
- `ANDROID_KEY_PASSWORD`

Apple 平台的商店签名与公证不在工作流内，正式分发前需自行接入证书与公证流程。

## 部署提醒

- 生产必须使用 HTTPS，并替换 `JWT_SECRET`、`MEDIA_SIGNING_KEY`、`ADMIN_API_TOKEN`。
- 控制台依赖反向代理注入管理令牌，自身没有登录页，必须放在内网或额外访问控制之后。
- 生产启动会拒绝默认密钥、`CORS_ALLOWED_ORIGINS=*` 和 `SOURCE_ALLOW_INSECURE=true`。
- 仍需补齐：DRM（Widevine / FairPlay）、真实 CDN 鉴权、邮箱验证与找回密码、
  风控与审计、分布式限流、Kubernetes / 云托管与密钥管理。

## License

代码可用于学习与二次开发。仓库不包含影视素材；采集入库内容与示例流版权归各自权利人所有，
不在代码许可范围内。正式发布前请确保所有内容均已获得分发授权。
