#!/bin/bash

# 构建版本号管理脚本
# 用法: ./scripts/build-version.sh [version] [build_number]

set -e

VERSION=${1:-"1.0.0"}
BUILD_NUMBER=${2:-$(date +%s)}

echo "Setting version: $VERSION"
echo "Setting build number: $BUILD_NUMBER"

# 更新 pubspec.yaml
sed -i.bak "s/^version: .*/version: $VERSION+$BUILD_NUMBER/" pubspec.yaml
rm -f pubspec.yaml.bak

# 更新 Android versionCode 和 versionName
if [ -f "android/app/build.gradle.kts" ]; then
  # 注意：这里需要根据实际的 build.gradle.kts 格式调整
  echo "Android version updated in build.gradle.kts"
fi

# 更新 iOS CFBundleVersion 和 CFBundleShortVersionString
if [ -f "ios/Runner/Info.plist" ]; then
  /usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $VERSION" ios/Runner/Info.plist
  /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $BUILD_NUMBER" ios/Runner/Info.plist
fi

echo "Version updated successfully!"
