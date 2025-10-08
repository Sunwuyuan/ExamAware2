# 发布指南

本文档介绍如何发布 ExamAware 的 npm 包。

## 可发布的包

- **@examaware/core** - 核心库，提供考试配置解析、验证和时间处理等核心功能
- **@examaware/player** - 考试播放器组件，提供考试显示和管理的核心逻辑

## 前置准备

### 1. npm 账号和权限

确保你有 npm 账号并且有权限发布 `@examaware` scope 下的包：

```bash
# 登录 npm
npm login

# 验证登录状态
npm whoami
```

### 2. GitHub Secrets 配置

在 GitHub 仓库设置中添加 npm token：

1. 在 npm 创建访问令牌：
   - 访问 https://www.npmjs.com/settings/YOUR_USERNAME/tokens
   - 点击 "Generate New Token" → "Classic Token"
   - 选择 "Automation" 类型（用于 CI/CD）
   - 复制生成的 token

2. 在 GitHub 添加 Secret：
   - 访问仓库的 Settings → Secrets and variables → Actions
   - 点击 "New repository secret"
   - Name: `NPM_TOKEN`
   - Value: 粘贴你的 npm token
   - 点击 "Add secret"

## 发布方法

### 方法一：使用自动化脚本（推荐）

项目提供了 `bump-version.sh` 脚本来简化版本管理：

```bash
# 更新 @examaware/core 的补丁版本
./scripts/bump-version.sh --package core patch

# 更新 @examaware/player 的次要版本
./scripts/bump-version.sh --package player minor

# 同时更新所有包的主要版本
./scripts/bump-version.sh --package all major
```

脚本会自动完成：
1. ✅ 更新 package.json 中的版本号
2. ✅ 提交版本更改
3. ✅ 创建 git 标签

然后按照脚本提示推送更改：

```bash
# 推送代码
git push origin main

# 推送标签（触发自动发布）
git push origin <tag-name>
```

### 方法二：手动发布

#### 1. 更新版本号

```bash
# 进入包目录
cd packages/core  # 或 packages/player

# 更新版本号
npm version patch  # 或 minor/major

# 返回根目录
cd ../..
```

#### 2. 提交并创建标签

```bash
# 提交版本更改
git add packages/*/package.json
git commit -m "chore(core): bump version to x.x.x"

# 创建标签
git tag @examaware/core@x.x.x

# 推送到 GitHub
git push origin main
git push origin @examaware/core@x.x.x
```

### 方法三：使用 GitHub Actions 手动触发

1. 访问 Actions 页面
2. 选择 "发布 NPM 包" 工作流
3. 点击 "Run workflow"
4. 选择要发布的包和版本类型
5. 点击 "Run workflow" 开始发布

> ⚠️ 注意：使用此方法前需要确保 package.json 中的版本号已经更新

## 版本管理规范

