#!/usr/bin/env bash
set -euo pipefail

# stdinのJSONを全部読む
json="$(cat)"

# jqで必要な情報を抽出
cwd=$(echo "$json" | jq -r '.cwd // empty')
project_name=$(basename "$cwd")
timestamp=$(date "+%Y-%m-%d %H:%M:%S")

# TMUXセッション情報があれば取得
session_file="$cwd/.claude-orchestration/current-tmux-session.txt"
session_info=""
if [[ -f "$session_file" ]]; then
    session_name=$(cat "$session_file")
    session_info="TMUXセッション: $session_name"
fi

# タスクサマリーがあれば取得
summary_file="$cwd/.claude-orchestration/task-summary.md"
task_summary=""
if [[ -f "$summary_file" ]]; then
    # 最新の5エントリまでを取得
    task_summary=$(tail -n 20 "$summary_file" | head -n 15)
fi

# 最後のgitコミット情報を取得
last_commit=""
if [[ -d "$cwd/.git" ]]; then
    cd "$cwd"
    last_commit=$(git log -1 --oneline 2>/dev/null || echo "")
    if [[ -n "$last_commit" ]]; then
        last_commit="最新コミット: $last_commit"
    fi
fi

# 通知本文を組み立て
notification_body="タスク完了通知です

プロジェクト: $project_name
作業ディレクトリ: $cwd
完了時刻: $timestamp
$session_info
$last_commit

--- タスクサマリー ---
$task_summary"

# ntfyへ送信（改行を含む本文）
curl -H "Title: Claude Code [$project_name] タスク完了" \
     -d "$notification_body" \
     ntfy.sh/<topic-cca>

# セッション情報のクリーンアップ（必要に応じて）
# rm -f "$summary_file" 2>/dev/null || true