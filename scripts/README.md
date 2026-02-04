# 构建脚本说明

## 脚本列表

### 1. `build-version.sh` - 版本号管理

更新应用的版本号和构建号。

**用法**:
```bash
./scripts/build-version.sh [version] [build_number]
```

**示例**:
```bash
./scripts/build-version.sh 1.0.1 123
```

**功能**:
- 更新 `pubspec.yaml` 中的版本号
- 更新 Android `build.gradle.kts` 中的版本信息
- 更新 iOS `Info.plist` 中的版本信息

### 2. `pre-build.sh` - 构建前准备

执行构建前的准备工作。

**用法**:
```bash
./scripts/pre-build.sh
```

**功能**:
- 清理旧的构建文件
- 获取依赖
- 验证 Flutter 环境
- 运行代码检查
- 运行测试

### 3. `build-and-upload-pgyer.sh` - 构建并上传到蒲公英

构建 APK 并自动上传到蒲公英开发者平台。

**用法**:
```bash
./scripts/build-and-upload-pgyer.sh [环境] [更新说明]
```

**示例**:

方式1: 使用环境变量
```bash
# 设置 API Key（注意：等号两边不能有空格）
export PGYER_API_KEY=your_api_key

# 可选：设置安装密码
export PGYER_PASSWORD=your_password

# 构建并上传
./scripts/build-and-upload-pgyer.sh prod "修复了若干bug"
```

方式2: 使用配置文件（推荐）
```bash
# 1. 创建配置文件
cp .pgyer_config.example .pgyer_config

# 2. 编辑 .pgyer_config，填入你的 API Key
# PGYER_API_KEY=your_api_key
# PGYER_PASSWORD=your_password  # 可选

# 3. 直接运行脚本（会自动读取配置文件）
./scripts/build-and-upload-pgyer.sh prod "修复了若干bug"
```

方式3: 脚本中已配置（当前方式）
- 脚本中已包含默认 API Key，可直接运行
- 如需修改，编辑脚本或使用上述方式

**参数**:
- `环境`: `dev` / `test` / `prod`（默认：prod）
- `更新说明`: 本次更新的描述信息

**环境变量配置方式**:

方式1: 使用环境变量（推荐）
```bash
# 注意：等号两边不能有空格
export PGYER_API_KEY=your_api_key
export PGYER_PASSWORD=your_password  # 可选
```

方式2: 使用配置文件（推荐，更安全）
```bash
# 复制示例文件
cp .pgyer_config.example .pgyer_config

# 编辑配置文件，填入你的 API Key
# .pgyer_config 已在 .gitignore 中，不会被提交
```

方式3: 直接在脚本中设置（不推荐）
- 脚本中已有默认值，但建议使用配置文件或环境变量

**环境变量**:
- `PGYER_API_KEY`（必需）: 蒲公英 API Key
- `PGYER_PASSWORD`（可选）: 安装密码

**功能**:
- 清理并获取依赖
- 构建 APK（Debug 或 Release）
- 上传到蒲公英
- 显示下载链接和二维码
- **在控制台直接打印二维码**（如果安装了 qrencode 或 Python qrcode）
- 保存上传信息到文件

**输出**:
- APK 文件: `build/app/outputs/flutter-apk/app-*.apk`
- 上传信息: `build/pgyer-info.txt`

### 4. `build-and-upload-pgyer-ios.sh` - 构建并上传 iOS IPA 到蒲公英

构建 iOS IPA 并自动上传到蒲公英开发者平台。

**用法**:
```bash
./scripts/build-and-upload-pgyer-ios.sh [环境] [更新说明]
```

**示例**:

方式1: 使用环境变量
```bash
# 设置 API Key（注意：等号两边不能有空格）
export PGYER_API_KEY=your_api_key

# 可选：设置安装密码
export PGYER_PASSWORD=your_password

# 构建并上传
./scripts/build-and-upload-pgyer-ios.sh prod "修复了若干bug"
```

方式2: 使用配置文件（推荐）
```bash
# 1. 创建配置文件（如果还没有）
cp .pgyer_config.example .pgyer_config

# 2. 编辑 .pgyer_config，填入你的 API Key
# PGYER_API_KEY=your_api_key
# PGYER_PASSWORD=your_password  # 可选

# 3. 直接运行脚本（会自动读取配置文件）
./scripts/build-and-upload-pgyer-ios.sh prod "修复了若干bug"
```

