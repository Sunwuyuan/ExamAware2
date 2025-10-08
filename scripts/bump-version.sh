#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_info() {
    echo -e "${BLUE}ℹ ${1}${NC}"
}

print_success() {
    echo -e "${GREEN}✅ ${1}${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  ${1}${NC}"
}

print_error() {
    echo -e "${RED}❌ ${1}${NC}"
}

# 检查是否在 git 仓库中
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    print_error "不在 git 仓库中"
    exit 1
fi

# 检查是否有未提交的更改
if [[ -n $(git status --porcelain) ]]; then
    print_warning "存在未提交的更改，请先提交或暂存更改"
    git status --short
    exit 1
fi

# 显示帮助信息
show_help() {
    cat << EOF
使用方法: $0 [选项] <版本类型>

自动更新 ExamAware 包版本并创建标签

选项:
  -p, --package <name>  指定要更新的包 (core|player|all)
  -h, --help           显示此帮助信息

版本类型:
  patch    补丁版本 (x.x.X)
  minor    次要版本 (x.X.x)
  major    主要版本 (X.x.x)

示例:
  $0 --package core patch      # 更新 @examaware/core 的补丁版本
  $0 --package all minor       # 更新所有包的次要版本
  $0 -p player major           # 更新 @examaware/player 的主要版本

EOF
}

# 解析参数
PACKAGE=""
VERSION_TYPE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -p|--package)
            PACKAGE="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        patch|minor|major)
            VERSION_TYPE="$1"
            shift
            ;;
        *)
            print_error "未知参数: $1"
            show_help
            exit 1
            ;;
    esac
done

# 检查必需参数
if [[ -z "$PACKAGE" ]] || [[ -z "$VERSION_TYPE" ]]; then
    print_error "缺少必需参数"
    show_help
    exit 1
fi

# 验证包名
if [[ "$PACKAGE" != "core" ]] && [[ "$PACKAGE" != "player" ]] && [[ "$PACKAGE" != "all" ]]; then
    print_error "无效的包名: $PACKAGE (必须是 core, player 或 all)"
    exit 1
fi

# 更新包版本的函数
update_package_version() {
    local pkg_name=$1
    local pkg_path="packages/$pkg_name"
    
    if [[ ! -d "$pkg_path" ]]; then
        print_error "包目录不存在: $pkg_path"
        return 1
    fi
    
    print_info "更新 @examaware/$pkg_name 版本..."
    
    cd "$pkg_path" || return 1
    
    # 使用 npm version 更新版本
    local new_version
    new_version=$(npm version "$VERSION_TYPE" --no-git-tag-version 2>&1)
    
    if [[ $? -ne 0 ]]; then
        print_error "版本更新失败: $new_version"
        cd ../..
        return 1
    fi
    
    # 提取新版本号
    new_version=$(echo "$new_version" | sed 's/v//')
    
    print_success "@examaware/$pkg_name 版本已更新到 $new_version"
    
    cd ../..
    return 0
}

# 主执行逻辑
main() {
    print_info "开始版本更新流程..."
    
    # 更新包版本
    if [[ "$PACKAGE" == "all" ]]; then
        update_package_version "core" || exit 1
        update_package_version "player" || exit 1
    else
        update_package_version "$PACKAGE" || exit 1
    fi
    
    # 获取更新后的版本号
    local versions=""
    if [[ "$PACKAGE" == "all" ]]; then
        local core_version=$(node -p "require('./packages/core/package.json').version")
        local player_version=$(node -p "require('./packages/player/package.json').version")
        versions="core@$core_version, player@$player_version"
    else
        local version=$(node -p "require('./packages/$PACKAGE/package.json').version")
        versions="$PACKAGE@$version"
    fi
    
    # 添加并提交更改
    print_info "提交版本更改..."
    git add packages/*/package.json
    git commit -m "chore: bump version - $versions"
    
    if [[ $? -ne 0 ]]; then
        print_error "提交失败"
        exit 1
    fi
    
    print_success "版本更改已提交"
    
    # 创建标签
    print_info "创建 git 标签..."
    
    if [[ "$PACKAGE" == "all" ]]; then
        local core_version=$(node -p "require('./packages/core/package.json').version")
        git tag "v$core_version"
        print_success "标签已创建: v$core_version"
    else
        local version=$(node -p "require('./packages/$PACKAGE/package.json').version")
        git tag "@examaware/$PACKAGE@$version"
        print_success "标签已创建: @examaware/$PACKAGE@$version"
    fi
    
    # 显示下一步操作
    echo ""
    print_info "版本更新完成！"
    print_warning "请执行以下命令推送更改："
    echo ""
    echo "  git push origin main"
    if [[ "$PACKAGE" == "all" ]]; then
        local core_version=$(node -p "require('./packages/core/package.json').version")
        echo "  git push origin v$core_version"
    else
        local version=$(node -p "require('./packages/$PACKAGE/package.json').version")
        echo "  git push origin @examaware/$PACKAGE@$version"
    fi
    echo ""
    print_info "推送标签后，GitHub Actions 将自动构建并发布包到 npm"
}

# 执行主函数
main
