# fuclaude-setup

## 权限设置
chmod +x download-fuclaude.sh
chmod +x run.sh

## 下载 FuClaude
./download-fuclaude.sh
./run.sh

## 停止 FuClaude
docker stop fuclaude-container
docker rm fuclaude-container
docker rmi fuclaude-app