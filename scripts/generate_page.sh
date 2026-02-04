#!/bin/bash

# 页面生成脚本
# 用法: ./scripts/generate_page.sh <page_name> [route_path] [page_type]
# 示例: ./scripts/generate_page.sh user_profile /user-profile
# 示例: ./scripts/generate_page.sh product_list /product-list scroll
# 示例: ./scripts/generate_page.sh order_list /order-list list
# 示例: ./scripts/generate_page.sh news_list /news-list refresh
#
# page_type 可选值:
#   base (默认) - BasePage，需要实现 buildContent
#   scroll      - BaseScrollPage，需要实现 buildScrollContent
#   list        - BaseListPage，需要实现 buildListItem 和 items getter
#   refresh     - BaseRefreshPage，需要实现 buildRefreshContent，Controller 需继承 BaseRefreshController

set -e

if [ -z "$1" ]; then
    echo "❌ 错误: 请提供页面名称"
    echo "用法: ./scripts/generate_page.sh <page_name> [route_path] [page_type]"
    echo ""
    echo "page_type 可选值:"
    echo "  base (默认) - BasePage，需要实现 buildContent"
    echo "  scroll      - BaseScrollPage，需要实现 buildScrollContent"
    echo "  list        - BaseListPage，需要实现 buildListItem 和 items getter"
    echo "  refresh     - BaseRefreshPage，需要实现 buildRefreshContent"
    echo ""
    echo "示例:"
    echo "  ./scripts/generate_page.sh user_profile /user-profile"
    echo "  ./scripts/generate_page.sh product_list /product-list scroll"
    echo "  ./scripts/generate_page.sh order_list /order-list list"
    echo "  ./scripts/generate_page.sh news_list /news-list refresh"
    exit 1
fi

PAGE_NAME=$1
# 转换为小写（兼容 macOS）
PAGE_NAME_LOWER=$(echo "$PAGE_NAME" | tr '[:upper:]' '[:lower:]')
ROUTE_PATH=${2:-"/$PAGE_NAME_LOWER"}  # 默认路由为小写页面名
PAGE_TYPE=${3:-"base"}  # 默认使用 BasePage

# 转换为驼峰命名（首字母大写，处理下划线和连字符）
# 例如: product_detail -> ProductDetail, user-profile -> UserProfile
PAGE_NAME_CAPITALIZED=$(echo "$PAGE_NAME" | awk -F'[_-]' '{
  result = ""
  for (i=1; i<=NF; i++) {
    word = $i
    if (length(word) > 0) {
      first = toupper(substr(word,1,1))
      rest = tolower(substr(word,2))
      result = result first rest
    }
  }
  print result
}')
PAGE_DIR="$PAGE_NAME_LOWER"
CONTROLLER_NAME="${PAGE_NAME_CAPITALIZED}Controller"
BINDING_NAME="${PAGE_NAME_CAPITALIZED}Binding"
PAGE_CLASS="${PAGE_NAME_CAPITALIZED}Page"
CONTROLLER_FILE="${PAGE_DIR}_controller.dart"
PAGE_FILE="${PAGE_DIR}_page.dart"
BINDING_FILE="${PAGE_DIR}_binding.dart"

# 验证 page_type
case $PAGE_TYPE in
  base|scroll|list|refresh)
    ;;
  *)
    echo "❌ 错误: 无效的 page_type: $PAGE_TYPE"
    echo "可用类型: base, scroll, list, refresh"
    exit 1
    ;;
esac

# 创建目录
mkdir -p "lib/pages/$PAGE_DIR"

# 生成 Controller
if [ "$PAGE_TYPE" = "refresh" ]; then
  # Refresh 页面需要使用 BaseRefreshController
  cat > "lib/pages/$PAGE_DIR/$CONTROLLER_FILE" << EOF
import '../../base/base_refresh_controller.dart';

class $CONTROLLER_NAME extends BaseRefreshController {
  @override
  void onInit() {
    super.onInit();
    // TODO: 初始化逻辑
  }

