#!/bin/bash

# 部下に指示を送るスクリプト
# 使用方法: ./send-to-agent.sh <PANE_INDEX> "<MESSAGE>"

PANE_INDEX=$1
MESSAGE=$2
SESSION_FILE=".claude-orchestration/current-tmux-session.txt"

if [ -z "$PANE_INDEX" ] || [ -z "$MESSAGE" ]; then
    echo "使用方法: $0 <PANE_INDEX> \"<MESSAGE>\""
    echo "例: $0 1 \"Issue #34のUIコンポーネントを実装してください\""
    exit 1
fi

if [ ! -f "$SESSION_FILE" ]; then
    echo "エラー: TMUXセッションが見つかりません"
    exit 1
fi

SESSION_NAME=$(cat "$SESSION_FILE")

# メッセージを送信
tmux send-keys -t "$SESSION_NAME:0.$PANE_INDEX" "$MESSAGE" Enter
tmux send-keys -t "$SESSION_NAME:0.$PANE_INDEX" "" Enter  # 空のEnterで確実に送信

echo "Pane $PANE_INDEX にメッセージを送信しました"