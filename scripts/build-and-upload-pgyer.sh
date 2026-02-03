#!/bin/bash

# 构建并上传 APK 到蒲公英开发者平台
# 用法: ./scripts/build-and-upload-pgyer.sh [环境] [更新说明]
# 示例: ./scripts/build-and-upload-pgyer.sh prod "修复了若干bug"

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 配置
ENV=${1:-"prod"}
UPDATE_DESC=${2:-"自动构建发布"}

# 蒲公英 API Key 配置
# 方式1: 从环境变量读取（推荐）
# 方式2: 直接在脚本中设置（不推荐，会暴露密钥）
# 方式3: 从配置文件读取
if [ -f ".pgyer_config" ]; then
    # 从配置文件读取（.pgyer_config 文件格式: PGYER_API_KEY=your_key）
    source .pgyer_config
fi

# 如果环境变量未设置，尝试使用脚本中的默认值
PGYER_API_KEY=${PGYER_API_KEY:-""}
PGYER_PASSWORD=${PGYER_PASSWORD:-""}  # 可选：安装密码

# 蒲公英 API 地址
PGYER_UPLOAD_URL="https://www.pgyer.com/apiv2/app/upload"

# 打印二维码到控制台
print_qr_code() {
    local url="$1"
    
    echo ""
    echo -e "${GREEN}📱 二维码（控制台）:${NC}"
    echo ""
    
    # 方法1: 使用 qrencode（如果已安装，最推荐）
    if command -v qrencode &> /dev/null; then
        # 尝试使用 ANSI 颜色输出（更美观）
        qrencode -t ANSIUTF8 "$url" 2>/dev/null && echo "" && return 0
        # 如果失败，使用 ASCII 输出
        qrencode -t ASCII "$url" 2>/dev/null && echo "" && return 0
    fi
    
    # 方法2: 使用 Python qrcode 库（如果可用）
    if command -v python3 &> /dev/null; then
        python3 -c "
import sys
try:
    import qrcode
    qr = qrcode.QRCode(
        version=1,
        error_correction=qrcode.constants.ERROR_CORRECT_L,
        box_size=2,
        border=1
    )
    qr.add_data('$url')
    qr.make(fit=True)
    qr.print_ascii(invert=True)
    sys.exit(0)
except ImportError:
    pass
except Exception:
    pass
" 2>/dev/null && echo "" && return 0
    fi
    
    # 方法3: 使用在线API生成ASCII二维码（需要网络）
    if command -v curl &> /dev/null; then
        # URL编码
        encoded_url=$(echo "$url" | sed 's/:/%3A/g; s/\//%2F/g; s/?/%3F/g; s/=/%3D/g; s/&/%26/g')
        # 尝试获取ASCII格式的二维码
        ascii_qr=$(curl -s --max-time 3 "https://api.qrserver.com/v1/create-qr-code/?size=10x10&format=txt&data=$encoded_url" 2>/dev/null)
        if [ $? -eq 0 ] && [ -n "$ascii_qr" ]; then
            echo "$ascii_qr" | head -15
            echo ""
            return 0
        fi
    fi
    
    # 如果所有方法都失败，提示用户安装工具
    echo -e "${YELLOW}💡 提示: 安装 qrencode 可在控制台显示二维码${NC}"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "   安装命令: brew install qrencode"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "   安装命令: sudo apt-get install qrencode 或 sudo yum install qrencode"
    fi
    echo "   或者安装 Python qrcode: pip3 install qrcode[pil]"
    echo ""
}

# 检查 API Key
if [ -z "$PGYER_API_KEY" ]; then
    echo -e "${RED}❌ 错误: 未设置 PGYER_API_KEY 环境变量${NC}"
    echo "请设置蒲公英 API Key:"
    echo "  export PGYER_API_KEY=your_api_key"
    echo "或在脚本中设置 PGYER_API_KEY 变量"
    exit 1
fi

echo -e "${GREEN}🚀 开始构建并上传 APK 到蒲公英...${NC}"
echo "环境: $ENV"
echo "更新说明: $UPDATE_DESC"

