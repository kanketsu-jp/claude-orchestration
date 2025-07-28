#!/bin/bash

# タスク完了時に上司（PM）に通知するフック

PROJECT_DIR="${CLAUDE_WORKING_DIRECTORY}"
AGENT_NAME="${CLAUDE_AGENT_NAME:-Agent}"

# TMUXセッション情報を確認
SESSION_FILE="$PROJECT_DIR/.claude-orchestration/current-tmux-session.txt"
if [ ! -f "$SESSION_FILE" ]; then
    exit 0
fi

SESSION_NAME=$(cat "$SESSION_FILE")

# タスク完了メッセージを生成
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
MESSAGE="[$TIMESTAMP] $AGENT_NAME: タスクが完了しました"

# 上司のペイン（0.0）に通知を送信
tmux send-keys -t "$SESSION_NAME:0.0" "$MESSAGE" Enter 2>/dev/null

# 通知ログを保存
LOG_FILE="$PROJECT_DIR/.claude-orchestration/task-completion.log"
mkdir -p "$PROJECT_DIR/.claude-orchestration"
echo "$MESSAGE" >> "$LOG_FILE"

echo "[Task Hook] タスク完了を上司に通知しました" >&2