#!/bin/bash

# エージェント用ヘルパー関数
# source .claude/tmux-org/agent-helper.sh で読み込む

# ブランチ作成関数
create_work_branch() {
    local TASK_ID=$1
    
    if [ -z "$TASK_ID" ]; then
        echo "使用方法: create_work_branch <TASK_ID>"
        return 1
    fi
    
    # ベースブランチを探す
    if git show-ref --verify --quiet refs/heads/dev-HoriikeKazuma; then
        BASE_BRANCH="dev-HoriikeKazuma"
    elif git show-ref --verify --quiet refs/heads/dev; then
        BASE_BRANCH="dev"
    else
        BASE_BRANCH="main"
    fi
    
    # 新しいブランチ名
    NEW_BRANCH="dev-Horiike-${TASK_ID}"
    
    # ブランチ作成
    git checkout -b "$NEW_BRANCH" "$BASE_BRANCH"
    
    echo "ブランチ '$NEW_BRANCH' を '$BASE_BRANCH' から作成しました"
}

# マージリクエスト作成関数
create_merge_request() {
    local TITLE=$1
    local DESCRIPTION=$2
    
    if [ -z "$TITLE" ]; then
        echo "使用方法: create_merge_request \"<TITLE>\" [\"<DESCRIPTION>\"]"
        return 1
    fi
    
    # 現在のブランチ名を取得
    CURRENT_BRANCH=$(git branch --show-current)
    
    # GitHubの場合
    if command -v gh &> /dev/null; then
        if [ -n "$DESCRIPTION" ]; then
            gh pr create --title "$TITLE" --body "$DESCRIPTION"
        else
            gh pr create --title "$TITLE"
        fi
    # GitLabの場合（glab CLIが必要）
    elif command -v glab &> /dev/null; then
        if [ -n "$DESCRIPTION" ]; then
            glab mr create --title "$TITLE" --description "$DESCRIPTION"
        else
            glab mr create --title "$TITLE"
        fi
    else
        echo "エラー: GitHub CLI (gh) またはGitLab CLI (glab) がインストールされていません"
        return 1
    fi
}

# ブランチクリーンアップ関数
cleanup_branch() {
    local BRANCH_NAME=$1
    
    if [ -z "$BRANCH_NAME" ]; then
        BRANCH_NAME=$(git branch --show-current)
    fi
    
    # mainブランチに戻る
    git checkout main
    
    # ローカルブランチを削除
    git branch -d "$BRANCH_NAME"
    
    echo "ブランチ '$BRANCH_NAME' を削除しました"
}