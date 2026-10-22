# 构建与安装包（全平台）

NovaClash 是全平台 Flutter 应用。本文说明如何在本地构建各平台安装包，以及如何用 GitHub Actions 自动构建。

## 0. 前置要求

- Flutter SDK（stable 渠道，建议 3.24+）
- 首次构建前生成平台工程目录（仓库未内置，由 flutter create 生成）：

```bash
flutter create --platforms=android,ios,linux,macos,windows --org com.novaclash .
flutter pub get
dart run flutter_launcher_icons   # 生成各平台应用图标
```

> 注：`flutter create .` 不会覆盖已存在的 lib/、pubspec.yaml 与文档，只会补齐平台目录。

## 1. 各平台安装包

| 平台 | 安装包格式 | 构建命令 | 产物位置 |
|------|-----------|----------|----------|
| Windows | NSIS .exe / .zip | `flutter build windows --release` | build/windows/x64/runner/Release |
| macOS | .dmg | `flutter build macos --release` | build/macos/Build/Products/Release/*.app |
| Linux | .deb/.rpm/.AppImage/.tar.gz | `flutter build linux --release` | build/linux/x64/release/bundle |
| Android | .apk / .aab | `flutter build apk --release --split-per-abi` / `flutter build appbundle` | build/app/outputs/ |
| iOS | .ipa（需签名） | `flutter build ipa`（需 Apple 证书） | build/ios/ipa |

### 一键生成真实安装包（推荐：flutter_distributor）

```bash
# 已内置 distribute_options.yaml，直接在当前系统生成对应安装包
dart run flutter_distributor release --name v0.1.0
```

- Windows 产出 NSIS .exe 安装程序
- macOS 产出 .dmg
- Linux 产出 .deb / .rpm / .AppImage / .tar.gz
- Android 产出 .apk / .aab

### 手动打包脚本

仓库提供了打包脚本，产出到 dist/：

```bash
# Linux（含 deb + tar.gz + 收集 apk/aab）
bash scripts/package_linux.sh

# macOS（dmg + ios 未签名 zip）
bash scripts/package_macos.sh

# Windows（zip + NSIS 安装程序）
./scripts/package_windows.ps1
```

## 2. 用 GitHub Actions 自动构建（推荐）

推送 `v*` 标签或手动触发，即可自动构建全部平台安装包并发布为 Release：

```bash
git tag v0.1.0
git push origin v0.1.0
```

- **ubuntu-latest**：Linux（deb/tar.gz）+ Android（apk/aab）
- **windows-latest**：Windows（zip + NSIS .exe）
- **macos-latest**：macOS（dmg）+ iOS（未签名）

产物在仓库 **Actions → 对应 run → Artifacts**，标签触发时会自动创建 **GitHub Release** 并附上安装包。

## 3. 注意事项

- **iOS 签名**：真正可安装的 .ipa 需要 Apple 开发者证书；CI 只能产出未签名版本，需在 macOS + Xcode 上配置签名后重打包。
- **应用标识**：Android applicationId / iOS bundle id 由 `--org com.novaclash` 决定（默认 com.novaclash.nova_clash），可用 flutter_distributor 的 PACKAGE_NAME 覆盖为 com.novaclash.app。
- **核心内核**：mihomo 内核二进制不随仓库分发，运行时需放置到应用支持目录（见 README）。
- **显示名/图标**：应用显示名 NovaClash 与图标由 flutter_distributor / flutter_launcher_icons 配置控制，图标源文件为 assets/icon/icon.png。

## 4. 开发者信息与免责声明

- 开发者：DaiYi（GitHub @DaiYiqq）· 邮箱 1703205607@qq.com
- 使用前请阅读 [DISCLAIMER.md](../DISCLAIMER.md)。
