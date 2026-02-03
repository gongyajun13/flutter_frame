# CI/CD 配置指南

## 概述

本项目配置了完整的 CI/CD 流程，使用 GitHub Actions 实现自动化构建、测试和发布。

## 工作流说明

### 1. CI 工作流 (`ci.yml`)

**触发条件**:
- 推送到 `main` 或 `develop` 分支
- 创建 Pull Request 到 `main` 或 `develop` 分支

**执行任务**:
1. **代码检查和测试** (`analyze-and-test`)
   - 代码格式化检查
   - 代码静态分析
   - 运行单元测试

2. **Android 构建** (`build-android`)
   - 构建 Debug APK
   - 构建 Release APK
   - 上传构建产物

3. **iOS 构建** (`build-ios`)
   - 构建 Debug iOS 应用
   - 构建 Release iOS 应用（无签名）
   - 上传构建产物

### 2. 发布工作流 (`release.yml`)

**触发条件**:
- 推送版本标签（格式：`v*.*.*`，如 `v1.0.0`）
- 手动触发（Workflow Dispatch）

**执行任务**:
1. **Android 发布构建**
   - 构建 Release APK
   - 构建 Release AAB（用于 Google Play）
   - 自动创建 GitHub Release
   - 上传构建产物

2. **iOS 发布构建**
   - 构建 Release IPA
   - 上传构建产物

**环境变量支持**:
- `dev`: 开发环境
- `test`: 测试环境
- `prod`: 生产环境（默认）

### 3. 代码质量检查 (`code-quality.yml`)

**触发条件**:
- 推送到 `main` 或 `develop` 分支
- 创建 Pull Request
- 定时任务（每天 UTC 2:00）

**执行任务**:
- 代码格式化检查
- 代码静态分析
- 检查未使用的依赖
- 检查过期的包
- 生成代码覆盖率
- 上传覆盖率到 Codecov

## 使用方法

### 本地开发

```bash
# 运行代码检查
flutter analyze

# 运行测试
flutter test

# 检查代码格式
dart format --set-exit-if-changed .

# 构建 Android APK
flutter build apk --release --dart-define=APP_ENV=prod

# 构建 iOS IPA
flutter build ipa --release --dart-define=APP_ENV=prod
```

### 发布新版本

#### 方式 1: 使用 Git 标签

```bash
# 1. 更新版本号（在 pubspec.yaml 中）
version: 1.0.1+2

# 2. 提交更改
git add pubspec.yaml
git commit -m "Bump version to 1.0.1"

# 3. 创建并推送标签
git tag v1.0.1
git push origin v1.0.1
```

#### 方式 2: 手动触发

1. 进入 GitHub Actions 页面
2. 选择 "Release" 工作流
3. 点击 "Run workflow"
4. 填写版本号和选择环境
5. 点击 "Run workflow" 按钮

### 使用构建脚本

```bash
# 设置版本号
chmod +x scripts/build-version.sh
./scripts/build-version.sh 1.0.1 123

# 构建前准备
chmod +x scripts/pre-build.sh
./scripts/pre-build.sh
```

## 环境配置

### GitHub Secrets 配置

为了支持签名和发布，需要在 GitHub 仓库中配置以下 Secrets：

#### Android 签名（可选）

- `KEYSTORE_PASSWORD`: Keystore 密码
- `KEY_ALIAS`: 密钥别名
- `KEY_PASSWORD`: 密钥密码

#### iOS 签名（可选）

- `APPLE_ID`: Apple Developer 账号
- `APPLE_APP_SPECIFIC_PASSWORD`: App 专用密码
- `CERTIFICATE_P12`: 证书文件（Base64 编码）
- `CERTIFICATE_PASSWORD`: 证书密码

#### Codecov（可选）

- `CODECOV_TOKEN`: Codecov 访问令牌

### 配置步骤

1. 进入 GitHub 仓库
2. 点击 "Settings" → "Secrets and variables" → "Actions"
3. 点击 "New repository secret"
4. 添加所需的密钥

## 构建产物

### CI 构建产物

- **Android APK**: `build/app/outputs/flutter-apk/*.apk`
- **iOS 应用**: `build/ios/iphoneos/*.app`

### 发布构建产物

- **Android APK**: `build/app/outputs/flutter-apk/app-release.apk`
- **Android AAB**: `build/app/outputs/bundle/release/app-release.aab`
- **iOS IPA**: `build/ios/ipa/*.ipa`

所有构建产物都会自动上传到 GitHub Actions Artifacts，保留 7-30 天。

## 环境变量

### APP_ENV

通过 `--dart-define=APP_ENV=<env>` 传递环境变量：

- `dev`: 开发环境
  - API 基础地址：开发服务器
  - 启用网络日志：是
  - 启用控制台日志：是
  - 启用错误上报：否

- `test`: 测试环境
  - API 基础地址：测试服务器
  - 启用网络日志：是
  - 启用控制台日志：是
  - 启用错误上报：是

