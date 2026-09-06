# Fork 变更说明

本仓库基于 [Android-DataBackup](https://github.com/XayahSuSuSu/Android-DataBackup) fork，主要同步 [backup_script (SpeedBackup)](https://github.com/YAWAsau/backup_script) 的核心备份代码实现，并增强自动构建能力。

## 变更概览

### 1. Dex 模块同步（核心备份代码）

将 `dex/` 模块从 Android-DataBackup 原版（v1.0）同步为 backup_script 的版本（v2.6.151）。

**新增核心类（25+）：**
- `AppStateEngine` / `AppStateLocalization` / `AppStateUtil` — AppState 元数据引擎
- `AppInventoryUtil` — 应用清单扫描
- `AppWakeBlockUtil` — 应用唤醒锁定
- `CgroupFreezeUtil` — cgroup 冻结管理
- `DaemonBootstrap` / `DaemonHardening` / `DaemonSupervisorUtil` / `SpeedBackupRootDaemon` — Root 守护进程体系
- `DeviceFactsUtil` / `DeviceModelDb` — 设备信息
- `GooglePackageSnapshot` — Google 包快照
- `HiddenApiBypassBridge` / `HiddenApiRuntimeProbe` — Hidden API 绕过
- `ProcessObserverUtil` — 进程观察
- `UidNetworkBlockUtil` — UID 网络阻断
- `WebDavUtil` / `SmbScanUtil` / `HttpCore` — 远程备份（WebDAV/SMB）
- `compat/` — 兼容性层（ActivityCompat, AppOpsCompat, PermissionCompat 等）

**构建配置变更：**
- 版本号：v1.0 → v2.6.151 (versionCode 2719)
- 新增 Kotlin 插件支持
- 依赖切换：`hiddenapibypass:6.1` 替代 `appcompat` + `httpclient5` + `slf4j`
- 启用 R8 代码压缩（release）

### 2. C 原生工具同步

新增 `C/` 目录，包含 backup_script 的 8 个 C 语言原生工具源码：

| 工具 | 用途 |
|------|------|
| `cgfreezer` | cgroup v2/v1 应用冻结与杀进程 |
| `eventwait` | 事件等待（inotify/property） |
| `filewatch` | 文件变化监控 |
| `netwatch` | 网络状态监控 |
| `procwait` | 进程稳定等待 |
| `speedscan` | 快速文件扫描 |
| `uidexec` | UID 隔离执行 |
| `unixsock` | Unix socket 通信 |

### 3. 备份脚本参考实现

新增 `script/` 目录，包含 backup_script 的核心 shell 脚本：
- `start.sh` — 入口 wrapper
- `backup_settings.conf` — 配置模板
- `tools/tools.sh` — 核心备份逻辑（~30000 行）
- `tools/dex_check.sh` — Dex 能力自检

### 4. GitHub Actions 自动构建

新增三个工作流：

| 工作流 | 触发 | 产物 |
|--------|------|------|
| `build-next.yaml` | `source-next/` 变更 / 手动 | APK (source-next v3.0.0) |
| `build-dex.yaml` | `dex/` 变更 / 手动 | classes.dex |
| `build-c-tools.yaml` | `C/` 变更 / 手动 | 4 ABI 原生工具 |

**build-next 构建环境：**
- JDK 21（AGP 9.2.1 要求）
- Rust stable + Android targets（rustic_core 依赖）
- NDK r25c + CMake 3.22.1
- 递归拉取子模块（tar, zstd-jni, rustic_core）

**保留原有工作流：**
- `build.yaml` — 构建 source/ 旧版 APK
- `bin.yaml` — 构建 zstd/busybox/tar 二进制
- `lint.yaml` — 代码检查
- `release-please.yml` — Release 管理

## 目录结构

```
Android-DataBackup-fork/
├── C/                          # [新增] C 原生工具源码（来自 backup_script）
├── dex/                        # [同步] Dex 模块 v2.6.151（来自 backup_script）
├── script/                     # [新增] 备份脚本参考实现（来自 backup_script）
│   ├── start.sh
│   ├── backup_settings.conf
│   └── tools/
│       ├── tools.sh
│       └── dex_check.sh
├── source/                     # 旧版 Android 应用（保留）
├── source-next/                # 新版 Android 应用 v3.0.0（保留）
├── build/                      # 原生二进制构建脚本
├── .github/workflows/          # CI/CD
│   ├── build-next.yaml         # [新增] source-next APK 构建
│   ├── build-dex.yaml          # [新增] Dex 构建
│   ├── build-c-tools.yaml      # [新增] C 工具构建
│   ├── build.yaml              # 原有 source/ 构建
│   ├── bin.yaml                # 原有二进制构建
│   ├── lint.yaml
│   └── release-please.yml
└── FORK_CHANGES.md             # 本文档
```

## 上游同步策略

- **dex/**：定期从 backup_script 同步，保持核心备份工具一致
- **C/**：定期从 backup_script 同步原生工具
- **script/**：作为参考实现，按需同步
- **source-next/**：跟随 Android-DataBackup 上游
