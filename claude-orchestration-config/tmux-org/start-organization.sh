#!/bin/bash

# プロジェクトIDベースのTMUX組織管理システム
# 使用方法: ./start-organization.sh <PROJECT_ID>

PROJECT_ID=$1
if [ -z "$PROJECT_ID" ]; then
    echo "使用方法: $0 <PROJECT_ID>"
    exit 1
fi

SESSION_NAME="project-${PROJECT_ID}"
WORK_DIR=$(pwd)

# セッションが既に存在するかチェック
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "セッション '$SESSION_NAME' は既に存在します"
    echo "アタッチする場合: tmux attach -t '$SESSION_NAME'"
    exit 1
fi

# TMUXセッションを作成
tmux new-session -d -s "$SESSION_NAME" -c "$WORK_DIR"

# 上司（PM）のペインでClaude Codeを起動
tmux send-keys -t "$SESSION_NAME:0.0" "ccl" Enter
sleep 2  # Claude Code起動待機

# 初期レイアウトを設定（上に上司、下に部下用スペース）
tmux split-window -t "$SESSION_NAME:0" -v -p 70
tmux select-pane -t "$SESSION_NAME:0.0"

# セッション情報を保存
mkdir -p "$WORK_DIR/.claude-orchestration"
echo "$SESSION_NAME" > "$WORK_DIR/.claude-orchestration/current-tmux-session.txt"

echo "TMUXセッション '$SESSION_NAME' を作成しました"
echo ""
echo "アクセス方法:"
echo "  tmux attach -t '$SESSION_NAME'"
echo ""
echo "外部からのアクセス:"
echo "  ssh user@host -t \"tmux attach -t '$SESSION_NAME'\""
echo ""

# .claude-orchestrationディレクトリに情報を記録
cat > "$WORK_DIR/.claude-orchestration/tmux-commands.md" << EOF
# TMUX Organization Commands for $PROJECT_ID

## セッションアクセス
\`\`\`bash
tmux attach -t "$SESSION_NAME"
\`\`\`

## 外部アクセス（VPN経由）
\`\`\`bash
ssh user@host -t "tmux attach -t '$SESSION_NAME'"
\`\`\`

## セッション削除
\`\`\`bash
tmux kill-session -t "$SESSION_NAME"
\`\`\`

## 作成日時: $(date)
EOF

echo "コマンド情報を .claude-orchestration/tmux-commands.md に保存しました"