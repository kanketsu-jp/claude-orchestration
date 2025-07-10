# 部下（Agent）用ガイド

## PMへの報告方法

### タスク完了時の報告

PRを作成したら、必ず以下のコマンドでPMに報告してください：

```bash
# プロジェクトのルートディレクトリから
.claude-orchestration/scripts/notify-pm.sh "PR #47を作成しました。" "Agent-Backend"

# または、.claude-orchestrationディレクトリから
scripts/notify-pm.sh "タスクが完了しました。" "Agent-Frontend"
```

### 使い方
```bash
notify-pm.sh "メッセージ" "あなたの名前"
```

### 報告が必要なタイミング
1. **PR作成時**: 必須
2. **ブロッカー発生時**: 必須
3. **重要な決定が必要な時**: 必須
4. **タスク完了時**: 推奨
5. **進捗報告**: 任意

### 例
```bash
# PR作成の報告
.claude-orchestration/scripts/notify-pm.sh "PR #48を作成しました。レビューをお願いします。" "Agent-Backend"

# ブロッカーの報告
.claude-orchestration/scripts/notify-pm.sh "エラーが発生しました。Supabaseの接続に失敗しています。" "Agent-Frontend"

# 進捗報告
.claude-orchestration/scripts/notify-pm.sh "認証フローの実装が50%完了しました。" "Agent-Auth"

# 質問・相談
.claude-orchestration/scripts/notify-pm.sh "データベース設計について相談があります。" "Agent-DB"
```

## 自動PR監視の起動

PMがPR作成を見逃さないように、自動監視を起動できます：

```bash
# 30秒ごとにPRをチェック（バックグラウンド実行）
.claude-orchestration/scripts/check-pr-status.sh 30 &
```

## 注意事項
- PMは`ceo-プロジェクト名-*`というセッションで作業しています
- メッセージは直接PMのClaude Codeに表示されます
- 重要な報告は必ず行ってください
- 通知履歴は `/tmp/プロジェクト名-pm-notifications.txt` に保存されます

## トラブルシューティング

### PMのセッションが見つからない場合
```bash
# 利用可能なセッションを確認
tmux list-sessions

# CEOで始まるセッションを探す
tmux list-sessions | grep ceo
```

### 通知が届かない場合
1. tmuxセッションが存在するか確認
2. PM（Claude Code）が起動しているか確認
3. 通知ファイルに記録されているか確認：
   ```bash
   cat /tmp/*-pm-notifications.txt
   ```