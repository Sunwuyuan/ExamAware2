# NPM 包发布自动化 - 快速开始

## 🎯 概述

本项目已配置自动化 GitHub Actions 工作流，可以轻松地构建和发布 npm 包。

## 📦 可发布的包

| 包名 | 描述 | 状态 |
|------|------|------|
| `@examaware/core` | 考试配置核心库 | ✅ 可发布 |
| `@examaware/player` | 考试播放器组件 | ✅ 可发布 |
| `@examaware/web` | Web 应用 | ❌ 私有包 |
| `@examaware/desktop` | 桌面应用 | ❌ 私有包 |

## 🚀 快速开始

### 1️⃣ 配置 NPM Token（首次使用）

```bash
# 在 npm 网站创建 token
# 访问：https://www.npmjs.com/settings/<your-username>/tokens
# 创建 "Automation" 类型的 token

# 在 GitHub 添加 Secret
# Settings → Secrets and variables → Actions → New repository secret
# Name: NPM_TOKEN
# Value: <your-npm-token>
```

### 2️⃣ 发布新版本（三种方式）

#### 方式 A：使用自动化脚本 ⭐ 推荐

```bash
# 更新 core 包的补丁版本 (1.0.0 → 1.0.1)
./scripts/bump-version.sh --package core patch

# 更新 player 包的次要版本 (1.0.0 → 1.1.0)
./scripts/bump-version.sh --package player minor

# 同时更新所有包的主要版本 (1.0.0 → 2.0.0)
./scripts/bump-version.sh --package all major

# 然后推送（触发自动发布）
git push origin main
git push origin <tag-name>
```

#### 方式 B：手动标签发布

```bash
# 1. 更新版本号
cd packages/core
npm version patch  # 或 minor/major
cd ../..

# 2. 提交并创建标签
git add packages/core/package.json
git commit -m "chore(core): bump version"
git tag @examaware/core@1.0.1

# 3. 推送（触发自动发布）
git push origin main @examaware/core@1.0.1
```

#### 方式 C：GitHub Actions 手动触发

1. 访问 Actions 页面
2. 选择 "发布 NPM 包" 工作流
3. 点击 "Run workflow"
4. 选择包和版本类型
5. 点击 "Run workflow"

> ⚠️ 使用此方法前需先手动更新 package.json 中的版本号

## 📋 工作流程图

```
┌─────────────────────┐
│  开发者更新版本号    │
│  并推送标签         │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  GitHub Actions     │
│  自动触发           │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  安装依赖           │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  类型检查           │
│  代码检查 (可选)    │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  构建包             │
│  - @examaware/core  │
│  - @examaware/player│
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  发布到 npm         │
│  (包含 provenance)  │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  ✅ 发布成功        │
└─────────────────────┘
```

## 🔍 工作流说明

### 发布工作流 (`publish-packages.yml`)

**触发条件：**
- 推送标签：`v1.0.0`, `@examaware/core@1.0.0`, `@examaware/player@1.0.0`
- 手动触发

**执行步骤：**
1. ✅ 检出代码
2. ✅ 设置 pnpm 10.15.0
3. ✅ 设置 Node.js 20
4. ✅ 安装依赖（frozen lockfile）
5. ✅ 运行类型检查
6. ⚠️ 运行代码检查（允许失败）
7. ✅ 构建包
8. ✅ 发布到 npm（public + provenance）

### 构建测试工作流 (`build-packages.yml`)

**触发条件：**
- Pull Request 到 main/develop
- 推送到 main/develop
- 修改 packages/core 或 packages/player

**测试矩阵：**
- Node.js 18, 20, 22

**执行步骤：**
1. ✅ 多版本环境测试
2. ✅ 类型检查
3. ⚠️ 代码检查（允许失败）
4. ✅ 构建验证
5. ✅ 导入测试（CJS & ESM）
6. ✅ 上传构建产物

## 📚 详细文档

- [完整发布指南](./PUBLISHING.md) - 详细的发布流程和故障排除
- [工作流说明](./.github/workflows/README.md) - GitHub Actions 工作流详细说明

## 🔧 开发命令

```bash
# 安装依赖
pnpm install

# 构建单个包
pnpm --filter @examaware/core build
pnpm --filter @examaware/player build

# 类型检查
pnpm --filter @examaware/core type-check
pnpm --filter @examaware/player type-check

# 代码检查
pnpm --filter @examaware/core lint
pnpm --filter @examaware/player lint

# 清理构建产物
pnpm --filter @examaware/core clean
pnpm --filter @examaware/player clean
```

## 🎨 版本管理规范

遵循 [语义化版本 2.0.0](https://semver.org/lang/zh-CN/)：

| 版本类型 | 说明 | 示例 |
|---------|------|------|
| **MAJOR** | 不兼容的 API 修改 | 1.0.0 → 2.0.0 |
| **MINOR** | 向下兼容的功能性新增 | 1.0.0 → 1.1.0 |
| **PATCH** | 向下兼容的问题修正 | 1.0.0 → 1.0.1 |

## ❓ 常见问题

### Q: 如何查看当前发布的版本？

```bash
npm view @examaware/core version
npm view @examaware/player version
```

### Q: 发布失败了怎么办？

1. 检查 GitHub Actions 日志
2. 确认 `NPM_TOKEN` 配置正确
3. 确认版本号大于当前发布的版本
4. 查看 [PUBLISHING.md](./PUBLISHING.md) 的故障排除章节

### Q: 如何测试包是否正确？

```bash
# 本地测试构建
pnpm --filter @examaware/core build

# 检查构建产物
ls -la packages/core/dist/

# 测试导入
cd packages/core
node -e "console.log(require('./dist/index.js'))"
```

### Q: 能否只发布一个包？

可以！使用包特定的标签：
```bash
git tag @examaware/core@1.0.1
git push origin @examaware/core@1.0.1
```

## 🔐 安全最佳实践

- ✅ 使用 Automation token 而非 Personal Access Token
- ✅ 启用 npm 账号的 2FA（双因素认证）
- ✅ 定期轮换 npm token
- ✅ 不要在代码中包含敏感信息
- ✅ 使用 provenance 增强包的可信度（已配置）

## 📞 获取帮助

- 查看 [PUBLISHING.md](./PUBLISHING.md) 完整文档
- 查看 [GitHub Actions 日志](../../actions)
- 提交 Issue 获取支持

---

**祝发布顺利！** 🎉
