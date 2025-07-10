# 部下（Agent）監視コマンド

## 概要
CEO Model開発体制で作成した部下（tmuxペイン内のClaude Code）の動作をリアルタイムで監視するためのコマンド集です。

## 利用可能なコマンド

### 1. watch-agents.sh - シンプルなリアルタイム監視
```bash
# 基本的な使い方
./watch-agents.sh

# 特定のセッションを監視
./watch-agents.sh [session-name]
```

**特徴:**
- 3秒ごとに自動更新
- 各ペインの最新10行を表示
- シンプルで軽量

### 2. agent-dashboard.sh - 高機能ダッシュボード
```bash
# 起動
./agent-dashboard.sh

# 特定のセッションを指定
./agent-dashboard.sh [session-name]
```

**表示モード:**
1. **リアルタイム監視**: 自動更新で全ペインを監視
2. **スナップショット**: 現在の状態を1回だけ表示
3. **詳細表示**: 特定のペインを詳しく確認

**特徴:**
- Issue番号の自動抽出
- カラフルなUI
- 複数の表示モード

## スラッシュコマンド対応

PMに「/agents」または「部下の様子を見たい」と伝えると、以下の案内を提供します：

```bash
# 新しいターミナルを開いて実行
cd /path/to/MCP4KMDR
./agent-dashboard.sh
```

## tmux直接コマンド

### 特定のペインを確認
```bash
# ペイン0の内容を確認
tmux capture-pane -t mcp4kmdr-dev:0.0 -p | tail -30

# ペイン1の内容を確認
tmux capture-pane -t mcp4kmdr-dev:0.1 -p | tail -30
```

### すべてのペインを一覧表示
```bash
tmux list-panes -t mcp4kmdr-dev -F "Pane #{pane_index}: #{pane_current_command}"
```

### 特定のペインにフォーカス
```bash
# 別ウィンドウでペインを表示
tmux new-window -t mcp4kmdr-dev "tmux attach-session -t mcp4kmdr-dev"
```

## 使用例

### ケース1: 部下の進捗を確認したい
```bash
# ダッシュボードを起動
./agent-dashboard.sh

# モード2（スナップショット）を選択
# → 各部下の現在の作業状況が一覧表示される
```

### ケース2: 特定の部下を詳しく監視
```bash
# ダッシュボードを起動
./agent-dashboard.sh

# モード3（詳細表示）を選択
# ペイン番号を入力（例: 0）
# → そのペインの詳細な出力が表示される
```

### ケース3: 継続的な監視
```bash
# バックグラウンドで監視を開始
./watch-agents.sh &

# または別ターミナルで
./agent-dashboard.sh
# モード1（リアルタイム監視）を選択
```

## トラブルシューティング

### セッションが見つからない場合
```bash
# 利用可能なセッションを確認
tmux list-sessions

# 正しいセッション名を指定
./agent-dashboard.sh correct-session-name
```

### ペインが表示されない場合
```bash
# セッション内のペインを確認
tmux list-panes -t session-name
```

## 注意事項
- tmuxセッションが存在している必要があります
- 部下（Claude Code）が起動している必要があります
- スクリプトは実行権限が必要です（`chmod +x`）