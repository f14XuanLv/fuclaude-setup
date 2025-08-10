#!/bin/bash

# FuClaude 自动构建和运行脚本
set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 打印函数
print_info() {
    echo -e "${GREEN}[信息]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[警告]${NC} $1"
}

print_error() {
    echo -e "${RED}[错误]${NC} $1"
}

# 配置变量
IMAGE_NAME="fuclaude"
IMAGE_TAG="latest"
CONTAINER_NAME="fuclaude-container"
HOST_PORT="8181"
CONTAINER_PORT="8181"

print_info "开始构建和运行 FuClaude..."

# 1. 检查必要文件
if [ ! -f "Dockerfile" ]; then
    print_error "未找到 Dockerfile"
    exit 1
fi

if [ ! -f "config.json" ]; then
    print_error "未找到 config.json"
    exit 1
fi

# 2. 检查是否存在下载的 fuclaude 目录
FUCLAUDE_DIR=$(find . -maxdepth 1 -type d -name "fuclaude-*" | head -1)

if [ -z "$FUCLAUDE_DIR" ]; then
    print_error "未找到 fuclaude 下载目录，请先运行 ./download-fuclaude.sh"
    exit 1
fi

print_info "找到 fuclaude 目录: $FUCLAUDE_DIR"

# 3. 检查 fuclaude 二进制文件是否存在
if [ ! -f "$FUCLAUDE_DIR/fuclaude" ]; then
    print_error "在 $FUCLAUDE_DIR 中未找到 fuclaude 二进制文件"
    exit 1
fi

# 4. 复制配置文件到 fuclaude 目录
print_info "复制 Dockerfile 和 config.json 到 $FUCLAUDE_DIR"
cp Dockerfile "$FUCLAUDE_DIR/"
cp config.json "$FUCLAUDE_DIR/"

# 5. 进入 fuclaude 目录
cd "$FUCLAUDE_DIR"

# 6. 停止并删除已存在的容器（如果存在）
if docker ps -a --format 'table {{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    print_warning "停止并删除已存在的容器: $CONTAINER_NAME"
    docker stop "$CONTAINER_NAME" >/dev/null 2>&1 || true
    docker rm "$CONTAINER_NAME" >/dev/null 2>&1 || true
fi

# 7. 构建 Docker 镜像
print_info "在 $FUCLAUDE_DIR 目录中构建 Docker 镜像: $IMAGE_NAME:$IMAGE_TAG"
docker build -t "$IMAGE_NAME:$IMAGE_TAG" .

# 8. 运行 Docker 容器
print_info "启动 Docker 容器: $CONTAINER_NAME"
docker run -d \
    --name "$CONTAINER_NAME" \
    -p "$HOST_PORT:$CONTAINER_PORT" \
    --restart unless-stopped \
    "$IMAGE_NAME:$IMAGE_TAG"

# 9. 等待容器启动
print_info "等待容器启动..."
sleep 3

# 10. 检查容器状态
if docker ps --format 'table {{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    print_info "✅ FuClaude 已成功启动！"
    print_info "📱 访问地址: http://localhost:$HOST_PORT"
    print_info "🐳 容器名称: $CONTAINER_NAME"
    print_info ""
    print_info "📋 有用的命令:"
    echo "  查看日志: docker logs $CONTAINER_NAME"
    echo "  停止服务: docker stop $CONTAINER_NAME"
    echo "  重启服务: docker restart $CONTAINER_NAME"
    echo "  删除容器: docker rm -f $CONTAINER_NAME"
else
    print_error "容器启动失败"
    print_info "查看错误日志: docker logs $CONTAINER_NAME"
    exit 1
fi

# 11. 显示容器日志的最后几行
print_info "容器启动日志:"
docker logs --tail 10 "$CONTAINER_NAME"