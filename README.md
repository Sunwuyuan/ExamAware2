# ExamAware2

## NPM 包发布

本项目使用 GitHub Actions 自动化构建和发布 npm 包。

**快速开始：** 查看 [NPM 发布快速指南](./NPM_PUBLISHING_GUIDE.md)

**详细文档：** 查看 [完整发布指南](./PUBLISHING.md)

### 可发布的包

- **@examaware/core** - 考试配置核心库
- **@examaware/player** - 考试播放器组件

### 快速发布

```bash
# 使用自动化脚本
./scripts/bump-version.sh --package core patch
git push origin main
git push origin @examaware/core@x.x.x
```

更多信息请参考 [NPM_PUBLISHING_GUIDE.md](./NPM_PUBLISHING_GUIDE.md)。
