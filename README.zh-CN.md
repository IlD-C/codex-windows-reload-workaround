# Codex Windows 无限转圈临时解决方案

这是一个**非官方 workaround**，用于部分 Windows Codex Desktop 启动后持续转圈、但后台和登录实际上正常的情况。

## 原理

脚本会：

1. 通过 Windows 的 `IApplicationActivationManager` 启动 Microsoft Store/MSIX 版 `OpenAI.Codex`；
2. 仅在本机 `127.0.0.1:9222` 开启 Chromium DevTools 接口；
3. 找到主 renderer：`app://-/index.html`；
4. 通过 Chrome DevTools Protocol 执行一次 `Page.reload`。

它不会删除 `.codex`、历史会话、项目、登录数据或 Desktop profile。

## 使用

首次运行：

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\Install-Shortcuts.ps1
```

桌面会创建：

- `1 Start Codex (Debug)`
- `2 Fix Codex Spinner`

以后：

1. 先运行第一个快捷方式；
2. 等 Codex 窗口出现；
3. 如果一直转圈，再运行第二个快捷方式。

## 安全说明

调试接口只绑定：

```text
127.0.0.1:9222
```

不要改成 `0.0.0.0`。

这是临时 workaround，不是 OpenAI 官方修复。未来 Codex 更新后可能不再需要，也可能失效。
