#!/bin/bash
# 部下がCEOに通知を送るためのスクリプト

# プロジェクト名を取得
PROJECT_NAME=$(basename $(dirname $(dirname $(pwd))))
NOTIFY_FILE="/tmp/${PROJECT_NAME}-ceo-notifications.txt"

# 通知メッセージ
MESSAGE="$@"

if [ -z "$MESSAGE" ]; then
    echo "使い方: $0 <通知メッセージ>"
    echo "例: $0 'Issue #34のUI実装が完了しました'"
    exit 1
fi

# エージェントタイプを現在のブランチから推測
BRANCH=$(git branch --show-current)
AGENT_TYPE=$(echo $BRANCH | sed -E 's/issue-[0-9]+-//')

# 通知を送信
echo "[$(date +%H:%M:%S)] Agent-$AGENT_TYPE: $MESSAGE" >> "$NOTIFY_FILE"

echo "✅ CEOに通知を送信しました: $MESSAGE"