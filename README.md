# OpenClaw Dashboard App

> OpenClaw Gateway 的原生 macOS 桌面管理界面

一个用 SwiftUI + Electron 构建的原生 macOS 桌面应用，为 [OpenClaw](https://github.com/openclaw/openclaw) Gateway 提供可视化管理界面。

---

## 功能 | Features

### 多渠道消息 | Multi-Channel Messaging
- 支持 Feishu、Telegram、Discord 等渠道的消息收发
- 渠道状态实时监控

### 会话管理 | Session Management  
- 查看所有活跃/历史会话
- 实时消息流查看

### 技能视图 | Skills View
- 查看所有已安装的 Agent Skills
- Skills 启用/禁用状态

### 系统概览 | Overview
- Gateway 运行状态
- Cron 任务统计
- Session 数量

### 设置 | Settings
- 模型选择（MiniMax / GPT / Claude）
- 渠道配置
- Dark Mode

---

## 技术栈 | Tech Stack

| 层级 | 技术 |
|------|------|
| 桌面壳 | Electron 41 |
| 前端界面 | SwiftUI (macOS) |
| 状态获取 | OpenClaw Gateway API |
| 构建工具 | Xcode + electron-packager |

---

## 构建 | Build

### macOS App（SwiftUI）
```bash
cd OpenClawDashboardApp
xcodebuild -project OpenClawDashboard.xcodeproj \
  -scheme OpenClawDashboard \
  -configuration Debug build
```

### Electron 桌面客户端
```bash
npm install
npm run package
# 输出: dist/OpenClawDashboard.app
```

### 运行（开发模式）
```bash
npm start
```

---

## 项目结构 | Project Structure

```
OpenClawDashboardApp/
├── main.js                    # Electron 入口
├── package.json                # Electron 依赖
├── OpenClawDashboard/         # SwiftUI macOS App
│   ├── OpenClawDashboardApp.swift
│   ├── ContentView.swift       # 主布局
│   ├── Views/                 # 页面视图
│   │   ├── OverviewView.swift
│   │   ├── ChannelsView.swift
│   │   ├── SessionsView.swift
│   │   ├── SkillsView.swift
│   │   └── SettingsView.swift
│   ├── Models/               # 数据模型
│   └── Services/              # Gateway API 服务
```

---

## 认证 | Authentication

App 启动时自动从 `~/.openclaw/openclaw.json` 读取 Gateway token，并注入到 Dashboard URL：
```
http://127.0.0.1:18789/#token=<token>
```

---

## License

MIT