  @override
  void onReady() {
    super.onReady();
    // TODO: 页面准备完成后的逻辑
    // 自动加载数据
    loadData();
  }

  @override
  void onClose() {
    super.onClose();
    // TODO: 清理资源
  }

  @override
  Future<void> loadData() async {
    // TODO: 实现加载数据逻辑（第一页）
    // 示例:
    // isLoading.value = true;
    // try {
    //   final data = await api.getList(page: 1);
    //   items.assignAll(data);
    //   resetRefreshState();
    // } catch (e) {
    //   setError('加载失败: \$e');
    // } finally {
    //   isLoading.value = false;
    // }
  }

  @override
  Future<bool> loadMoreData() async {
    // TODO: 实现加载更多数据逻辑
    // 示例:
    // try {
    //   final nextPage = currentPage + 1;
    //   final data = await api.getList(page: nextPage);
    //   items.addAll(data);
    //   return data.isNotEmpty; // 返回是否还有更多数据
    // } catch (e) {
    //   setError('加载失败: \$e');
    //   return false;
    // }
    return false;
  }
}
EOF
else
  # 其他类型使用 BaseController
  cat > "lib/pages/$PAGE_DIR/$CONTROLLER_FILE" << EOF
import '../../base/base_controller.dart';

class $CONTROLLER_NAME extends BaseController {
  @override
  void onInit() {
    super.onInit();
    // TODO: 初始化逻辑
  }

  @override
  void onReady() {
    super.onReady();
    // TODO: 页面准备完成后的逻辑
  }

  @override
  void onClose() {
    super.onClose();
    // TODO: 清理资源
  }
}
EOF
fi

# 生成 Page（根据不同类型生成不同代码）
case $PAGE_TYPE in
  base)
    cat > "lib/pages/$PAGE_DIR/$PAGE_FILE" << EOF
import 'package:flutter/material.dart';
import '../../base/base_page.dart';
import '${PAGE_DIR}_controller.dart';

class $PAGE_CLASS extends BasePage<$CONTROLLER_NAME> {
  const $PAGE_CLASS({super.key});

  @override
  String? get pageTitle => '$PAGE_NAME_CAPITALIZED';

  @override
  Widget buildContent(BuildContext context) {
    return const Center(
      child: Text('$PAGE_NAME_CAPITALIZED Page'),
    );
  }
}
EOF
    ;;
  scroll)
    cat > "lib/pages/$PAGE_DIR/$PAGE_FILE" << EOF
import 'package:flutter/material.dart';
import '../../base/base_page.dart';
import '${PAGE_DIR}_controller.dart';

class $PAGE_CLASS extends BaseScrollPage<$CONTROLLER_NAME> {
  const $PAGE_CLASS({super.key});

  @override
  String? get pageTitle => '$PAGE_NAME_CAPITALIZED';

  @override
  Widget buildScrollContent(BuildContext context) {
    return Column(
      children: [
        // TODO: 添加滚动内容
        const Text('$PAGE_NAME_CAPITALIZED Scroll Page'),
      ],
    );
  }
}
EOF
    ;;
  list)
    cat > "lib/pages/$PAGE_DIR/$PAGE_FILE" << EOF
import 'package:flutter/material.dart';
import '../../base/base_page.dart';
import '${PAGE_DIR}_controller.dart';

// TODO: 导入你的数据模型
// import 'models/your_item_model.dart';

class $PAGE_CLASS extends BaseListPage<$CONTROLLER_NAME, dynamic> {
  const $PAGE_CLASS({super.key});

  @override
  String? get pageTitle => '$PAGE_NAME_CAPITALIZED';

  @override
  List<dynamic> get items {
    // TODO: 从 Controller 获取列表数据
    // 示例: return controller.items;
    return [];
  }

  @override
  Widget buildListItem(BuildContext context, dynamic item, int index) {
    // TODO: 实现列表项 UI
    return ListTile(
      title: Text('Item \$index'),
      subtitle: Text('Item data: \$item'),
    );
  }
}
EOF
    ;;
  refresh)
    cat > "lib/pages/$PAGE_DIR/$PAGE_FILE" << EOF
