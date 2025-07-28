#!/bin/bash

# TMUXセッションとすべてのエージェントを削除するスクリプト

SESSION_FILE=".claude-orchestration/current-tmux-session.txt"

if [ ! -f "$SESSION_FILE" ]; then
    echo "エラー: TMUXセッションが見つかりません"
    exit 1
fi

SESSION_NAME=$(cat "$SESSION_FILE")

# 確認プロンプト
echo "セッション '$SESSION_NAME' とすべてのエージェントを削除します。"
echo -n "続行しますか？ (y/N): "
read -r CONFIRM

if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
    echo "キャンセルしました"
    exit 0
fi

# TMUXセッションを削除
tmux kill-session -t "$SESSION_NAME" 2>/dev/null

# Claude Codeプロセスを終了
pkill -f "ccl.*$SESSION_NAME" 2>/dev/null

# セッション情報を削除
rm -f "$SESSION_FILE"
rm -f ".claude-orchestration/tmux-commands.md"

echo "セッション '$SESSION_NAME' を削除しました"