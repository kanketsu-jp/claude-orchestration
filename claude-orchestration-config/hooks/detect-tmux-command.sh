#!/bin/bash

# TMUXコマンドを検出して自動的に適切なアクションを実行するフック

# 環境変数からプロンプトを取得
PROMPT="${CLAUDE_PROMPT}"
PROJECT_DIR="${CLAUDE_WORKING_DIRECTORY}"

# TMUXセッションファイルの存在確認
SESSION_FILE="$PROJECT_DIR/.claude-orchestration/current-tmux-session.txt"

# TMUXコマンドパターンの検出
if echo "$PROMPT" | grep -iE "tmux.*組織|組織.*開始|プロジェクト.*開始|start.*organization" > /dev/null; then
    # プロジェクトIDを抽出（数字またはアルファベット+数字の組み合わせ）
    PROJECT_ID=$(echo "$PROMPT" | grep -oE "[A-Za-z0-9]+-?[0-9]+" | head -1)
    
    if [ -n "$PROJECT_ID" ]; then
        echo "[TMUX Hook] プロジェクト '$PROJECT_ID' の組織化を検出しました" >&2
        
        # 既存セッションのチェック
        if [ -f "$SESSION_FILE" ]; then
            EXISTING_SESSION=$(cat "$SESSION_FILE")
            echo "[TMUX Hook] 既存のセッション '$EXISTING_SESSION' が存在します" >&2
        else
            echo "[TMUX Hook] 新しい組織の起動を推奨: .claude-orchestration/claude-orchestration-config/tmux-org/start-organization.sh $PROJECT_ID" >&2
        fi
    fi
fi

# 部下作成パターンの検出
if echo "$PROMPT" | grep -iE "部下.*作成|エージェント.*作成|create.*agent" > /dev/null; then
    if [ -f "$SESSION_FILE" ]; then
        echo "[TMUX Hook] 部下作成を検出しました。使用: .claude-orchestration/claude-orchestration-config/tmux-org/create-agent.sh <NAME> [TASK_ID]" >&2
    else
        echo "[TMUX Hook] TMUXセッションが開始されていません。先に組織を起動してください" >&2
    fi
fi

# 指示送信パターンの検出
if echo "$PROMPT" | grep -iE "指示.*送信|send.*instruction|部下.*に.*指示" > /dev/null; then
    if [ -f "$SESSION_FILE" ]; then
        echo "[TMUX Hook] 指示送信を検出しました。使用: .claude-orchestration/claude-orchestration-config/tmux-org/send-to-agent.sh <PANE> \"<MESSAGE>\"" >&2
    fi
fi