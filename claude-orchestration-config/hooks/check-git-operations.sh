#!/bin/bash

# Git操作を検出してブランチ戦略を確認するフック

COMMAND="${CLAUDE_TOOL_COMMAND}"
PROJECT_DIR="${CLAUDE_WORKING_DIRECTORY}"

# ブランチ作成コマンドの検出
if echo "$COMMAND" | grep -E "git checkout -b|git branch" > /dev/null; then
    cd "$PROJECT_DIR" 2>/dev/null || exit 0
    
    # 現在のブランチを確認
    CURRENT_BRANCH=$(git branch --show-current 2>/dev/null)
    
    # 推奨ベースブランチの確認
    if git show-ref --verify --quiet refs/heads/dev-HoriikeKazuma; then
        RECOMMENDED_BASE="dev-HoriikeKazuma"
    elif git show-ref --verify --quiet refs/heads/dev; then
        RECOMMENDED_BASE="dev"
    else
        RECOMMENDED_BASE="main"
    fi
    
    # 新しいブランチ名がdev-Horiike-*パターンに従っているか確認
    if echo "$COMMAND" | grep -E "dev-Horiike-" > /dev/null; then
        echo "[Git Hook] 正しいブランチ命名規則に従っています" >&2
    else
        echo "[Git Hook] 注意: ブランチ名は 'dev-Horiike-{タスクID}' 形式を推奨します" >&2
    fi
    
    echo "[Git Hook] 推奨ベースブランチ: $RECOMMENDED_BASE" >&2
fi

# マージリクエスト作成の検出
if echo "$COMMAND" | grep -E "gh pr create|glab mr create" > /dev/null; then
    cd "$PROJECT_DIR" 2>/dev/null || exit 0
    
    CURRENT_BRANCH=$(git branch --show-current 2>/dev/null)
    
    # TMUXセッション情報があれば通知
    SESSION_FILE="$PROJECT_DIR/.claude-orchestration/current-tmux-session.txt"
    if [ -f "$SESSION_FILE" ]; then
        SESSION_NAME=$(cat "$SESSION_FILE")
        echo "[Git Hook] MR/PR作成を検出しました (Branch: $CURRENT_BRANCH)" >&2
        echo "[Git Hook] 上司への通知: tmux send-keys -t '$SESSION_NAME:0.0' 'PR作成: $CURRENT_BRANCH' Enter" >&2
    fi
fi