遵循 [语义化版本（Semantic Versioning）](https://semver.org/lang/zh-CN/)：

- **主版本号（MAJOR）**：不兼容的 API 修改
- **次版本号（MINOR）**：向下兼容的功能性新增
- **修订号（PATCH）**：向下兼容的问题修正

### 示例

- `1.0.0` → `1.0.1`：修复 bug（patch）
- `1.0.1` → `1.1.0`：添加新功能（minor）
- `1.1.0` → `2.0.0`：破坏性更改（major）

## 发布流程

### 完整发布流程

```bash
# 1. 确保代码最新
git checkout main
git pull origin main

# 2. 确保所有包都能正常构建
pnpm install
pnpm --filter @examaware/core build
pnpm --filter @examaware/player build

# 3. 运行测试和检查
pnpm --filter @examaware/core type-check
pnpm --filter @examaware/core lint
pnpm --filter @examaware/player type-check
pnpm --filter @examaware/player lint

# 4. 使用脚本更新版本
./scripts/bump-version.sh --package core patch

# 5. 推送更改（触发自动发布）
git push origin main
git push origin @examaware/core@x.x.x
```

### 同时发布多个包

当 core 和 player 都有更新时：

```bash
# 使用脚本同时更新
./scripts/bump-version.sh --package all patch

# 推送更改
git push origin main
git push origin vx.x.x
```

## 自动化工作流

### 触发条件

GitHub Actions 会在以下情况自动构建和发布：

1. **推送版本标签**：
   - `v*.*.*` - 发布所有包
   - `@examaware/core@*.*.*` - 仅发布 core
   - `@examaware/player@*.*.*` - 仅发布 player

2. **手动触发**：在 Actions 页面手动运行工作流

### 工作流步骤

1. ✅ 检出代码
2. ✅ 设置 Node.js 和 pnpm
3. ✅ 安装依赖
4. ✅ 类型检查
5. ✅ 代码检查（lint）
6. ✅ 构建包
7. ✅ 发布到 npm（包含 provenance）

## 验证发布

发布成功后，验证包是否可用：

```bash
# 查看最新版本
npm view @examaware/core version
npm view @examaware/player version

# 测试安装
npm install @examaware/core
npm install @examaware/player
```

## 回滚发布

如果发现发布的版本有问题：

```bash
# 使用 npm deprecate 标记版本为废弃
npm deprecate @examaware/core@x.x.x "This version has critical bugs, please upgrade to x.x.y"

# 发布修复版本
./scripts/bump-version.sh --package core patch
git push origin main
git push origin @examaware/core@x.x.y
```

> ⚠️ 注意：npm 不允许删除已发布的包版本（发布后 72 小时内除外），只能标记为废弃。

## 常见问题

### 1. 发布失败：401 Unauthorized

**原因**：npm token 无效或过期

**解决方法**：
- 在 npm 生成新的 token
- 在 GitHub 更新 `NPM_TOKEN` secret

### 2. 发布失败：403 Forbidden

**原因**：没有发布权限

**解决方法**：
- 确认你是 `@examaware` organization 的成员
- 确认你有发布权限

### 3. 发布失败：版本已存在

**原因**：尝试发布已存在的版本号

**解决方法**：
- 检查 npm 上的当前版本：`npm view @examaware/core version`
- 更新到新的版本号后重新发布

### 4. 构建失败：类型错误

**解决方法**：
```bash
# 在本地运行类型检查
pnpm --filter @examaware/core type-check
pnpm --filter @examaware/player type-check

# 修复类型错误后重新提交
```

### 5. 包导入失败

**原因**：构建产物不正确或缺失

**解决方法**：
```bash
# 本地测试构建
cd packages/core
pnpm build
ls -la dist/

# 检查是否存在以下文件：
# - dist/index.js (CJS)
# - dist/index.mjs (ESM)
# - dist/index.d.ts (类型定义)
```

## 最佳实践

### 发布前检查清单

- [ ] 代码已经过 code review
- [ ] 所有测试通过
- [ ] 类型检查通过
- [ ] 代码格式检查通过
- [ ] 本地构建成功
- [ ] 版本号已更新
- [ ] CHANGELOG 已更新（如果有）
- [ ] README 已更新（如果有 API 变更）

### 版本号管理

- 始终使用 `npm version` 命令更新版本号
- 不要手动编辑 package.json 中的版本号
- 每次发布都要更新版本号，不要重复发布相同版本

### 发布时机

- 在工作日发布，避免周末发布
- 避免在假期或下班时间发布
- 重要更新建议提前通知用户

### 安全性

- 不要在代码中包含敏感信息
- 定期更新 npm token
- 使用 provenance 增强包的可信度
- 启用 2FA 保护 npm 账号

## 相关链接

- [npm 文档](https://docs.npmjs.com/)
- [语义化版本规范](https://semver.org/lang/zh-CN/)
- [GitHub Actions 文档](https://docs.github.com/en/actions)
- [GitHub Actions 工作流说明](.github/workflows/README.md)
