# 使用 Alpine 作为基础镜像
FROM alpine:latest

# 安装 ca-certificates，注意包管理器换成了 apk
RUN apk update && apk add --no-cache ca-certificates

# 创建工作目录
WORKDIR /app

# 复制文件
COPY fuclaude /app/
COPY config.json /app/

# 添加执行权限
RUN chmod +x /app/fuclaude

# 公开端口
EXPOSE 8181

# 启动命令
CMD ["./fuclaude"]