import 'package:flutter/material.dart';
import '../../base/base_refresh_page.dart';
import '${PAGE_DIR}_controller.dart';

class $PAGE_CLASS extends BaseRefreshPage<$CONTROLLER_NAME> {
  const $PAGE_CLASS({super.key});

  @override
  String? get pageTitle => '$PAGE_NAME_CAPITALIZED';

  @override
  Widget buildRefreshContent(BuildContext context) {
    return Obx(() {
      // TODO: 从 Controller 获取数据并构建列表
      // 示例:
      // final items = controller.items;
      // if (items.isEmpty) {
      //   return buildEmptyWidget(context) ?? const SizedBox();
      // }
      // return ListView.builder(
      //   itemCount: items.length,
      //   itemBuilder: (context, index) {
      //     return ListTile(
      //       title: Text(items[index].title),
      //     );
      //   },
      // );
      
      return const Center(
        child: Text('$PAGE_NAME_CAPITALIZED Refresh Page'),
      );
    });
  }
}
EOF
    ;;
esac

# 生成 Binding
cat > "lib/pages/$PAGE_DIR/$BINDING_FILE" << EOF
import 'package:get/get.dart';
import '${PAGE_DIR}_controller.dart';

class $BINDING_NAME extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => $CONTROLLER_NAME());
  }
}
EOF

# 生成路由常量名称
ROUTE_CONST=$(echo "$PAGE_NAME" | tr '[:lower:]' '[:upper:]' | tr '-' '_')

# 自动添加路由配置
echo "🔧 自动配置路由..."

# 1. 在 app_routes.dart 中添加路由常量
ROUTES_FILE="lib/app/routes/app_routes.dart"
if [ -f "$ROUTES_FILE" ]; then
  # 检查是否已存在
  if grep -q "static const $ROUTE_CONST" "$ROUTES_FILE"; then
    echo "⚠️  路由常量 $ROUTE_CONST 已存在，跳过添加"
  else
    # 在 Routes 类中添加常量（在最后一个 static const 之后）
    if [[ "$OSTYPE" == "darwin"* ]]; then
      sed -i '' "/static const FILE_DOWNLOAD_DEMO = _Paths.FILE_DOWNLOAD_DEMO;/a\\
  static const $ROUTE_CONST = _Paths.$ROUTE_CONST;
" "$ROUTES_FILE"
    else
      sed -i "/static const FILE_DOWNLOAD_DEMO = _Paths.FILE_DOWNLOAD_DEMO;/a\\  static const $ROUTE_CONST = _Paths.$ROUTE_CONST;" "$ROUTES_FILE"
    fi
    
    # 在 _Paths 类中添加路径常量（在最后一个 static const 之后）
    if [[ "$OSTYPE" == "darwin"* ]]; then
      sed -i '' "/static const FILE_DOWNLOAD_DEMO = '\/file-download-demo';/a\\
  static const $ROUTE_CONST = '$ROUTE_PATH';
" "$ROUTES_FILE"
    else
      sed -i "/static const FILE_DOWNLOAD_DEMO = '\/file-download-demo';/a\\  static const $ROUTE_CONST = '$ROUTE_PATH';" "$ROUTES_FILE"
    fi
    
    echo "✅ 已添加路由常量到 app_routes.dart"
  fi
else
  echo "⚠️  未找到 $ROUTES_FILE，跳过路由常量添加"
fi

