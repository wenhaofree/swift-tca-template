#!/bin/bash

# check-gitignore.sh
# 检查和验证 .gitignore 配置的脚本

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查是否在 git 仓库中
check_git_repo() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        print_error "当前目录不是 Git 仓库"
        exit 1
    fi
}

# 检查 .gitignore 文件是否存在
check_gitignore_exists() {
    if [ ! -f ".gitignore" ]; then
        print_error ".gitignore 文件不存在"
        exit 1
    fi
    print_success ".gitignore 文件存在"
}

# 检查常见的应该被忽略的文件
check_common_ignored_files() {
    print_status "检查常见的应该被忽略的文件..."
    
    local should_be_ignored=(
        ".DS_Store"
        "xcuserdata"
        ".build"
        ".swiftpm"
        "DerivedData"
        "build"
        "*.tmp"
        "*.log"
        "*.swp"
    )
    
    for pattern in "${should_be_ignored[@]}"; do
        # 创建临时测试文件
        local test_file="test_${pattern//\*/temp}"
        test_file="${test_file//\//_}"
        
        if [[ "$pattern" == *"*"* ]]; then
            # 处理通配符模式
            test_file="${test_file}.test"
        fi
        
        # 检查模式是否被忽略
        if git check-ignore "$test_file" > /dev/null 2>&1; then
            print_success "✓ $pattern 被正确忽略"
        else
            print_warning "⚠ $pattern 可能没有被忽略"
        fi
    done
}

# 检查是否有敏感文件被跟踪
check_sensitive_files() {
    print_status "检查敏感文件..."
    
    local sensitive_patterns=(
        "*.p12"
        "*.mobileprovision"
        "*secret*"
        "*key*"
        ".env"
        "AuthKey_*.p8"
        "GoogleService-Info.plist"
    )
    
    local found_sensitive=false
    
    for pattern in "${sensitive_patterns[@]}"; do
        if git ls-files | grep -i "$pattern" > /dev/null 2>&1; then
            print_error "发现可能的敏感文件被跟踪: $pattern"
            git ls-files | grep -i "$pattern"
            found_sensitive=true
        fi
    done
    
    if [ "$found_sensitive" = false ]; then
        print_success "没有发现被跟踪的敏感文件"
    fi
}

# 检查大文件
check_large_files() {
    print_status "检查大文件（>1MB）..."
    
    local large_files=$(git ls-files | xargs ls -la 2>/dev/null | awk '$5 > 1048576 {print $9, $5}')
    
    if [ -n "$large_files" ]; then
        print_warning "发现大文件:"
        echo "$large_files"
        print_warning "考虑使用 Git LFS 或将其添加到 .gitignore"
    else
        print_success "没有发现大文件"
    fi
}

# 显示当前被忽略的文件
show_ignored_files() {
    print_status "当前被忽略的文件和目录:"
    git status --ignored --porcelain | grep "^!!" | head -20
    
    local ignored_count=$(git status --ignored --porcelain | grep "^!!" | wc -l)
    print_status "总共有 $ignored_count 个文件/目录被忽略"
}

# 显示未跟踪的文件
show_untracked_files() {
    print_status "未跟踪的文件:"
    git status --porcelain | grep "^??" | head -10
    
    local untracked_count=$(git status --porcelain | grep "^??" | wc -l)
    if [ "$untracked_count" -gt 0 ]; then
        print_warning "有 $untracked_count 个未跟踪的文件"
        print_status "检查这些文件是否应该被添加到 .gitignore"
    else
        print_success "没有未跟踪的文件"
    fi
}

# 清理建议
suggest_cleanup() {
    print_status "清理建议:"
    
    # 检查是否有应该被移除的已跟踪文件
    local files_to_remove=(
        "xcuserdata"
        ".DS_Store"
        "build"
        "DerivedData"
    )
    
    for pattern in "${files_to_remove[@]}"; do
        if git ls-files | grep "$pattern" > /dev/null 2>&1; then
            print_warning "建议移除已跟踪的文件: $pattern"
            echo "  运行: git rm -r --cached \$(git ls-files | grep $pattern)"
        fi
    done
}

# 验证 .gitignore 语法
validate_gitignore_syntax() {
    print_status "验证 .gitignore 语法..."
    
    # 检查是否有重复的规则
    local duplicates=$(sort .gitignore | uniq -d)
    if [ -n "$duplicates" ]; then
        print_warning "发现重复的规则:"
        echo "$duplicates"
    else
        print_success ".gitignore 没有重复规则"
    fi
    
    # 检查是否有空行过多
    local empty_lines=$(grep -c "^$" .gitignore)
    if [ "$empty_lines" -gt 10 ]; then
        print_warning ".gitignore 中有 $empty_lines 个空行，考虑清理"
    fi
}

# 主函数
main() {
    echo "🔍 Git Ignore 配置检查工具"
    echo "================================"
    
    check_git_repo
    check_gitignore_exists
    
    echo ""
    check_common_ignored_files
    
    echo ""
    check_sensitive_files
    
    echo ""
    check_large_files
    
    echo ""
    validate_gitignore_syntax
    
    echo ""
    show_ignored_files
    
    echo ""
    show_untracked_files
    
    echo ""
    suggest_cleanup
    
    echo ""
    print_success "检查完成！"
    print_status "如需帮助，请查看 docs/gitignore-guide.md"
}

# 运行主函数
main "$@"
