#!/bin/bash

set -e

# 检测系统
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

case $OS in
    linux*) OS="linux" ;;
    darwin*) OS="darwin" ;;
    *) echo "不支持的系统: $OS"; exit 1 ;;
esac

case $ARCH in
    x86_64) ARCH="amd64" ;;
    aarch64|arm64) ARCH="arm64" ;;
    *) echo "不支持的架构: $ARCH"; exit 1 ;;
esac

PLATFORM="$OS-$ARCH"

# 获取下载链接
RESPONSE=$(curl -fsSL https://api.github.com/repos/wozulong/fuclaude/releases/latest)
DOWNLOAD_URL=$(echo "$RESPONSE" | sed -n 's/.*"browser_download_url": "\([^"]*\)".*/\1/p' | grep "$PLATFORM")
FILENAME=$(basename "$DOWNLOAD_URL")

# 下载
curl -fsSL "$DOWNLOAD_URL" -o "$FILENAME"

# 解压
unzip -q -P "linux.do" "$FILENAME"

# 删除压缩包
rm -f "$FILENAME"