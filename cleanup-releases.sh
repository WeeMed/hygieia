#!/bin/bash

# GitHub Release 清理腳本
# 保留最新的 10 個版本，刪除其他舊版本

set -e

echo "🧹 開始清理 GitHub Releases..."

# 檢查 GitHub CLI 認證
if ! gh auth status > /dev/null 2>&1; then
    echo "❌ GitHub CLI 未認證，請先執行: gh auth login"
    exit 1
fi

# 獲取所有 release 標籤，按版本號排序（最新的在前）
echo "📋 獲取 release 列表..."
releases=$(gh api repos/:owner/:repo/releases --paginate | jq -r '.[].tag_name' | sort -V -r)

if [ -z "$releases" ]; then
    echo "ℹ️  沒有找到任何 releases"
    exit 0
fi

# 轉換為陣列
release_array=($releases)
total_count=${#release_array[@]}

echo "📊 找到 $total_count 個 releases"

# 保留最新的 10 個版本
KEEP_COUNT=10

if [ $total_count -le $KEEP_COUNT ]; then
    echo "✅ 版本數量 ($total_count) 未超過保留數量 ($KEEP_COUNT)，無需清理"
    exit 0
fi

echo "🗑️  將刪除 $((total_count - KEEP_COUNT)) 個舊版本..."
echo "🔒 保留最新的 $KEEP_COUNT 個版本:"

# 顯示要保留的版本
for i in $(seq 0 $((KEEP_COUNT - 1))); do
    if [ $i -lt $total_count ]; then
        echo "   - ${release_array[$i]}"
    fi
done

echo ""
echo "🗑️  將刪除的版本:"

# 顯示要刪除的版本
for i in $(seq $KEEP_COUNT $((total_count - 1))); do
    if [ $i -lt $total_count ]; then
        echo "   - ${release_array[$i]}"
    fi
done

echo ""
read -p "❓ 確定要刪除這些版本嗎？ (y/N): " confirm

if [[ $confirm != [yY] && $confirm != [yY][eE][sS] ]]; then
    echo "❌ 取消清理操作"
    exit 0
fi

echo ""
echo "🚀 開始刪除舊版本..."

# 刪除舊版本
deleted_count=0
for i in $(seq $KEEP_COUNT $((total_count - 1))); do
    if [ $i -lt $total_count ]; then
        tag=${release_array[$i]}
        echo "🗑️  刪除 $tag..."
        
        if gh release delete "$tag" --yes --cleanup-tag; then
            echo "   ✅ 已刪除 $tag"
            ((deleted_count++))
        else
            echo "   ❌ 刪除 $tag 失敗"
        fi
        
        # 避免 GitHub API 限制
        sleep 1
    fi
done

echo ""
echo "🎉 清理完成！"
echo "📊 總共刪除了 $deleted_count 個舊版本"
echo "🔒 保留了最新的 $KEEP_COUNT 個版本"

# 顯示剩餘的版本
echo ""
echo "📋 剩餘的 releases:"
gh api repos/:owner/:repo/releases | jq -r '.[].tag_name' | sort -V -r | head -15 