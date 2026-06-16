import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../base/base_page.dart';
import '../../theme/app_design_tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../overlay/overlay.dart';
import 'database_demo_controller.dart';
import '../../database/models/user_table_model.dart';
import '../../database/models/product_table_model.dart';

/// 数据库演示页面
class DatabaseDemoPage extends BasePage<DatabaseDemoController> {
  const DatabaseDemoPage({super.key});

  @override
  String? get pageTitle => '数据库演示';

  @override
  Widget buildContent(BuildContext context) {
    return Column(
      children: [
        // 表切换工具栏
        _buildTableToolbar(),
        // 搜索框
        _buildSearchBar(),
        // 操作工具栏
        _buildActionToolbar(),
        // 数据列表
        Expanded(
          child: Obx(() {
            if (controller.selectedTable.value == 'users') {
              return _buildUserList();
            } else {
              return _buildProductList();
            }
          }),
        ),
      ],
    );
  }

  /// 构建表切换工具栏
  Widget _buildTableToolbar() {
    return Container(
      margin: EdgeInsets.all(AppDesignTokens.spacing16),
      padding: EdgeInsets.all(AppDesignTokens.spacing12),
      decoration: BoxDecoration(
        color: AppDesignTokens.surfaceColor,
        borderRadius: BorderRadius.circular(AppDesignTokens.radius12),
        boxShadow: AppDesignTokens.shadowSmall,
      ),
      child: Obx(() => Row(
        children: [
          Expanded(
            child: _buildTableButton(
              'users',
              '用户',
              Icons.people,
              controller.selectedTable.value == 'users',
            ),
          ),
          SizedBox(width: AppDesignTokens.spacing8),
          Expanded(
            child: _buildTableButton(
              'products',
              '产品',
              Icons.shopping_bag,
              controller.selectedTable.value == 'products',
            ),
          ),
        ],
      )),
    );
  }