- `prod`: 生产环境（默认）
  - API 基础地址：生产服务器
  - 启用网络日志：否
  - 启用控制台日志：否
  - 启用错误上报：是

## 故障排查

### 构建失败

1. **检查 Flutter 版本**
   ```bash
   flutter --version
   ```
   确保本地版本与 CI 配置一致（3.29.1）

2. **检查依赖**
   ```bash
   flutter pub get
   flutter pub outdated
   ```

3. **检查代码格式**
   ```bash
   dart format .
   ```

4. **检查静态分析**
   ```bash
   flutter analyze
   ```

### 测试失败

1. **运行测试**
   ```bash
   flutter test
   ```

2. **检查测试覆盖率**
   ```bash
   flutter test --coverage
   ```

### iOS 构建问题

1. **更新 CocoaPods**
   ```bash
   cd ios
   pod install
   ```

2. **检查证书和配置文件**
   - 确保在 GitHub Secrets 中正确配置
   - 检查证书是否过期

### Android 构建问题

1. **检查 Gradle 配置**
   ```bash
   cd android
   ./gradlew clean
   ```

2. **检查签名配置**
   - 确保 `android/app/frame.jks` 存在
   - 检查签名密码是否正确

## 最佳实践

1. **提交前检查**
   - 运行 `flutter analyze` 确保没有错误
   - 运行 `flutter test` 确保测试通过
   - 检查代码格式：`dart format .`

2. **版本管理**
   - 使用语义化版本号（Semantic Versioning）
   - 版本号格式：`主版本.次版本.修订版本+构建号`
   - 示例：`1.0.1+123`

3. **分支策略**
   - `main`: 生产环境代码
   - `develop`: 开发环境代码
   - 功能分支：`feature/*`
   - 修复分支：`fix/*`

4. **Pull Request**
   - 确保 CI 检查通过
   - 添加适当的描述和标签
   - 请求代码审查

5. **发布流程**
   - 在 `main` 分支上创建版本标签
   - 使用 `v*.*.*` 格式的标签
   - 检查构建产物是否正确
   - 验证应用功能

## 蒲公英上传

### 本地使用

**方式1: 使用环境变量**
```bash
# 设置蒲公英 API Key（注意：等号两边不能有空格）
export PGYER_API_KEY=your_api_key

# 可选：设置安装密码
export PGYER_PASSWORD=your_password

# 执行上传脚本
chmod +x scripts/build-and-upload-pgyer.sh
./scripts/build-and-upload-pgyer.sh prod "修复了若干bug"
```

**方式2: 使用配置文件（推荐）**
```bash
# 1. 创建配置文件
cp .pgyer_config.example .pgyer_config

# 2. 编辑 .pgyer_config，填入你的 API Key
# PGYER_API_KEY=your_api_key
# PGYER_PASSWORD=your_password  # 可选

# 3. 直接运行脚本（会自动读取配置文件）
chmod +x scripts/build-and-upload-pgyer.sh
./scripts/build-and-upload-pgyer.sh prod "修复了若干bug"
```

**方式3: 脚本中已配置**
- 脚本中已包含默认 API Key，可直接运行
- 如需修改，建议使用配置文件方式

### GitHub Actions 使用

1. **配置 Secrets**
   - 进入 GitHub 仓库 Settings → Secrets
   - 添加 `PGYER_API_KEY`（必需）
   - 可选：添加 `PGYER_PASSWORD`（安装密码）

2. **手动触发**
   - 进入 Actions → "Build and Upload to Pgyer"
   - 点击 "Run workflow"
   - 选择环境、填写更新说明、设置密码（可选）

3. **自动触发**
   - 推送到 `main` 分支时自动触发
   - 自动构建并上传到蒲公英

### 获取蒲公英 API Key

1. 登录 [蒲公英官网](https://www.pgyer.com/)
2. 进入 "账号设置" → "API 信息"
3. 复制 API Key

### 上传脚本参数

```bash
./scripts/build-and-upload-pgyer.sh [环境] [更新说明]
```

- **环境**: `dev` / `test` / `prod`（默认：prod）
- **更新说明**: 本次更新的描述信息

### 上传结果

上传成功后会显示：
- 应用名称和版本号
- 下载链接
- 二维码链接
- 安装密码（如果设置）
- 信息保存到 `build/pgyer-info.txt`

## 扩展功能

### 添加新的检查步骤

在 `.github/workflows/ci.yml` 中添加新的 job：

```yaml
jobs:
  custom-check:
    name: Custom Check
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run custom check
        run: |
          # 你的检查命令
```

### 集成其他服务

- **Firebase App Distribution**: 自动分发到测试用户
- **Fastlane**: 自动化 iOS 和 Android 发布
- **Slack/Teams 通知**: 构建状态通知
- **蒲公英**: 国内 Android 应用内测分发（已配置）

## 相关文档

- [GitHub Actions 文档](https://docs.github.com/en/actions)
- [Flutter CI/CD 最佳实践](https://docs.flutter.dev/deployment/cd)
- [环境配置指南](./ENVIRONMENT_CONFIG_GUIDE.md)