# 1. 清理并获取依赖
echo -e "${YELLOW}📦 获取依赖...${NC}"
flutter clean
flutter pub get

# 2. 构建 APK
echo -e "${YELLOW}🔨 构建 APK (环境: $ENV)...${NC}"
BUILD_MODE="release"
if [ "$ENV" = "dev" ]; then
    BUILD_MODE="debug"
fi

# 提取版本号
VERSION_NAME=$(grep '^version:' pubspec.yaml | sed 's/version: //' | sed 's/+.*//' || echo "1.0.0")
BUILD_NUMBER=$(grep '^version:' pubspec.yaml | sed 's/.*+//' || echo "1")

echo "版本号: $VERSION_NAME"
echo "构建号: $BUILD_NUMBER"

# 构建 APK
echo -e "${YELLOW}构建参数:${NC}"
echo "  模式: $BUILD_MODE"
echo "  环境: $ENV"
echo "  版本: $VERSION_NAME"
echo "  构建号: $BUILD_NUMBER"

if [ "$BUILD_MODE" = "release" ]; then
    flutter build apk --release \
        --dart-define=APP_ENV="$ENV" \
        --build-name="$VERSION_NAME" \
        --build-number="$BUILD_NUMBER"
else
    flutter build apk --debug \
        --dart-define=APP_ENV="$ENV" \
        --build-name="$VERSION_NAME" \
        --build-number="$BUILD_NUMBER"
fi

# 检查构建是否成功
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ APK 构建失败！${NC}"
    exit 1
fi

# 2.5. 将自定义文件名的 APK 复制到 flutter-apk 目录（保持一致性）
echo -e "${YELLOW}📋 同步 APK 文件到 flutter-apk 目录...${NC}"
CUSTOM_APK=$(find build/app/outputs/apk -name "Frame-*.apk" -type f 2>/dev/null | head -1)
if [ -n "$CUSTOM_APK" ] && [ -f "$CUSTOM_APK" ]; then
    FLUTTER_APK_DIR="build/app/outputs/flutter-apk"
    mkdir -p "$FLUTTER_APK_DIR"
    CUSTOM_APK_NAME=$(basename "$CUSTOM_APK")
    cp "$CUSTOM_APK" "$FLUTTER_APK_DIR/$CUSTOM_APK_NAME"
    echo -e "${GREEN}✅ 已同步: $CUSTOM_APK_NAME${NC}"
fi

# 3. 查找 APK 文件（尝试多个可能的路径）
# 注意：Flutter 构建会在两个位置生成 APK：
# 1. build/app/outputs/apk/release/ - Android Gradle 标准输出（应用了自定义文件名）
# 2. build/app/outputs/flutter-apk/ - Flutter 输出（默认文件名）
# 优先查找自定义文件名的 APK
APK_PATHS=(
    "build/app/outputs/apk/${BUILD_MODE}/Frame-*.apk"  # 新格式：Frame-版本号-构建类型-时间戳.apk（Gradle 输出）
    "build/app/outputs/apk/release/Frame-*.apk"  # Release 构建的自定义文件名
    "build/app/outputs/apk/debug/Frame-*.apk"  # Debug 构建的自定义文件名
    "build/app/outputs/flutter-apk/Frame-*.apk"  # Flutter 输出目录中的自定义文件名
    "build/app/outputs/flutter-apk/app-${BUILD_MODE}.apk"  # Flutter 默认文件名
    "build/app/outputs/flutter-apk/app-release.apk"
    "build/app/outputs/flutter-apk/app-debug.apk"
    "build/app/outputs/flutter-apk/*.apk"  # 任何 APK 文件
)

APK_PATH=""
for path in "${APK_PATHS[@]}"; do
    # 处理通配符路径
    if [[ "$path" == *"*"* ]]; then
        # 查找匹配的文件
        found=$(ls -t $path 2>/dev/null | head -1)
        if [ -n "$found" ] && [ -f "$found" ]; then
            APK_PATH="$found"
            break
        fi
    elif [ -f "$path" ]; then
        APK_PATH="$path"
        break
    fi
done

