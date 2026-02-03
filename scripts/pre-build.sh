#!/bin/bash

# 构建前准备脚本
# 用于清理构建缓存、验证环境等

set -e

echo "🚀 Starting pre-build steps..."

# 清理旧的构建文件
echo "🧹 Cleaning build artifacts..."
flutter clean

# 获取依赖
echo "📦 Getting dependencies..."
flutter pub get

# 验证 Flutter 环境
echo "✅ Verifying Flutter environment..."
flutter doctor -v

# 运行代码检查
echo "🔍 Running code analysis..."
flutter analyze

# 运行测试
echo "🧪 Running tests..."
flutter test

echo "✅ Pre-build steps completed!"
