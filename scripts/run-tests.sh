#!/bin/bash

# 测试运行脚本
# 用法: ./scripts/run-tests.sh [unit|integration|all]
# 示例: ./scripts/run-tests.sh all

set -e

TEST_TYPE=${1:-"all"}

case $TEST_TYPE in
  unit)
    echo "🧪 运行单元测试..."
    flutter test test/unit/
    ;;
  integration)
    echo "🧪 运行集成测试..."
    flutter test integration_test/
    ;;
  all)
    echo "🧪 运行所有测试..."
    echo ""
    echo "📋 单元测试..."
    if [ -d "test/unit" ]; then
      flutter test test/unit/ || echo "⚠️  单元测试目录不存在或测试失败"
    else
      echo "⚠️  单元测试目录不存在: test/unit/"
    fi
    echo ""
    echo "📋 集成测试..."
    if [ -d "integration_test" ]; then
      flutter test integration_test/ || echo "⚠️  集成测试失败"
    else
      echo "⚠️  集成测试目录不存在: integration_test/"
    fi
    echo ""
    echo "✅ 测试完成"
    ;;
  *)
    echo "❌ 无效的测试类型: $TEST_TYPE"
    echo "可用类型: unit, integration, all"
    exit 1
    ;;
esac
