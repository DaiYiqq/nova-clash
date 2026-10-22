# NovaClash

> 新一代跨平台代理客户端 · 以 [FlClash](https://github.com/chen08209/FlClash) 为模板打造 · 内置 15+ 项创新功能

NovaClash 是一个基于 **mihomo / Clash 内核** 的开源跨平台代理客户端，UI 架构与交互设计参考了 [FlClash](https://github.com/chen08209/FlClash)，并在此之上创新性地引入 AI 选路、节点健康评分、隐私护盾、分应用代理等多项实用功能。

> ⚠️ **请先阅读 [免责声明](./DISCLAIMER.md)**。本项目仅供学习交流与技术研究，请遵守当地法律法规。

---

## 📺 在线演示（Live Demo）

- **交互式 UI 预览**：直接打开 [docs/ui-preview/index.html](./docs/ui-preview/index.html)（浏览器本地即可查看，无需编译）。
- **在线地址（GitHub Pages）**：https://<你的用户名>.github.io/<你的仓库名>/

> 启用在线演示：仓库 Settings → Pages → Source 选择 **GitHub Actions**。已内置 [.github/workflows/pages.yml](./.github/workflows/pages.yml)，推送后自动把 `docs/ui-preview` 部署为在线 Demo。

---

## ✨ 特性亮点（15+ 项创新）

### 核心能力（对标 FlClash）

- 🚀 基于 mihomo 内核，支持 SS / SSR / VMess / VLESS / Trojan / Hysteria2 / TUIC / WireGuard 等主流协议
- 🌐 规则模式 / 全局模式 / 直连模式一键切换
- 📦 订阅管理：导入、更新、流量与到期信息展示
- 🎯 代理组管理：手动选择、自动测速、故障转移、负载均衡

### 创新功能（本项目独有）

| # | 功能 | 说明 |
|---|------|------|
| 1 | 🧠 **AI 智能选路** | 基于延迟/吞吐/稳定性历史 + 时段规律，自动推荐最优节点 |
| 2 | 💊 **节点健康评分** | 综合延迟、抖动、丢包率、可用性计算 0–100 健康度 |
| 3 | 📱 **分应用代理** | 指定不同 App 走不同代理组，精细化分流 |
| 4 | 🛡️ **隐私护盾** | WebRTC 泄漏防护、TLS 指纹随机化、加密 DNS |
| 5 | 🧭 **智能分流引擎** | GeoIP + 域名关键字 + 应用上下文联合路由 |
| 6 | 📊 **数据用量预测** | 预测月度流量消耗，超量提前告警 |
| 7 | 🩺 **一键网络体检** | DNS / 握手 / 延迟 / 泄漏四合一诊断向导 |
| 8 | 🔄 **订阅自动更新** | 定时拉取订阅 + 变更检测，异常告警 |
| 9 | ⛓️ **代理链（多级代理）** | 中继节点串联，构建多跳代理链路 |
| 10 | 📡 **局域网共享 + 设备白名单** | 一键共享代理给局域网，逐设备授权控制 |
| 11 | 🔋 **能耗优化模式** | 移动端省电策略，按需唤醒 |
| 12 | 🔐 **安全审计日志** | 链式哈希防篡改，完整记录配置/连接变更 |
| 13 | 🌙 **定时静默模式** | 设定时段自动切换代理开关 |
| 14 | 🔁 **自动故障转移** | 主节点失效时自动切换备用组 |
| 15 | 🧹 **DNS 抗污染** | EDNS 客户端子网 + 加密 DNS + 污染特征过滤 |

---

## 🎨 UI 设计

界面参考 FlClash 的 **Material 3** 设计语言：

- 紫罗兰主色 + 圆角卡片 + 深色优先的主题
- 首页大号连接开关 + 实时流量环形图
- 代理列表分组折叠 + 延迟/健康度徽标
- 底部导航：主页 / 代理 / 订阅 / 规则 / 设置

---

## 🧱 技术栈

- **UI**: Flutter (Dart) + Material 3 + Provider 状态管理
- **内核**: mihomo / Clash（外部控制器 REST API）
- **持久化**: 本地 JSON 配置 + 安全存储

## 📁 目录结构

```
NovaClash/
├── lib/
│   ├── main.dart              # 入口
│   ├── app.dart               # 根组件
│   ├── core/                  # 核心层（内核桥接、状态、配置、存储）
│   ├── models/                # 数据模型
│   ├── services/              # 创新功能服务层
│   ├── pages/                 # 页面
│   ├── widgets/               # 通用组件
│   └── theme/                 # 主题
├── assets/                    # 资源
├── docs/                      # 文档 + 在线演示（ui-preview）
├── .github/workflows/         # GitHub Pages 自动部署 Demo
├── DISCLAIMER.md              # 免责声明
├── CONTACT.md                 # 开发者联系方式
└── pubspec.yaml
```

---

## 🔧 构建与运行

### 前置要求

- Flutter SDK >= 3.3
- 自行准备 mihomo / Clash 内核二进制（不随仓库分发）

### 步骤

```bash
# 1. 安装依赖
flutter pub get

# 2. 放置内核二进制（可选，运行时也可手动指定）
#    Windows:  assets/core/nova_core.exe
#    Linux:    assets/core/nova_core
#    macOS:    assets/core/nova_core

# 3. 运行
flutter run
```

---

## 👨‍💻 开发者信息与联系方式

- **项目名称**：NovaClash
- **开发者**：NovaClash 开发团队
- **联系邮箱**：dev@novaclash.app
- **官方网站**：https://novaclash.app
- **开源仓库**：https://github.com/<你的用户名>/<你的仓库名>

详见 [CONTACT.md](./CONTACT.md)。UI 架构与交互设计参考 FlClash（作者 chen08209），内核基于 mihomo/Clash。

> ⚠️ 以上占位信息请替换为你的真实联系方式。

---

## 📜 致谢

- [FlClash](https://github.com/chen08209/FlClash) — 设计灵感与架构参考
- [mihomo / Clash.Meta](https://github.com/MetaCubeX/mihomo) — 代理内核
- 所有开源贡献者

## 📄 许可证

本项目独立实现部分采用 [MIT License](./LICENSE)。参考项目 FlClash 遵循 GPL-3.0，若分发包含其衍生代码的产物，请遵循相应开源协议。
