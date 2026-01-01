# VirtualHere USB Server Docker 容器

一个用于运行 VirtualHere USB Server 的 Docker 容器，包含预下载的二进制文件，支持多种架构并配有专用的 Dockerfile。

## 功能特点

- 🚀 **预下载的二进制文件** - 构建时下载特定架构的二进制文件
- 🏗️ **多架构支持** - 分别为 AMD64、ARM64、ARM 提供独立的 Dockerfile
- 🔄 **自动化构建** - GitHub Actions CI/CD 流水线
- 📦 **多仓库发布** - 支持 Docker Hub 和 GitHub Container Registry
- 🔒 **安全扫描** - 使用 Trivy 进行自动化漏洞扫描
- 📊 **健康检查** - 内置容器健康监控
- 🏷️ **简单标签策略** - 仅使用 `latest` 和 `release` 标签

## 快速开始

### 多架构镜像

根据您的系统选择适当的镜像：

```docker-compose
services:
  virtualhere:
    image: virtualhere-server:latest
    container_name: virtualhere
    volumes:
      - /dev/bus/usb:/dev/bus/usb
      - ./data:/data
    devices:
      - /dev:/dev
    restart: unless-stopped
    network_mode: "host"
```

### Docker Hub 和 GitHub Container Registry

| 标签 | 描述 | 支持的架构 |
|-----|-------------|---------------|
| `latest` | 主分支的最新构建 | 多架构 (amd64, arm64, arm) |
| `latest-amd64` | 最新的 AMD64 构建 | amd64 |
| `latest-arm64` | 最新的 ARM64 构建 | arm64 |
| `latest-arm` | 最新的 ARM 构建 | arm/v7 |
| `release` | 最新的发布版本 | 多架构 (amd64, arm64, arm) |
| `release-amd64` | 发布的 AMD64 版本 | amd64 |
| `release-arm64` | 发布的 ARM64 版本 | arm64 |
| `release-arm` | 发布的 ARM 版本 | arm/v7 |
| `v1.2.3` | 特定版本 | 多架构 (amd64, arm64, arm) |

### 仓库地址

- **Docker Hub**: `jsntwdj/virtualhere-server:latest`

## 架构检测

系统会根据您的架构自动选择适当的镜像：

- **x86_64** → `latest-amd64`（Intel/AMD 64位）
- **aarch64** → `latest-arm64`（ARM 64位）
- **armv7l** → `latest-arm`（ARM 32位）

## 项目结构

```
├── config.ini                # 配置文件
├── Dockerfile.amd64          # AMD64 特定构建文件
├── Dockerfile.arm64          # ARM64 特定构建文件
├── Dockerfile.arm            # ARM 特定构建文件
├── start-virtualhere.sh      # 启动脚本（共享）
├── docker-compose.yml        # Docker Compose 配置
├── .github/
│   └── workflows/
│       └── build.yml         # CI/CD 流水线
├── README.md
├── vhusbdarm                 # AMD64 4.8.5版本
├── vhusbdarm64               # ARM64 4.8.5版本
└── vhusbdx86_64              # ARM   4.8.5版本


```

## 从源码构建

### 前提条件

- 支持 BuildKit 的 Docker
- Git

### 构建命令

```bash
# 克隆仓库
git clone https://github.com/jsntwdj/virtualhere-docker.git
cd virtualhere-docker

# 构建特定架构镜像
docker build -f Dockerfile.amd64 -t virtualhere-server:amd64 .
docker build -f Dockerfile.arm64 -t virtualhere-server:arm64 .
docker build -f Dockerfile.arm -t virtualhere-server:arm .

# 为当前架构构建（自动检测）
ARCH=$(uname -m)
case "$ARCH" in
  x86_64) docker build -f Dockerfile.amd64 -t virtualhere-server . ;;
  aarch64) docker build -f Dockerfile.arm64 -t virtualhere-server . ;;
  armv7l) docker build -f Dockerfile.arm -t virtualhere-server . ;;
esac
```

## GitHub Actions 设置

要启用自动化构建，请在 GitHub 仓库中配置以下密钥：

| 密钥 | 描述 |
|--------|-------------|
| `DOCKERHUB_USERNAME` | 您的 Docker Hub 用户名 |
| `DOCKERHUB_TOKEN` | Docker Hub 访问令牌 |

工作流会自动：
- 在推送到主分支时构建多架构镜像
- 在 git 标签创建时发布版本
- 每周构建以获取最新的 VirtualHere 二进制文件
- 使用 Trivy 进行安全扫描

## 故障排除

### 容器无法启动

1. 检查容器是否有 USB 访问权限：
   ```bash
   docker exec virtualhere lsusb
   ```

2. 验证 USB 设备是否已挂载：
   ```bash
   ls -la /dev/bus/usb/
   ```

### 未检测到 USB 设备

1. 确保主机已连接 USB 设备
2. 检查容器是否以 `--privileged` 或适当的设备访问权限运行
3. 验证主机系统的 udev 规则

### 连接问题

1. 检查端口 7575 是否可访问：
   ```bash
   netstat -tuln | grep 7575
   ```

2. 验证主机的防火墙设置
3. 从 VirtualHere 客户端测试连接

### 日志和调试

```bash
# 查看容器日志
docker logs virtualhere

# 交互式 shell 访问
docker exec -it virtualhere /bin/bash

# 检查运行中的进程
docker exec virtualhere ps aux
```

## 贡献指南

1. Fork 本仓库
2. 创建功能分支：`git checkout -b feature-name`
3. 进行修改并测试
4. 提交拉取请求

## 许可证

本项目基于 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件。

## 致谢

- [VirtualHere](https://virtualhere.com/) 提供优秀的 USB 共享软件
- Docker 社区提供的最佳实践和工具

## 支持

- 📖 [VirtualHere 文档](https://virtualhere.com/usb_server_software)
- 🐛 [报告问题](https://github.com/jsntwdj/virtualhere-docker/issues)
- 💬 [讨论区](https://github.com/jsntwdj/virtualhere-docker/discussions)