# 如果还是找不到，列出目录内容帮助调试
if [ -z "$APK_PATH" ] || [ ! -f "$APK_PATH" ]; then
    echo -e "${RED}❌ 错误: 找不到 APK 文件${NC}"
    echo "已尝试的路径:"
    for path in "${APK_PATHS[@]}"; do
        echo "  - $path"
    done
    echo ""
    echo "构建输出目录内容:"
    if [ -d "build/app/outputs/flutter-apk" ]; then
        ls -la build/app/outputs/flutter-apk/ || true
    else
        echo "  目录不存在: build/app/outputs/flutter-apk"
        echo "  检查构建输出:"
        find build -name "*.apk" 2>/dev/null | head -5 || echo "  未找到任何 APK 文件"
    fi
    exit 1
fi

echo -e "${GREEN}✅ APK 构建成功: $APK_PATH${NC}"

# 4. 获取 APK 信息
APK_SIZE=$(du -h "$APK_PATH" | cut -f1)
echo "APK 大小: $APK_SIZE"

# 5. 上传到蒲公英
echo -e "${YELLOW}📤 上传到蒲公英...${NC}"

# 构建上传参数
UPLOAD_PARAMS=(
    -F "_api_key=$PGYER_API_KEY"
    -F "file=@$APK_PATH"
    -F "buildUpdateDescription=$UPDATE_DESC"
)

# 如果设置了密码，添加密码参数
if [ -n "$PGYER_PASSWORD" ]; then
    UPLOAD_PARAMS+=(-F "buildPassword=$PGYER_PASSWORD")
fi

# 上传文件
UPLOAD_RESPONSE=$(curl -s "${UPLOAD_PARAMS[@]}" "$PGYER_UPLOAD_URL")

# 检查上传结果
if echo "$UPLOAD_RESPONSE" | grep -q '"code":0'; then
    # 提取下载链接和二维码
    DOWNLOAD_URL=$(echo "$UPLOAD_RESPONSE" | grep -o '"buildShortcutUrl":"[^"]*"' | cut -d'"' -f4)
    QR_CODE_URL=$(echo "$UPLOAD_RESPONSE" | grep -o '"buildQRCodeURL":"[^"]*"' | cut -d'"' -f4)
    BUILD_NAME=$(echo "$UPLOAD_RESPONSE" | grep -o '"buildName":"[^"]*"' | cut -d'"' -f4)
    BUILD_VERSION=$(echo "$UPLOAD_RESPONSE" | grep -o '"buildVersion":"[^"]*"' | cut -d'"' -f4)
    
    DOWNLOAD_LINK="https://www.pgyer.com/$DOWNLOAD_URL"
    
    echo -e "${GREEN}✅ 上传成功！${NC}"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📱 应用信息"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "应用名称: $BUILD_NAME"
    echo "版本号: $BUILD_VERSION"
    echo "环境: $ENV"
    echo ""
    echo "📥 下载链接: $DOWNLOAD_LINK"
    echo "📱 二维码URL: $QR_CODE_URL"
    
    # 在控制台打印二维码
    print_qr_code "$DOWNLOAD_LINK"
    
    if [ -n "$PGYER_PASSWORD" ]; then
        echo "🔒 安装密码: $PGYER_PASSWORD"
        echo ""
    fi
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # 保存信息到文件
    INFO_FILE="build/pgyer-info.txt"
    mkdir -p build
    cat > "$INFO_FILE" << EOF
上传时间: $(date '+%Y-%m-%d %H:%M:%S')
应用名称: $BUILD_NAME
版本号: $BUILD_VERSION
环境: $ENV
下载链接: https://www.pgyer.com/$DOWNLOAD_URL
二维码: $QR_CODE_URL
安装密码: ${PGYER_PASSWORD:-"无"}
更新说明: $UPDATE_DESC
EOF
    
    echo -e "${GREEN}📄 信息已保存到: $INFO_FILE${NC}"
else
    echo -e "${RED}❌ 上传失败！${NC}"
    echo "响应: $UPLOAD_RESPONSE"
    exit 1
fi

echo -e "${GREEN}🎉 完成！${NC}"
