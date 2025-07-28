#!/bin/bash

# セッション終了時の自動クリーンアップフック

PROJECT_DIR="${CLAUDE_WORKING_DIRECTORY}"

# TMUXセッション情報を確認
SESSION_FILE="$PROJECT_DIR/.claude-orchestration/current-tmux-session.txt"
if [ ! -f "$SESSION_FILE" ]; then
    exit 0
fi

SESSION_NAME=$(cat "$SESSION_FILE")

# セッションが存在しなくなっている場合はファイルをクリーンアップ
if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    rm -f "$SESSION_FILE"
    rm -f "$PROJECT_DIR/.claude-orchestration/tmux-commands.md"
    echo "[Cleanup Hook] セッション '$SESSION_NAME' のクリーンアップを実行しました" >&2
fi

# 一時的なログファイルのローテーション（30日以上古いものを削除）
find "$PROJECT_DIR/.claude-orchestration" -name "*.log" -mtime +30 -delete 2>/dev/null

echo "[Cleanup Hook] セッションクリーンアップチェック完了" >&2