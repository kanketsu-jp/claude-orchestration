#!/bin/bash

# 部下からPMへ直接メッセージを送信するスクリプト
# Usage: ./notify-pm.sh "メッセージ" [エージェント名]

MESSAGE="$1"
AGENT_NAME="${2:-Agent}"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# プロジェクト名を取得（親ディレクトリから）
PROJECT_NAME=$(basename $(dirname $(pwd)))
if [ "$PROJECT_NAME" == ".claude-orchestration" ]; then
    PROJECT_NAME=$(basename $(dirname $(dirname $(pwd))))
fi

# セッション情報の取得
PM_SESSION=$(cat /tmp/${PROJECT_NAME}-session-name.txt 2>/dev/null || tmux list-sessions | grep "ceo-${PROJECT_NAME}" | cut -d: -f1 | head -1)

if [ -z "$PM_SESSION" ]; then
    echo "❌ エラー: PMのセッションが見つかりません"
    echo "利用可能なセッション:"
    tmux list-sessions
    exit 1
fi

if [ -z "$MESSAGE" ]; then
    echo "使い方: ./notify-pm.sh \"メッセージ\" [エージェント名]"
    exit 1
fi

# PMのClaude Codeに直接メッセージを送信
echo "📨 PMへメッセージを送信中..."

# まず改行を送信して新しい行を確保
tmux send-keys -t "$PM_SESSION:0.0" Enter

# メッセージを送信（部下からの報告として明確に）
tmux send-keys -t "$PM_SESSION:0.0" "# 🔔 部下からの報告 [$TIMESTAMP]" Enter
tmux send-keys -t "$PM_SESSION:0.0" "# $AGENT_NAME: $MESSAGE" Enter
tmux send-keys -t "$PM_SESSION:0.0" Enter

# 通知ファイルにも記録
NOTIFY_FILE="/tmp/${PROJECT_NAME}-pm-notifications.txt"
echo "[$TIMESTAMP] $AGENT_NAME: $MESSAGE" >> "$NOTIFY_FILE"

echo "✅ メッセージ送信完了！"
echo "送信内容: $MESSAGE"
echo "送信先: $PM_SESSION"