**参数**:
- `环境`: `dev` / `test` / `prod`（默认：prod）
- `更新说明`: 本次更新的描述信息

**环境变量**:
- `PGYER_API_KEY`（必需）: 蒲公英 API Key
- `PGYER_PASSWORD`（可选）: 安装密码

**功能**:
- 清理并获取依赖
- 安装 CocoaPods 依赖
- 构建 IPA（Debug 或 Release）
- 上传到蒲公英
- 显示下载链接和二维码
- **在控制台直接打印二维码**（如果安装了 qrencode 或 Python qrcode）
- 保存上传信息到文件

**输出**:
- IPA 文件: `build/ios/ipa/*.ipa`
- 上传信息: `build/pgyer-info-ios.txt`

**重要提示**:
- ⚠️ **只能在 macOS 上运行**（iOS 构建需要 macOS 和 Xcode）
- 需要配置 Xcode 签名证书和配置文件
- 需要安装 CocoaPods: `sudo gem install cocoapods`
- 如果构建失败，请检查 Xcode 项目配置

## 使用示例

### 完整发布流程

```bash
# 1. 更新版本号
./scripts/build-version.sh 1.0.1 123

# 2. 构建前检查
./scripts/pre-build.sh

# 3. 构建并上传到蒲公英
export PGYER_API_KEY=your_api_key
./scripts/build-and-upload-pgyer.sh prod "版本 1.0.1 发布"
```

### 快速开发测试

```bash
# Android 开发版本
export PGYER_API_KEY=your_api_key
./scripts/build-and-upload-pgyer.sh dev "开发测试版本"

# iOS 开发版本（仅 macOS）
export PGYER_API_KEY=your_api_key
./scripts/build-and-upload-pgyer-ios.sh dev "开发测试版本"
```

## 注意事项

1. **API Key 安全**
   - 不要将 API Key 提交到代码仓库
   - 使用环境变量或 GitHub Secrets 存储

2. **网络要求**
   - 上传到蒲公英需要网络连接
   - 确保能够访问 `www.pgyer.com`

3. **构建时间**
   - Release 构建需要较长时间
   - Debug 构建速度较快，适合测试

4. **版本号管理**
   - 建议使用语义化版本号
   - 构建号建议使用时间戳或 CI 构建号

5. **控制台二维码显示**
   - 脚本会自动尝试在控制台打印二维码
   - 推荐安装 `qrencode` 以获得最佳效果：
     - macOS: `brew install qrencode`
     - Linux: `sudo apt-get install qrencode` 或 `sudo yum install qrencode`
   - 或者安装 Python qrcode 库: `pip3 install qrcode[pil]`
   - 如果未安装，脚本会显示二维码 URL 链接

## 故障排查

### 上传失败

1. **检查 API Key**
   ```bash
   echo $PGYER_API_KEY
   ```

2. **检查网络连接**
   ```bash
   curl -I https://www.pgyer.com
   ```

3. **查看详细错误**
   - 脚本会输出详细的错误信息
   - 检查蒲公英 API 响应

### 构建失败

#### Android 构建失败

1. **检查 Flutter 环境**
   ```bash
   flutter doctor
   ```

2. **清理并重新构建**
   ```bash
   flutter clean
   flutter pub get
   ```

3. **检查依赖**
   ```bash
   flutter pub outdated
   ```

#### iOS 构建失败

1. **检查 macOS 和 Xcode**
   ```bash
   # 检查是否在 macOS 上
   uname -s
   
   # 检查 Xcode 版本
   xcodebuild -version
   
   # 检查 Flutter 环境
   flutter doctor
   ```

2. **检查 CocoaPods**
   ```bash
   # 检查是否安装
   pod --version
   
   # 如果未安装，安装 CocoaPods
   sudo gem install cocoapods
   
   # 更新 CocoaPods 仓库
   pod repo update
   ```

3. **检查签名配置**
   - 在 Xcode 中打开 `ios/Runner.xcworkspace`
   - 检查 `Signing & Capabilities` 配置
   - 确保有有效的开发者证书和配置文件

