#!/bin/bash
# 脚本头部声明使用bash解释器
# 这是VirtualHere单架构二进制文件的启动脚本

set -e
# 设置脚本选项：遇到任何命令执行失败（非零退出状态）立即退出脚本
# 防止错误累积，增强脚本健壮性

echo "*** 开始启动VirtualHere USB服务器..."
# 输出提示信息，表明开始启动VirtualHere USB服务器


# 为调试目的列出USB设备
echo "*** 当前USB设备:"
# 输出提示信息
if ! lsusb; then
    # 尝试执行lsusb命令列出USB设备，如果执行失败(!表示取反)
    echo "警告：无法列出 USB 设备。请确保容器具有正确的 USB 访问权限。"
    # 输出警告信息，提示可能由于容器USB访问权限问题无法列出设备
fi
# 结束if条件块


# 准备数据目录
mkdir -p /data
# 创建/data目录，-p参数确保如果目录已存在不会报错，父目录不存在则一并创建
cd /data
# 切换当前工作目录到/data


# 清理旧的临时文件
echo "*** 清理临时文件..."
# 输出清理临时文件的提示信息
find . -name '*bus_usb_*' -delete 2>/dev/null || true
# 在当前目录(.)查找名称匹配*bus_usb_*的文件并删除
# 2>/dev/null 将错误信息重定向到空设备（丢弃错误）
# || true 确保即使find命令失败，脚本也不会因set -e而退出（因为这是可选的清理操作）


# 检查VirtualHere二进制文件是否存在
if [ ! -f "/app/virtualhere" ]; then
    # 如果/app/virtualhere不是普通文件(! -f)
    echo "错误：在 /app/virtualhere 目录下未找到 VirtualHere 二进制文件"
    # 输出错误信息
    exit 1
    # 退出脚本，返回状态码1表示错误
fi
# 结束if条件块

# 创建符号链接到默认配置
ln -sf /data/config.ini /app/config.ini


# 显示二进制文件信息
echo "*** VirtualHere 二进制信息:"
# 输出提示信息
/app/virtualhere -h 2>&1 | head -3 || echo "无法获取版本信息"
# 执行/app/virtualhere -h获取帮助信息
# 2>&1 将标准错误重定向到标准输出（合并输出流）
# | head -3 只显示前3行输出
# || echo 如果前面命令失败，则输出无法获取版本信息的提示

# 启动VirtualHere服务器
echo "*** 启动 VirtualHere 服务器..."
# 输出启动提示
echo "工作目录: $(pwd)"
# 输出当前工作目录，$(pwd)执行pwd命令获取当前路径
echo "正在监听端口: 7575"
# 输出服务监听端口
echo "系统架构: $(uname -m)"
# 输出系统架构，$(uname -m)执行uname -m获取机器硬件名称


# 使用exec使VirtualHere成为主进程（PID 1）
exec /app/virtualhere
# 使用exec执行virtualhere程序，替换当前shell进程
# 这样virtualhere进程成为PID 1，可以正确处理信号并成为容器主进程
