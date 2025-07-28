#!/bin/bash

# エージェント（部下）のタスク完了時に実行されるフック

PROJECT_DIR="${CLAUDE_WORKING_DIRECTORY}"
AGENT_NAME="${CLAUDE_AGENT_NAME:-Agent}"
TASK_ID="${CLAUDE_TASK_ID}"

# TMUXセッション情報を確認
SESSION_FILE="$PROJECT_DIR/.claude-orchestration/current-tmux-session.txt"
if [ ! -f "$SESSION_FILE" ]; then
    exit 0
fi

SESSION_NAME=$(cat "$SESSION_FILE")
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

# タスク完了通知メッセージ
if [ -n "$TASK_ID" ]; then
    MESSAGE="[$TIMESTAMP] $AGENT_NAME: タスク #$TASK_ID が完了しました"
else
    MESSAGE="[$TIMESTAMP] $AGENT_NAME: サブタスクが完了しました"
fi

# 現在のブランチ情報を取得
cd "$PROJECT_DIR" 2>/dev/null
CURRENT_BRANCH=$(git branch --show-current 2>/dev/null)
if [ -n "$CURRENT_BRANCH" ] && [ "$CURRENT_BRANCH" != "main" ]; then
    MESSAGE="$MESSAGE (Branch: $CURRENT_BRANCH)"
fi

# 上司のペインに通知
tmux send-keys -t "$SESSION_NAME:0.0" "$MESSAGE" Enter 2>/dev/null

# 完了タスクのサマリーを生成
SUMMARY_FILE="$PROJECT_DIR/.claude-orchestration/task-summary.md"
mkdir -p "$PROJECT_DIR/.claude-orchestration"
cat >> "$SUMMARY_FILE" << EOF

## $TIMESTAMP - $AGENT_NAME
- タスク: ${TASK_ID:-"サブタスク"}
- ブランチ: ${CURRENT_BRANCH:-"N/A"}
- ステータス: 完了

EOF

echo "[Agent Hook] タスク完了を記録しました" >&2