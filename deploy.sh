#!/bin/bash
# image-push Docker 部署脚本
# 使用方法: ./deploy.sh [--build] [--push] [--image-name IMAGE_NAME]
set -e
# 默认配置
IMAGE_NAME="${IMAGE_NAME:-image-push}"
TAG="${TAG:-latest}"
REGISTRY_ADDRESS="${REGISTRY_ADDRESS:-http://localhost:5000}"
REGISTRY_USERNAME="${REGISTRY_USERNAME:-admin}"
REGISTRY_PASSWORD="${REGISTRY_PASSWORD:-Harbor12345}"
REGISTRY_PROJECT="${REGISTRY_PROJECT:-library}"
IMAGE_FILE="${IMAGE_FILE:-./images/your-image.tar}"
# 解析参数
ACTION="build"
while [[ $# -gt 0 ]]; do
  case $1 in
    --build)
      ACTION="build"
      shift
      ;;
    --push)
      ACTION="push"
      shift
      ;;
    --run)
      ACTION="run"
      shift
      ;;
    --image-name)
      IMAGE_NAME="$2"
      shift 2
      ;;
    *)
      shift
      ;;
  esac
done
case $ACTION in
  build)
    echo "📦 构建 Docker 镜像..."
    docker build -t "${IMAGE_NAME}:${TAG}" .
    echo "✅ 构建完成: ${IMAGE_NAME}:${TAG}"
    ;;
  push)
    echo "📤 推送镜像到 Registry..."
    docker push "${IMAGE_NAME}:${TAG}"
    echo "✅ 推送完成"
    ;;
  run)
    echo "🚀 运行容器推送镜像..."
    if [ ! -f "$IMAGE_FILE" ]; then
      echo "❌ 镜像文件不存在: $IMAGE_FILE"
      exit 1
    fi
    docker run --rm \
      -v "$(dirname "$IMAGE_FILE"):/images:ro" \
      "${IMAGE_NAME}:${TAG}" \
      --address "${REGISTRY_ADDRESS}" \
      --username "${REGISTRY_USERNAME}" \
      --password "${REGISTRY_PASSWORD}" \
      --project "${REGISTRY_PROJECT}" \
      --file "/images/$(basename "$IMAGE_FILE")" \
      --skipTls
    echo "✅ 推送完成"
    ;;
esac