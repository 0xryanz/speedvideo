# SpeedVideo App

SpeedVideo 的 Flutter 客户端（iOS / Android / macOS / Windows / Web），Netflix 风格的深色界面，
中英双语。默认以访客身份直接浏览和播放，账号功能在操作时提示登录。

## 功能

- 首页 Billboard、Top 10、继续观看、分类货架
- 搜索：片名搜索、类型筛选（类型 chip）、最近搜索（按资料持久化）
- 影片详情：简介、分级、类型、相似影片、可播来源切换
- 剧集：季/集列表、自动下一集、续播进度
- 播放器：HLS 流、倍速、进度保存、本地离线文件优先
- 下载：签名授权、进度、取消、删除，按资料隔离
- 我的片单、个人资料切换、设置
- 访客可浏览和播放；片单、下载、进度需要登录
- 登录状态保存在 Keychain / Keystore，重启自动恢复

## 技术栈

Flutter 3.41 / Dart 3.11、Riverpod 2.6、go_router 17、Dio 5、
Freezed 3 + json_serializable、video_player（HLS + 本地文件；Windows 用
video_player_win）、cached_network_image、flutter_secure_storage、path_provider、
Material 3、ARB。

## 运行

```bash
flutter pub get
flutter gen-l10n
dart run build_runner build --delete-conflicting-outputs
flutter run --dart-define=API_BASE_URL=http://localhost:8080
```

各平台：

```bash
flutter run -d macos   --dart-define=API_BASE_URL=http://localhost:8080
flutter run -d windows --dart-define=API_BASE_URL=http://localhost:8080
flutter run -d ios     --dart-define=API_BASE_URL=http://localhost:8080
flutter run -d android --dart-define=API_BASE_URL=http://10.0.2.2:8080
flutter run -d chrome  --dart-define=API_BASE_URL=http://localhost:8080
```

Android 模拟器访问宿主机使用 `10.0.2.2`；生产构建必须使用 HTTPS。

## 目录

```
lib/app/             路由、主题、外壳
lib/core/            配置、Dio + 刷新拦截器、安全存储、通用组件
lib/features/
  auth/              账号 / 登录 / 个人资料
  home/              Billboard 与货架
  catalog/           影片、搜索、详情、类型
  library/           我的片单
  playback/          播放会话与播放器
  downloads/         下载授权、本地文件、离线播放
  settings/          设置
lib/l10n/            ARB 与生成代码
```

## 生成代码

```bash
flutter gen-l10n
dart run build_runner build --delete-conflicting-outputs
```

`*.freezed.dart`、`*.g.dart` 和本地化生成文件都会提交，保证 CI 和新克隆无需额外生成。

## 说明

- `video_player` 使用 HLS；签名 manifest 地址短时有效，每次播放重新获取。
- 下载通过 Dio 流式写盘，支持取消；播放时优先使用已完成的本地文件，
  没有本地文件才回退到在线流。
- Dio 拦截器做单飞刷新令牌轮换，401 后重试原请求，刷新失败统一登出。
- 令牌存 Keychain / Keystore。macOS 调试包在没有签名团队时降级到
  SharedPreferences（仅调试），因为 ad-hoc 签名应用无法访问钥匙串。
- 搜索页只有片名、类型 chip 和最近搜索，不再有「全部 / 电影 / 剧集」类型筛选。

## 测试

```bash
flutter analyze
flutter test
```

## 发布构建

仓库根目录推送 `vX.Y.Z` 标签会触发 `.github/workflows/release.yml`，
自动构建 Android / iOS / macOS / Windows 安装包并上传到 GitHub Release。
本地等价的 release 命令：

```bash
flutter build apk --release --build-name=1.0.0 --build-number=1
flutter build ios --release --no-codesign --build-name=1.0.0 --build-number=1
flutter build macos --release --build-name=1.0.0 --build-number=1
flutter build windows --release --build-name=1.0.0 --build-number=1
```

Android 正式签名读取 `android/key.properties`（不在版本库中）；
没有该文件时 release 构建退回 debug 签名。
