# TMUX Organization System

プロジェクトIDベースのTMUXセッション管理システム

## 概要

このシステムはClaudeエージェントがTMUXを使用して上司-部下の組織を構築し、大規模タスクを並列処理するためのフレームワークです。

## 使用タイミング

- 単一エージェントでは対応困難な大規模イシュー
- 多数の小タスクを並列処理したい場合
- 複数の作業を同時進行で管理したい場合

## セッション管理

### プロジェクトセッション作成
```bash
# プロジェクトIDでセッション作成
tmux new-session -d -s "project-{PROJECT_ID}"
```

### アクセスコマンド

#### セッション一覧表示
```bash
tmux ls
```

#### セッションにアタッチ（分割画面を確認）
```bash
tmux attach -t "project-{PROJECT_ID}"
```

#### 外部からのアクセス（VPN経由）
```bash
ssh user@host -t "tmux attach -t 'project-{PROJECT_ID}'"
```

#### セッション削除（タスク完了時）
```bash
tmux kill-session -t "project-{PROJECT_ID}"
```

## ブランチ戦略

1. 作業ブランチの作成優先順位：
   - `dev-HoriikeKazuma` から作成
   - 存在しない場合は `dev` から作成
   - どちらも存在しない場合は `main` から作成

2. ブランチ命名規則：
   ```bash
   dev-Horiike-{issue番号またはタスク識別子}
   ```

3. 作業フロー：
   - ブランチ作成 → 作業 → MR作成 → マージ後ブランチ削除

## 重要な注意事項

### Claude Code起動時の待機
```bash
ccl  # Claude Code起動
sleep 2  # 1-2秒待機
```

### プロンプト送信の手順
1. プロンプトを入力
2. Enter送信
3. **空のEnterを追加送信**（重要）

これにより、tmux内のClaudeエージェントに確実に指示が伝達されます。

## 画面レイアウト

```
+-------------------+
|     上司 (PM)     |
+--------+----------+
| 部下1  |  部下2   |
+--------+----------+
| 部下3  |  部下4   |
+--------+----------+
```

## 緊急停止

すべてのプロセスとセッションを削除：
```bash
tmux kill-session -t "project-{PROJECT_ID}"
pkill -f "ccl.*project-{PROJECT_ID}"
```

## 具体的な使用方法

### 1. 組織の起動
```bash
.claude-orchestration/claude-orchestration-config/tmux-org/start-organization.sh PROJECT-123
```

### 2. セッションへのアクセス
```bash
# ローカルアクセス
tmux attach -t "project-PROJECT-123"

# リモートアクセス（VPN経由）
ssh user@host -t "tmux attach -t 'project-PROJECT-123'"
```

### 3. 部下の作成（上司のペインから実行）
```bash
# 基本的な部下作成
.claude-orchestration/claude-orchestration-config/tmux-org/create-agent.sh frontend

# タスクID付きで作成
.claude-orchestration/claude-orchestration-config/tmux-org/create-agent.sh backend 35
```

### 4. 部下への指示送信
```bash
# Pane番号を指定して送信（0:上司, 1:部下1, 2:部下2...）
.claude-orchestration/claude-orchestration-config/tmux-org/send-to-agent.sh 1 "Issue #34のUIを実装してください"
.claude-orchestration/claude-orchestration-config/tmux-org/send-to-agent.sh 2 "APIエンドポイントを作成してください"
```

### 5. ペイン番号の確認
```bash
# TMUXセッション内で実行
Ctrl+b q  # 各ペインの番号が表示される
```

### 6. 組織の停止
```bash
.claude-orchestration/claude-orchestration-config/tmux-org/stop-organization.sh
```

## ディレクトリ構造

```
.claude-orchestration/           # プロジェクトにコピーするディレクトリ
└── claude-orchestration-config/
    ├── tmux-org/
    │   ├── start-organization.sh    # 組織起動
    │   ├── create-agent.sh          # 部下作成
    │   ├── send-to-agent.sh         # 指示送信
    │   ├── stop-organization.sh     # 組織停止
    │   └── agent-helper.sh          # ブランチ管理ヘルパー
    └── hooks/
        ├── global-settings.json     # フック設定サンプル
        ├── install-hooks.sh         # フックインストーラー
        ├── detect-tmux-command.sh   # TMUXコマンド検出
        ├── check-git-operations.sh  # Git操作監視
        ├── notify-task-completion.sh # タスク完了通知
        ├── session-cleanup.sh       # セッションクリーンアップ
        └── agent-task-complete.sh   # エージェントタスク完了

# プロジェクトルートに作成されるファイル
.claude-orchestration/
├── current-tmux-session.txt     # 現在のセッション名
├── tmux-commands.md             # プロジェクト用コマンド集
├── task-completion.log          # タスク完了ログ
└── task-summary.md              # タスクサマリー
```

## Claude Codeフック機能

### フックのインストール

```bash
# グローバルフックをインストール（一度だけ実行）
.claude-orchestration/claude-orchestration-config/hooks/install-hooks.sh
```

## 他プロジェクトでの使用方法

1. `.claude-orchestration` ディレクトリをプロジェクトにコピー
```bash
cp -r /path/to/.claude-orchestration /your/project/
```

2. 組織を起動
```bash
cd /your/project
.claude-orchestration/claude-orchestration-config/tmux-org/start-organization.sh PROJECT-ID
```

3. TMUXセッションにアタッチして作業開始

### フック機能一覧

1. **TMUXコマンド自動検出** (UserPromptSubmit)
   - 「組織を開始」「部下を作成」などのコマンドを検出
   - 適切なスクリプトの使用を提案

2. **Git操作監視** (PostToolUse - Bash)
   - ブランチ作成時に命名規則をチェック
   - 推奨ベースブランチを提示
   - MR/PR作成を検出して上司に通知

3. **タスク完了通知** (PostToolUse - Task)
   - タスク完了時に自動的に上司に通知
   - 完了ログを記録

4. **セッションクリーンアップ** (Stop)
   - Claude Code終了時に自動クリーンアップ
   - 古いログファイルの削除

5. **エージェントタスク管理** (SubagentStop)
   - 部下のタスク完了を記録
   - タスクサマリーを自動生成

### フックの確認

```bash
# Claude Code内で実行
/hooks
```

### フックの無効化

```bash
# 設定ファイルを削除またはバックアップ
mv ~/.claude/settings.json ~/.claude/settings.json.disabled
```