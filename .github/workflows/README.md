# GitHub Actions 工作流说明

本目录包含用于自动化构建和发布 ExamAware 包的 GitHub Actions 工作流。

## 工作流列表

### 1. 发布 NPM 包 (`publish-packages.yml`)

自动构建并发布 `@examaware/core` 和 `@examaware/player` 到 npm。

#### 触发方式

1. **标签推送（自动触发）**
   ```bash
   # 发布所有包的新版本
   git tag v1.0.0
   git push origin v1.0.0
   
   # 或发布特定包
   git tag @examaware/core@1.0.0
   git push origin @examaware/core@1.0.0
   ```

2. **手动触发**
   - 在 GitHub Actions 页面选择 "发布 NPM 包" 工作流
   - 点击 "Run workflow"
   - 选择要发布的包（all/core/player）
   - 选择版本类型（patch/minor/major）

#### 前置要求

1. **设置 NPM Token**
   - 在 npm 创建访问令牌（Automation token 或 Publish token）
   - 在 GitHub 仓库设置中添加 Secret：`NPM_TOKEN`
   - Settings → Secrets and variables → Actions → New repository secret

2. **包版本管理**
   - 确保 `packages/core/package.json` 和 `packages/player/package.json` 中的版本号已更新
   - 使用 `npm version patch/minor/major` 更新版本号

#### 工作流程

1. ✅ 检出代码
2. ✅ 设置 pnpm 和 Node.js 环境
3. ✅ 安装依赖
4. ✅ 运行类型检查
5. ✅ 运行代码检查（lint）
6. ✅ 构建包
7. ✅ 发布到 npm（包含 provenance）

### 2. 构建和测试包 (`build-packages.yml`)

在 Pull Request 和推送到主分支时自动构建和测试包。

#### 触发方式

- 自动触发：
  - Pull Request 到 `main` 或 `develop` 分支
  - 推送到 `main` 或 `develop` 分支
  - 修改 `packages/core/` 或 `packages/player/` 目录

- 手动触发：
  - 在 GitHub Actions 页面选择 "构建和测试包" 工作流
  - 点击 "Run workflow"

#### 测试矩阵

- Node.js 版本：18, 20, 22
- 确保包在多个 Node.js 版本上正常工作

#### 工作流程

1. ✅ 检出代码
2. ✅ 设置多版本 Node.js 环境
3. ✅ 安装依赖
4. ✅ 运行类型检查
5. ✅ 运行代码检查
6. ✅ 构建所有包
7. ✅ 验证构建产物
8. ✅ 测试包导入（CJS 和 ESM）
9. ✅ 上传构建产物

## 发布流程示例

### 发布新版本

```bash
# 1. 确保在主分支且代码最新
git checkout main
git pull origin main

# 2. 更新包版本（以 core 为例）
cd packages/core
npm version patch  # 或 minor/major
cd ../..

# 3. 提交版本变更
git add packages/core/package.json
git commit -m "chore(core): bump version to x.x.x"
git push origin main

# 4. 创建并推送标签
git tag @examaware/core@x.x.x
git push origin @examaware/core@x.x.x

# 5. GitHub Actions 会自动构建并发布
```

### 同时发布多个包

```bash
# 1. 更新所有包版本
cd packages/core && npm version patch && cd ../..
cd packages/player && npm version patch && cd ../..

# 2. 提交版本变更
git add packages/*/package.json
git commit -m "chore: bump versions"
git push origin main

# 3. 创建统一版本标签
git tag v1.0.0
git push origin v1.0.0
```

## 常见问题

### 1. 发布失败：403 Forbidden

- 检查 `NPM_TOKEN` 是否正确配置
- 确认 npm 令牌有发布权限
- 检查包名是否已被占用

### 2. 构建失败：类型错误

- 在本地运行 `pnpm --filter @examaware/core type-check`
- 修复类型错误后再推送

### 3. 版本冲突

- 确保 package.json 中的版本号大于 npm 上已发布的版本
- 使用 `npm view @examaware/core version` 查看当前版本

## 最佳实践

1. **版本管理**
   - 遵循语义化版本（Semantic Versioning）
   - 使用 `npm version` 命令更新版本
   - 在 CHANGELOG.md 中记录变更

2. **发布前检查**
   - 确保所有测试通过
   - 本地构建并测试包
   - 检查包内容：`npm pack` 和 `tar -tzf *.tgz`

3. **安全性**
   - 不要将 npm token 提交到代码库
   - 定期更新 npm token
   - 使用 provenance 增强包的可信度

4. **自动化**
   - 使用标签触发自动发布
   - 在 PR 中自动运行构建测试
   - 保持 CI/CD 流程简洁高效
