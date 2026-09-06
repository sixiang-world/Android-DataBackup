#!/bin/bash
# Android-DataBackup fork 一键推送脚本
# 使用方法：在本地克隆或下载本仓库后运行此脚本

set -e

REPO_URL="https://github.com/sixiang-world/Android-DataBackup.git"
BRANCH="main"

echo "=== Android-DataBackup Fork 推送脚本 ==="
echo ""

# 检查是否在 git 仓库中
if [ ! -d ".git" ]; then
    echo "错误：当前目录不是 git 仓库"
    exit 1
fi

# 配置 git 用户（如果未配置）
if ! git config user.email > /dev/null 2>&1; then
    read -p "请输入你的 Git 邮箱: " git_email
    git config user.email "$git_email"
fi
if ! git config user.name > /dev/null 2>&1; then
    read -p "请输入你的 Git 用户名: " git_name
    git config user.name "$git_name"
fi

# 添加远程仓库
if git remote get-url origin > /dev/null 2>&1; then
    echo "更新远程仓库地址..."
    git remote set-url origin "$REPO_URL"
else
    echo "添加远程仓库..."
    git remote add origin "$REPO_URL"
fi

echo ""
echo "远程仓库: $(git remote get-url origin)"
echo "当前分支: $(git branch --show-current)"
echo ""

# 确保所有变更已提交
if [ -n "$(git status --porcelain)" ]; then
    echo "检测到未提交的变更，正在提交..."
    git add -A
    git commit -m "sync: fork changes"
fi

# 推送到远程
echo "正在推送到 GitHub..."
git push -u origin "$BRANCH" --force

echo ""
echo "=== 推送完成 ==="
echo "仓库地址: $REPO_URL"