# 2. 在 app_pages.dart 中添加 import 和路由配置
PAGES_FILE="lib/app/routes/app_pages.dart"
if [ -f "$PAGES_FILE" ]; then
  # 检查是否已存在 import
  PAGE_IMPORT="import '../../pages/$PAGE_DIR/${PAGE_DIR}_page.dart';"
  BINDING_IMPORT="import '../../pages/$PAGE_DIR/${PAGE_DIR}_binding.dart';"
  
  if ! grep -q "${PAGE_DIR}_page.dart" "$PAGES_FILE"; then
    # 在最后一个 import 之后添加（使用临时文件方式）
    LAST_IMPORT_LINE=$(grep -n "import.*file_download_demo" "$PAGES_FILE" | tail -1 | cut -d: -f1)
    if [ -n "$LAST_IMPORT_LINE" ]; then
      # 创建临时文件
      TEMP_FILE=$(mktemp)
      head -n "$LAST_IMPORT_LINE" "$PAGES_FILE" > "$TEMP_FILE"
      echo "$PAGE_IMPORT" >> "$TEMP_FILE"
      echo "$BINDING_IMPORT" >> "$TEMP_FILE"
      tail -n +$((LAST_IMPORT_LINE + 1)) "$PAGES_FILE" >> "$TEMP_FILE"
      mv "$TEMP_FILE" "$PAGES_FILE"
      echo "✅ 已添加 import 语句到 app_pages.dart"
    else
      echo "⚠️  未找到插入位置，请手动添加 import"
    fi
  else
    echo "⚠️  import 语句已存在，跳过"
  fi
  
  # 检查是否已存在路由配置
  if ! grep -q "_Paths.$ROUTE_CONST" "$PAGES_FILE"; then
    # 在最后一个 GetPage 之后添加路由配置（在 ]; 之前）
    LAST_ROUTE_LINE=$(grep -n "binding: FileDownloadDemoBinding()" "$PAGES_FILE" | tail -1 | cut -d: -f1)
    if [ -n "$LAST_ROUTE_LINE" ]; then
      # 创建临时文件
      TEMP_FILE=$(mktemp)
      head -n "$LAST_ROUTE_LINE" "$PAGES_FILE" > "$TEMP_FILE"
      echo "    )," >> "$TEMP_FILE"
      echo "" >> "$TEMP_FILE"
      echo "    // $PAGE_NAME_CAPITALIZED" >> "$TEMP_FILE"
      echo "    GetPage(" >> "$TEMP_FILE"
      echo "      name: _Paths.$ROUTE_CONST," >> "$TEMP_FILE"
      echo "      page: () => const $PAGE_CLASS()," >> "$TEMP_FILE"
      echo "      binding: $BINDING_NAME()," >> "$TEMP_FILE"
      tail -n +$((LAST_ROUTE_LINE + 1)) "$PAGES_FILE" >> "$TEMP_FILE"
      mv "$TEMP_FILE" "$PAGES_FILE"
      echo "✅ 已添加路由配置到 app_pages.dart"
    else
      echo "⚠️  未找到插入位置，请手动添加路由配置"
    fi
  else
    echo "⚠️  路由配置已存在，跳过"
  fi
else
  echo "⚠️  未找到 $PAGES_FILE，跳过路由配置添加"
fi

echo ""
echo "✅ 页面生成完成: $PAGE_NAME_CAPITALIZED"
echo "📁 文件位置: lib/pages/$PAGE_DIR/"
echo "📄 生成文件:"
echo "   - $CONTROLLER_FILE"
echo "   - $PAGE_FILE"
echo "   - $BINDING_FILE"
echo ""
echo "📋 页面类型: $PAGE_TYPE"
case $PAGE_TYPE in
  base)
    echo "   - 使用 BasePage，需要实现 buildContent 方法"
    ;;
  scroll)
    echo "   - 使用 BaseScrollPage，需要实现 buildScrollContent 方法"
    ;;
  list)
    echo "   - 使用 BaseListPage，需要实现 buildListItem 和 items getter"
    ;;
  refresh)
    echo "   - 使用 BaseRefreshPage，需要实现 buildRefreshContent 方法"
    echo "   - Controller 继承自 BaseRefreshController，需要实现 loadData 和 loadMoreData"
    ;;
esac
echo ""
echo "🔗 路由路径: $ROUTE_PATH"
echo ""
echo "🎉 路由配置完成！"
echo ""
echo "💡 提示: 如果自动配置失败，请手动检查以下文件:"
echo "   1. $ROUTES_FILE"
echo "   2. $PAGES_FILE"
