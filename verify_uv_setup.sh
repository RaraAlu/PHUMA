#!/bin/bash
# PHUMA UV Installation Verification Script
# This script verifies that UV is properly configured and working

echo "🔍 PHUMA UV 安装验证脚本"
echo "================================"
echo ""

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check counter
PASSED=0
FAILED=0

# Function to check command
check_command() {
    if command -v $1 &> /dev/null; then
        echo -e "${GREEN}✓${NC} $1 is installed"
        ((PASSED++))
        return 0
    else
        echo -e "${RED}✗${NC} $1 is NOT installed"
        ((FAILED++))
        return 1
    fi
}

# Function to check file
check_file() {
    if [ -f "$1" ]; then
        echo -e "${GREEN}✓${NC} $1 exists"
        ((PASSED++))
        return 0
    else
        echo -e "${RED}✗${NC} $1 NOT found"
        ((FAILED++))
        return 1
    fi
}

echo "📦 检查必要工具..."
echo "---"

# Check Python
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version 2>&1 | awk '{print $2}')
    echo -e "${GREEN}✓${NC} Python3 is installed: $PYTHON_VERSION"
    ((PASSED++))
else
    echo -e "${RED}✗${NC} Python3 is NOT installed"
    ((FAILED++))
fi

# Check pip
check_command pip || check_command pip3

# Check UV
if command -v uv &> /dev/null || python3 -m uv --version &> /dev/null 2>&1; then
    UV_VERSION=$(python3 -m uv --version 2>&1 || uv --version 2>&1)
    echo -e "${GREEN}✓${NC} UV is installed: $UV_VERSION"
    ((PASSED++))
else
    echo -e "${RED}✗${NC} UV is NOT installed"
    echo -e "${YELLOW}   Fix: pip install uv${NC}"
    ((FAILED++))
fi

echo ""
echo "📄 检查配置文件..."
echo "---"

# Check configuration files
check_file "pyproject.toml"
check_file "setup_uv.sh"
check_file "UV_SETUP_GUIDE.md"
check_file "UV_MIGRATION_SUMMARY.md"
check_file "UV_QUICK_REF.md"
check_file "README.md"

echo ""
echo "🗂️  检查项目结构..."
echo "---"

# Check directories
for dir in "src" "asset" "data"; do
    if [ -d "$dir" ]; then
        echo -e "${GREEN}✓${NC} $dir/ directory exists"
        ((PASSED++))
    else
        echo -e "${YELLOW}⚠${NC} $dir/ directory NOT found (may be expected)"
    fi
done

# Check if setup_uv.sh is executable
if [ -x "setup_uv.sh" ]; then
    echo -e "${GREEN}✓${NC} setup_uv.sh is executable"
    ((PASSED++))
else
    echo -e "${YELLOW}⚠${NC} setup_uv.sh is not executable"
    echo -e "${YELLOW}   Fix: chmod +x setup_uv.sh${NC}"
fi

echo ""
echo "📊 测试 UV 功能..."
echo "---"

# Test UV venv creation
if python3 -m uv venv --help &> /dev/null; then
    echo -e "${GREEN}✓${NC} UV venv command works"
    ((PASSED++))
else
    echo -e "${RED}✗${NC} UV venv command failed"
    ((FAILED++))
fi

# Test UV pip
if python3 -m uv pip --help &> /dev/null; then
    echo -e "${GREEN}✓${NC} UV pip command works"
    ((PASSED++))
else
    echo -e "${RED}✗${NC} UV pip command failed"
    ((FAILED++))
fi

echo ""
echo "================================"
echo "📈 验证结果"
echo "================================"
echo -e "${GREEN}通过: $PASSED${NC}"
echo -e "${RED}失败: $FAILED${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}🎉 所有检查通过! UV 配置正确。${NC}"
    echo ""
    echo "下一步:"
    echo "  1. 运行安装脚本: ./setup_uv.sh"
    echo "  2. 激活环境: source .venv/bin/activate"
    echo "  3. 查看文档: cat UV_QUICK_REF.md"
    exit 0
else
    echo -e "${RED}⚠️  发现 $FAILED 个问题,请检查上述错误。${NC}"
    echo ""
    echo "常见修复方法:"
    echo "  - 安装 UV: pip install uv"
    echo "  - 设置脚本权限: chmod +x setup_uv.sh"
    echo "  - 查看详细指南: cat UV_SETUP_GUIDE.md"
    exit 1
fi
