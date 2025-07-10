# Claude Code CEO Model - 現実的な実装

M4 MacBook Proで動作するシンプルで効果的なCEO Modelシステムです。

## 🚀 クイックスタート

### 1. このディレクトリをプロジェクトにコピー
```bash
cp -r path/to/.claude-orchestration your-project/
```

### 2. CLAUDE.mdに以下を追加
```markdown
## CEO Model開発体制

このプロジェクトではCEO Modelを採用しています。詳細は`.claude-orchestration/README.md`を参照。

### 起動方法
\`\`\`bash
.claude-orchestration/scripts/start-ceo.sh
\`\`\`
```

### 3. CEO起動
```bash
cd your-project
.claude-orchestration/scripts/start-ceo.sh
```

### 4. CEOセッションにアタッチ
```bash
tmux attach -t ceo-model
```

## 📋 基本的な使い方

### CEO（あなた）の作業フロー

1. **CEOとして指示を出す**
   ```
   私に「Issue #34のノート機能を実装してください」と指示してください
   ```

2. **CEOが部下を作成して指示**
   CEOのClaude Codeが自動的に：
   - Git Worktreeで部下の作業環境を作成
   - tmuxで新しいウィンドウを作成
   - 部下のClaude Codeを起動
   - タスクを指示

3. **部下からの通知を待つ**
   CEO画面の右下ペインに通知が表示されます

### 部下の作業フロー

1. **作業を実行**
   指示されたタスクを実行

2. **完了通知を送信**
   ```bash
   ../../.claude-orchestration/scripts/agent-notify.sh "Issue #34の実装が完了しました"
   ```

3. **CEOの次の指示を待つ**

## 🛠️ CEO用コマンド（Claude Code内で使用）

### ヘルパー関数の読み込み
```bash
source /tmp/ceo-helpers.sh
```

### 部下の作成
```bash
create_agent frontend 34    # frontendエージェントをIssue #34用に作成
create_agent backend 35     # backendエージェントをIssue #35用に作成
```

### 部下への指示
```bash
send_to_agent frontend "UIコンポーネントを実装してください"
send_to_agent backend "APIエンドポイントを作成してください"
```

### 全エージェントの状態確認
```bash
check_all_agents
```

## 📊 画面構成

```
CEO Model Session
├── Window 0: CEO
│   ├── Pane 0: CEO Claude Code（メイン作業）
│   ├── Pane 1: Git Worktree監視
│   └── Pane 2: 通知モニター
├── Window 1: Agent-frontend（自動作成）
└── Window 2: Agent-backend（自動作成）
```

## 💡 ベストプラクティス

### 1. タスクは明確に
```
❌ 「機能を実装して」
✅ 「Issue #34: ノート作成フォームとリスト表示を実装」
```

### 2. 小さなタスクに分割
```
1つの部下 = 1つの明確なタスク
```

### 3. 定期的な同期
```bash
# CEO Claude Codeで実行
git fetch --all
```

## 🔧 トラブルシューティング

### tmuxセッションが見つからない
```bash
tmux list-sessions  # 確認
.claude-orchestration/scripts/start-ceo.sh  # 再起動
```

### 通知が表示されない
```bash
# 通知ファイルのパスを確認
cat /tmp/$(basename $(pwd))-notify-path.txt
```

### 部下のClaude Codeが応答しない
```bash
# 該当ウィンドウで
Ctrl-C
cca  # 再起動
```

## 📝 プロジェクトへの導入例

### 1. CLAUDE.mdへの追加
```markdown
## 開発体制

### CEO Model
このプロジェクトではCEO Modelを採用しています。
- CEO: 全体管理とPRマージ
- 部下: 機能実装

起動: `.claude-orchestration/scripts/start-ceo.sh`
```

### 2. .gitignoreへの追加
```
# CEO Model worktrees
../*-agent-*/
```

## ⚠️ 注意事項

1. **リソース使用**: 各Claude Codeインスタンスは2-4GB RAM使用
2. **同時実行数**: 通常2-3個の部下が適切
3. **作業後**: 不要なworktreeは削除
   ```bash
   git worktree remove ../project-agent-frontend
   ```

---
Created: 2025-01-10
Based on practical experience with tmux + Claude Code + Git Worktree