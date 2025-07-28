#!/bin/bash

# 部下（エージェント）を作成するスクリプト
# 使用方法: ./create-agent.sh <AGENT_NAME> [TASK_ID]

AGENT_NAME=$1
TASK_ID=$2
SESSION_FILE=".claude-orchestration/current-tmux-session.txt"

if [ -z "$AGENT_NAME" ]; then
    echo "使用方法: $0 <AGENT_NAME> [TASK_ID]"
    exit 1
fi

if [ ! -f "$SESSION_FILE" ]; then
    echo "エラー: TMUXセッションが見つかりません"
    echo "先に ./start-organization.sh を実行してください"
    exit 1
fi

SESSION_NAME=$(cat "$SESSION_FILE")

# 新しいペインを作成（右側に分割）
PANE_ID=$(tmux split-window -t "$SESSION_NAME:0" -h -p 50 -P -F "#{pane_id}")

# Claude Codeを起動
tmux send-keys -t "$PANE_ID" "ccl" Enter
sleep 2

# エージェント識別情報を送信
if [ -n "$TASK_ID" ]; then
    PROMPT="あなたは部下エージェント '$AGENT_NAME' です。タスク #$TASK_ID を担当してください。"
else
    PROMPT="あなたは部下エージェント '$AGENT_NAME' です。上司からの指示を待ってください。"
fi

# ブランチ戦略の説明を追加
PROMPT="$PROMPT 作業時は dev-HoriikeKazuma, dev, main の順でベースブランチを探し、dev-Horiike-{タスク識別子} 形式でブランチを作成してください。"

tmux send-keys -t "$PANE_ID" "$PROMPT" Enter
tmux send-keys -t "$PANE_ID" "" Enter  # 空のEnterで確実に送信

echo "エージェント '$AGENT_NAME' を作成しました (Pane: $PANE_ID)"

# レイアウトを調整
tmux select-layout -t "$SESSION_NAME:0" tiled