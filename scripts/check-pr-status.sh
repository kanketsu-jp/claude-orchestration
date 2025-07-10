#!/bin/bash

# PR状態を定期的にチェックしてPMに通知するスクリプト
# Usage: ./check-pr-status.sh [interval-seconds]

INTERVAL="${1:-30}"  # デフォルト30秒ごと
PROJECT_DIR="$(dirname $(dirname $(pwd)))"
PROJECT_NAME=$(basename "$PROJECT_DIR")
LAST_PR_FILE="/tmp/${PROJECT_NAME}-last-pr.txt"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# 初回実行時は現在のPR数を記録
if [ ! -f "$LAST_PR_FILE" ]; then
    gh pr list --state open | wc -l > "$LAST_PR_FILE"
fi

echo "📊 PR監視を開始します（${INTERVAL}秒ごと）"
echo "プロジェクト: $PROJECT_NAME"
echo "終了: Ctrl+C"

while true; do
    # 現在のオープンPR一覧を取得
    CURRENT_PRS=$(gh pr list --state open)
    CURRENT_COUNT=$(echo "$CURRENT_PRS" | wc -l | tr -d ' ')
    LAST_COUNT=$(cat "$LAST_PR_FILE" 2>/dev/null || echo "0")
    
    # 新しいPRが作成された場合
    if [ "$CURRENT_COUNT" -gt "$LAST_COUNT" ]; then
        NEW_PR=$(echo "$CURRENT_PRS" | head -1)
        PR_NUMBER=$(echo "$NEW_PR" | awk '{print $1}')
        PR_TITLE=$(echo "$NEW_PR" | awk '{$1=""; print $0}' | xargs)
        
        echo "🎉 新しいPRを検出: #$PR_NUMBER - $PR_TITLE"
        
        # PMに通知
        "$SCRIPT_DIR/notify-pm.sh" "PR #$PR_NUMBER が作成されました: $PR_TITLE" "PR-Monitor"
    fi
    
    # 現在のPR数を保存
    echo "$CURRENT_COUNT" > "$LAST_PR_FILE"
    
    sleep "$INTERVAL"
done