4. **清理并重新构建**
   ```bash
   flutter clean
   flutter pub get
   cd ios
   pod install
   cd ..
   flutter build ipa --release
   ```

### 5. `generate_page.sh` - 页面生成工具

快速生成 GetX MVVM 页面结构（Controller、Page、Binding），**支持多种 BasePage 类型**，并**自动配置路由**。

**用法**:
```bash
./scripts/generate_page.sh <page_name> [route_path] [page_type]
```

**参数说明**:
- `page_name`: 页面名称（支持下划线和连字符，如 `user_profile` 或 `user-profile`）
- `route_path`: 路由路径（可选，默认为 `/page_name`）
- `page_type`: 页面类型（可选，默认为 `base`）

**页面类型**:
- `base` (默认) - `BasePage`，需要实现 `buildContent` 方法
- `scroll` - `BaseScrollPage`，需要实现 `buildScrollContent` 方法（带滚动视图）
- `list` - `BaseListPage`，需要实现 `buildListItem` 和 `items` getter（列表页面）
- `refresh` - `BaseRefreshPage`，需要实现 `buildRefreshContent` 方法（支持下拉刷新和上拉加载）

**示例**:
```bash
# 生成基础页面（默认）
./scripts/generate_page.sh user_profile /user-profile

# 生成滚动页面
./scripts/generate_page.sh product_detail /product-detail scroll

# 生成列表页面
./scripts/generate_page.sh order_list /order-list list

# 生成刷新页面（支持下拉刷新和上拉加载）
./scripts/generate_page.sh news_list /news-list refresh
```

**功能**:
- ✅ 自动创建 Controller、Page、Binding 三个文件
- ✅ 根据页面类型生成对应的代码结构
- ✅ **自动配置路由**（添加到 `app_routes.dart` 和 `app_pages.dart`）
- ✅ 自动添加 import 语句
- ✅ 生成符合项目规范的代码

**输出**:
- `lib/pages/{page_name}/{page_name}_controller.dart`
- `lib/pages/{page_name}/{page_name}_page.dart`
- `lib/pages/{page_name}/{page_name}_binding.dart`

**注意事项**:
- `refresh` 类型的页面，Controller 会自动继承 `BaseRefreshController`，需要实现 `loadData()` 和 `loadMoreData()` 方法
- `list` 类型的页面，需要指定数据模型类型（在生成的代码中修改 `dynamic` 为实际类型）
- 如果路由已存在，脚本会跳过添加，避免重复

### 6. `switch-env.sh` - 环境切换工具

快速切换开发/测试/生产环境。

**用法**:
```bash
./scripts/switch-env.sh [dev|test|prod]
```

**示例**:
```bash
# 切换到开发环境
./scripts/switch-env.sh dev

# 切换到生产环境
./scripts/switch-env.sh prod
```

**功能**:
- 更新环境配置文件
- 创建环境标记文件
- 显示运行命令提示

### 7. `run-tests.sh` - 测试运行工具

运行单元测试或集成测试。

**用法**:
```bash
./scripts/run-tests.sh [unit|integration|all]
```

**示例**:
```bash
# 运行所有测试
./scripts/run-tests.sh all

# 只运行单元测试
./scripts/run-tests.sh unit
```

## VS Code 代码片段

项目已配置 VS Code 代码片段，在编辑器中输入以下前缀即可快速生成代码：

- `gxcontroller` - GetX Controller 模板
- `gxpage` - GetX Page 模板
- `gxbinding` - GetX Binding 模板
- `networkreq` - 网络请求模板
- `localcache` - 本地缓存模板
- `obx` - GetX Obx 响应式组件
- `appbutton` - AppButton 组件
- `appcard` - AppCard 组件
- `trycatch` - Try-Catch 错误处理模板

**使用方法**:
1. 在 VS Code 中打开 Dart 文件
2. 输入代码片段前缀（如 `gxcontroller`）
3. 按 `Tab` 键自动补全
4. 使用 `Tab` 键在占位符之间跳转

## 相关文档

- [CI/CD 配置指南](../CI_CD_GUIDE.md)
- [环境配置指南](../ENVIRONMENT_CONFIG_GUIDE.md)
- [蒲公英 API 文档](https://www.pgyer.com/doc/view/api#uploadApp)
