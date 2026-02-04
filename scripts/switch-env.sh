#!/bin/bash

# 环境切换脚本
# 用法: ./scripts/switch-env.sh [dev|test|prod]
# 示例: ./scripts/switch-env.sh dev

set -e

ENV=${1:-"dev"}

case $ENV in
  dev|test|prod)
    echo "🔄 切换到 $ENV 环境..."
    
    # 创建环境标记文件
    echo "$ENV" > .current_env
    
    # 如果存在 .env 文件，更新它
    if [ -f ".env" ]; then
      if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s/APP_ENV=.*/APP_ENV=$ENV/" .env
      else
        sed -i "s/APP_ENV=.*/APP_ENV=$ENV/" .env
      fi
      echo "✅ 已更新 .env 文件"
    fi
    
    echo "✅ 环境已切换到: $ENV"
    echo ""
    echo "💡 运行应用:"
    echo "   flutter run --dart-define=APP_ENV=$ENV"
    echo ""
    echo "💡 构建应用:"
    echo "   flutter build apk --dart-define=APP_ENV=$ENV"
    ;;
  *)
    echo "❌ 无效的环境: $ENV"
    echo "可用环境: dev, test, prod"
    exit 1
    ;;
esac