  /// 构建表切换按钮
  Widget _buildTableButton(
    String table,
    String label,
    IconData icon,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () => controller.switchTable(table),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: AppDesignTokens.spacing8,
          vertical: AppDesignTokens.spacingV8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppDesignTokens.primaryColor
              : AppDesignTokens.grey100,
          borderRadius: BorderRadius.circular(AppDesignTokens.radius8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppDesignTokens.primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? Colors.white
                  : AppDesignTokens.textSecondary,
            ),
            SizedBox(width: AppDesignTokens.spacing4),
            Text(
              label,
              style: TextStyle(
                fontSize: AppDesignTokens.fontSize13,
                fontWeight: isSelected
                    ? AppDesignTokens.fontWeightSemiBold
                    : FontWeight.normal,
                color: isSelected
                    ? Colors.white
                    : AppDesignTokens.textSecondary,
              ),
            ),
            SizedBox(width: AppDesignTokens.spacing4),
            Obx(() {
              final count = table == 'users'
                  ? controller.userCount.value
                  : controller.productCount.value;
              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDesignTokens.spacing8,
                  vertical: AppDesignTokens.spacingV4,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.3)
                      : AppDesignTokens.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDesignTokens.radius12),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: AppDesignTokens.fontSize12,
                    fontWeight: AppDesignTokens.fontWeightSemiBold,
                    color: isSelected
                        ? Colors.white
                        : AppDesignTokens.primaryColor,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  /// 构建搜索框
  Widget _buildSearchBar() {
    return _SearchBarWidget(controller: controller);
  }

  /// 构建操作工具栏
  Widget _buildActionToolbar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppDesignTokens.spacing16),
      padding: EdgeInsets.all(AppDesignTokens.spacing12),
      decoration: BoxDecoration(
        color: AppDesignTokens.surfaceColor,
        borderRadius: BorderRadius.circular(AppDesignTokens.radius12),
        boxShadow: AppDesignTokens.shadowSmall,
      ),
      child: Obx(() {
        final isUsers = controller.selectedTable.value == 'users';
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: isUsers ? '添加用户' : '添加产品',
                    icon: Icons.add,
                    onPressed: isUsers
                        ? controller.addSampleUser
                        : controller.addSampleProduct,
                    type: AppButtonType.primary,
                  ),
                ),
                SizedBox(width: AppDesignTokens.spacing8),
                Expanded(
                  child: AppButton(
                    text: '批量添加',
                    icon: Icons.add_circle_outline,
                    onPressed: () => _showBatchAddDialog(isUsers),
                    type: AppButtonType.secondary,
                  ),
                ),
                SizedBox(width: AppDesignTokens.spacing8),
                Expanded(
                  child: AppButton(
                    text: '清空',
                    icon: Icons.delete_outline,
                    onPressed: isUsers
                        ? controller.clearUsers
                        : controller.clearProducts,
                    type: AppButtonType.danger,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppDesignTokens.spacingV8),
            AppButton(
              text: '刷新',
              icon: Icons.refresh,
              onPressed: controller.refreshData,
              type: AppButtonType.outline,
            ),
          ],
        );
      }),
    );
  }

  /// 显示批量添加对话框
  Future<void> _showBatchAddDialog(bool isUsers) async {
    final value = await AppOverlay.dialog.inputAsync(
      title: '批量添加${isUsers ? '用户' : '产品'}',
      hintText: '请输入要添加的数量',
      initialValue: '10',
      keyboardType: TextInputType.number,
    );
    if (value == null) return;

    final count = int.tryParse(value) ?? 10;
    if (isUsers) {
      controller.batchAddUsers(count);
    } else {
      controller.batchAddProducts(count);
    }
  }

  /// 构建用户列表
  Widget _buildUserList() {
    return Obx(() {
      if (controller.users.isEmpty) {
        return Center(
          child: Text(
            '暂无用户数据',
            style: TextStyle(
              fontSize: AppDesignTokens.fontSize14,
              color: AppDesignTokens.textSecondary,
            ),
          ),
        );
      }
      return ListView.builder(
        padding: EdgeInsets.all(AppDesignTokens.spacing16),
        itemCount: controller.users.length,
        itemBuilder: (context, index) {
          final user = controller.users[index];
          return _buildUserItem(user);
        },
      );
    });
  }

  /// 构建用户项
  Widget _buildUserItem(UserTableModel user) {
    return AppCard(
      margin: EdgeInsets.only(bottom: AppDesignTokens.spacingV12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppDesignTokens.primaryColor.withOpacity(0.1),
            child: Icon(
              Icons.person,
              color: AppDesignTokens.primaryColor,
            ),
          ),
          SizedBox(width: AppDesignTokens.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name ?? user.username,
                  style: TextStyle(
                    fontSize: AppDesignTokens.fontSize16,
                    fontWeight: AppDesignTokens.fontWeightSemiBold,
                    color: AppDesignTokens.textPrimary,
                  ),
                ),
                SizedBox(height: AppDesignTokens.spacingV4),
                Text(
                  user.email,
                  style: TextStyle(
                    fontSize: AppDesignTokens.fontSize13,
                    color: AppDesignTokens.textSecondary,
                  ),
                ),
                if (user.phone != null) ...[
                  SizedBox(height: AppDesignTokens.spacingV4),
                  Text(
                    user.phone!,
                    style: TextStyle(
                      fontSize: AppDesignTokens.fontSize12,
                      color: AppDesignTokens.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit_outlined, color: AppDesignTokens.primaryColor),
            onPressed: () => _showEditUserDialog(user),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: AppDesignTokens.errorColor),
            onPressed: () => controller.deleteUser(user.id),
          ),
        ],
      ),
    );
  }

  /// 构建产品列表
  Widget _buildProductList() {
    return Obx(() {
      if (controller.products.isEmpty) {
        return Center(
          child: Text(
            '暂无产品数据',
            style: TextStyle(
              fontSize: AppDesignTokens.fontSize14,
              color: AppDesignTokens.textSecondary,
            ),
          ),
        );
      }
      return ListView.builder(
        padding: EdgeInsets.all(AppDesignTokens.spacing16),
        itemCount: controller.products.length,
        itemBuilder: (context, index) {
          final product = controller.products[index];
          return _buildProductItem(product);
        },
      );
    });
  }

  /// 构建产品项
  Widget _buildProductItem(ProductTableModel product) {
    return AppCard(
      margin: EdgeInsets.only(bottom: AppDesignTokens.spacingV12),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppDesignTokens.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDesignTokens.radius8),
            ),
            child: Icon(
              Icons.shopping_bag,
              color: AppDesignTokens.primaryColor,
              size: 32,
            ),
          ),
          SizedBox(width: AppDesignTokens.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: TextStyle(
                    fontSize: AppDesignTokens.fontSize16,
                    fontWeight: AppDesignTokens.fontWeightSemiBold,
                    color: AppDesignTokens.textPrimary,
                  ),
                ),
                SizedBox(height: AppDesignTokens.spacingV4),
                Text(
                  product.description ?? '无描述',
                  style: TextStyle(
                    fontSize: AppDesignTokens.fontSize13,
                    color: AppDesignTokens.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: AppDesignTokens.spacingV4),
                Row(
                  children: [
                    Flexible(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDesignTokens.spacing8,
                          vertical: AppDesignTokens.spacingV4,
                        ),
                        decoration: BoxDecoration(
                          color: AppDesignTokens.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppDesignTokens.radius4),
                        ),
                        child: Text(
                          product.category,
                          style: TextStyle(
                            fontSize: AppDesignTokens.fontSize12,
                            color: AppDesignTokens.primaryColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    SizedBox(width: AppDesignTokens.spacing8),
                    Text(
                      '¥${product.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: AppDesignTokens.fontSize14,
                        fontWeight: AppDesignTokens.fontWeightBold,
                        color: AppDesignTokens.errorColor,
                      ),
                    ),
                    SizedBox(width: AppDesignTokens.spacing8),
                    Flexible(
                      child: Text(
                        '库存: ${product.stock}',
                        style: TextStyle(
                          fontSize: AppDesignTokens.fontSize12,
                          color: AppDesignTokens.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit_outlined, color: AppDesignTokens.primaryColor),
            onPressed: () => _showEditProductDialog(product),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: AppDesignTokens.errorColor),
            onPressed: () => controller.deleteProduct(product.id),
          ),
        ],
      ),
    );
  }

  /// 显示编辑用户对话框
  void _showEditUserDialog(UserTableModel user) {
    final nameController = TextEditingController(text: user.name ?? '');
    final emailController = TextEditingController(text: user.email);
    final phoneController = TextEditingController(text: user.phone ?? '');

    Get.dialog(
      AlertDialog(
        title: Text('编辑用户'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: '姓名',
                  hintText: '请输入姓名',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDesignTokens.radius8),
                  ),
                ),
              ),
              SizedBox(height: AppDesignTokens.spacingV12),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: '邮箱',
                  hintText: '请输入邮箱',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDesignTokens.radius8),
                  ),
                ),
              ),
              SizedBox(height: AppDesignTokens.spacingV12),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: '电话',
                  hintText: '请输入电话',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDesignTokens.radius8),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('取消'),
          ),
          TextButton(
            onPressed: () {
              final updatedUser = user.copyWith(
                name: nameController.text.isEmpty ? null : nameController.text,
                email: emailController.text,
                phone: phoneController.text.isEmpty ? null : phoneController.text,
                updatedAt: DateTime.now(),
              );
              controller.updateUser(updatedUser);
              Get.back();
            },
            child: Text('保存'),
          ),
        ],
      ),
    );
  }

  /// 显示编辑产品对话框
  void _showEditProductDialog(ProductTableModel product) {
    final nameController = TextEditingController(text: product.name);
    final descriptionController = TextEditingController(text: product.description ?? '');
    final priceController = TextEditingController(text: product.price.toString());
    final stockController = TextEditingController(text: product.stock.toString());
    final categoryController = TextEditingController(text: product.category);
    bool isActive = product.isActive;

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('编辑产品'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: '产品名称',
                      hintText: '请输入产品名称',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppDesignTokens.radius8),
                      ),
                    ),
                  ),
                  SizedBox(height: AppDesignTokens.spacingV12),
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: '描述',
                      hintText: '请输入产品描述',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppDesignTokens.radius8),
                      ),
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: AppDesignTokens.spacingV12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: priceController,
                          decoration: InputDecoration(
                            labelText: '价格',
                            hintText: '0.00',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppDesignTokens.radius8),
                            ),
                          ),
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                      SizedBox(width: AppDesignTokens.spacing8),
                      Expanded(
                        child: TextField(
                          controller: stockController,
                          decoration: InputDecoration(
                            labelText: '库存',
                            hintText: '0',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppDesignTokens.radius8),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppDesignTokens.spacingV12),
                  TextField(
                    controller: categoryController,
                    decoration: InputDecoration(
                      labelText: '分类',
                      hintText: '请输入分类',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppDesignTokens.radius8),
                      ),
                    ),
                  ),
                  SizedBox(height: AppDesignTokens.spacingV12),
                  Row(
                    children: [
                      Text('是否启用：'),
                      SizedBox(width: AppDesignTokens.spacing8),
                      Switch(
                        value: isActive,
                        onChanged: (value) {
                          setState(() {
                            isActive = value;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: Text('取消'),
              ),
              TextButton(
                onPressed: () {
                  final updatedProduct = product.copyWith(
                    name: nameController.text,
                    description: descriptionController.text.isEmpty
                        ? null
                        : descriptionController.text,
                    price: double.tryParse(priceController.text) ?? product.price,
                    stock: int.tryParse(stockController.text) ?? product.stock,
                    category: categoryController.text,
                    isActive: isActive,
                    updatedAt: DateTime.now(),
                  );
                  controller.updateProduct(updatedProduct);
                  Get.back();
                },
                child: Text('保存'),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// 搜索框组件（独立 StatefulWidget 以管理 TextEditingController）
class _SearchBarWidget extends StatefulWidget {
  final DatabaseDemoController controller;

  const _SearchBarWidget({required this.controller});

  @override
  State<_SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<_SearchBarWidget> {
  late TextEditingController _searchController;
  String _lastKeyword = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.controller.searchKeyword.value);
    _lastKeyword = widget.controller.searchKeyword.value;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppDesignTokens.spacing16),
      padding: EdgeInsets.symmetric(horizontal: AppDesignTokens.spacing12),
      decoration: BoxDecoration(
        color: AppDesignTokens.surfaceColor,
        borderRadius: BorderRadius.circular(AppDesignTokens.radius12),
        boxShadow: AppDesignTokens.shadowSmall,
      ),
      child: Obx(() {
        final isUsers = widget.controller.selectedTable.value == 'users';
        final currentKeyword = widget.controller.searchKeyword.value;
        
        // 当 controller 的搜索关键词变化时（比如切换表或清除搜索），同步到 TextEditingController
        if (_lastKeyword != currentKeyword) {
          _searchController.text = currentKeyword;
          _lastKeyword = currentKeyword;
        }
        
        return TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: isUsers ? '搜索用户（用户名/邮箱）' : '搜索产品（名称/描述）',
            prefixIcon: Icon(Icons.search, color: AppDesignTokens.textSecondary),
            suffixIcon: currentKeyword.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, color: AppDesignTokens.textSecondary),
                    onPressed: () {
                      _searchController.clear();
                      widget.controller.clearSearch();
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: AppDesignTokens.spacingV12),
          ),
          onChanged: (value) {
            // 更新本地状态
            _lastKeyword = value;
            // 调用搜索方法
            if (isUsers) {
              widget.controller.searchUsers(value);
            } else {
              widget.controller.searchProducts(value);
            }
          },
        );
      }),
    );
  }
}
