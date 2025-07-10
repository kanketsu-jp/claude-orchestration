# Claude Orchestration - Git Submodule

Claude CodeのCEO Model開発体制をサポートするためのサブモジュールです。tmuxを使用した階層的な開発組織（CEO/PM/Worker）を構築し、効率的なプロジェクト管理を実現します。

## 🎯 概要

このリポジトリは**サブモジュール**として各プロジェクトに組み込んで使用することを前提としています。プロジェクトごとに独立したCEO Modelセッションを構築し、複数のClaude Codeインスタンスを統合的に管理できます。

## 📦 サブモジュールとしての導入

### 1. 既存プロジェクトへの追加
```bash
cd your-project
git submodule add https://github.com/kanketsu-jp/claude-orchestration.git .claude-orchestration
git submodule update --init --recursive
git commit -m "feat: claude-orchestrationをサブモジュールとして追加"
```

### 2. プロジェクトのクローン時
```bash
git clone --recurse-submodules https://github.com/your-org/your-project.git
# または既存のクローンに対して
git submodule update --init --recursive
```

### 3. サブモジュールの更新
```bash
cd .claude-orchestration
git pull origin main
cd ..
git add .claude-orchestration
git commit -m "chore: claude-orchestrationサブモジュールを更新"
```

## 🚀 使用方法

### 1. CEO Modelの起動
```bash
# プロジェクトルートから実行
.claude-orchestration/scripts/start-ceo.sh
```

このスクリプトは以下を実行します：
- プロジェクト名とタイムスタンプを含むユニークなセッション名を生成（他プロジェクトと干渉しない）
- 3つのペインを持つtmuxセッションを作成
  - CEOペイン: Claude Code（cca）を自動起動
  - Git監視ペイン: worktreeとブランチの状態を監視
  - 通知監視ペイン: 部下からの通知を表示
- 各ペインに役割ラベルを表示

### 2. セッションへのアタッチ
```bash
# 起動時に表示されるセッション名を使用
tmux attach -t ceo-YOUR_PROJECT-1234567890
```

### 3. 部下（Worker）の作成
CEOペインのClaude Code内で：
```bash
source /tmp/ceo-helpers.sh
create_agent frontend 34    # フロントエンド担当をIssue #34用に作成
create_agent backend 35     # バックエンド担当をIssue #35用に作成
```

### 4. 部下への指示
```bash
send_to_agent frontend "Issue #34のUIコンポーネントを実装してください"
send_to_agent backend "Issue #35のAPIエンドポイントを作成してください"
```

### 5. 部下からの通知
部下のClaude Code内で：
```bash
# 通知ファイルのパスを取得
NOTIFY_FILE=$(cat /tmp/$(basename $(pwd))-notify-path.txt)
echo "[完了] Issue #34の実装が完了しました" >> $NOTIFY_FILE
```

## 📁 ディレクトリ構成

```
.claude-orchestration/
├── README.md           # このファイル
├── scripts/
│   ├── start-ceo.sh   # CEO Model起動スクリプト
│   └── agent-notify.sh # 部下用通知スクリプト
└── templates/         # プロジェクト設定テンプレート（将来拡張用）
```

## 🔧 プロジェクトでの設定

### CLAUDE.mdへの記載例
```markdown
## 開発体制

### Claude Orchestration (CEO Model)
このプロジェクトはclaude-orchestrationサブモジュールを使用したCEO Model開発体制を採用しています。

起動方法:
\`\`\`bash
.claude-orchestration/scripts/start-ceo.sh
\`\`\`

詳細: `.claude-orchestration/README.md`を参照
```

### .gitignoreへの追加
```gitignore
# Claude Orchestration
../*-agent-*/          # Git worktreeディレクトリ
/tmp/*-ceo-*.txt       # 一時ファイル
```

## 💡 ベストプラクティス

### 1. セッション管理
- プロジェクトごとに独立したセッションが作成される
- セッション名にはプロジェクト名とタイムスタンプが含まれる
- 作業終了時は必ずセッションをクリーンアップ

### 2. サブモジュールの更新
- 定期的に最新版に更新することを推奨
- 更新前に現在の動作を確認
- 更新後は必ずテスト実行

### 3. リソース管理
- 各Claude Codeインスタンスは2-4GBのRAMを使用
- 同時に起動する部下は2-3個が推奨
- 不要なworktreeは定期的に削除

## 🛠️ トラブルシューティング

### サブモジュールが見つからない
```bash
git submodule update --init --recursive
```

### セッション名の確認
```bash
cat /tmp/*-session-name.txt
tmux list-sessions
```

### 通知が表示されない
```bash
# 通知ファイルの場所を確認
cat /tmp/*-notify-path.txt
```

## 📝 サブモジュールのカスタマイズ

プロジェクト固有の設定が必要な場合：

1. **フォーク不要**: 設定はプロジェクト側のCLAUDE.mdで行う
2. **スクリプトの拡張**: プロジェクト側でラッパースクリプトを作成
3. **環境変数**: プロジェクト側の`.env`で設定

## ⚠️ 注意事項

1. **サブモジュールの変更**: 変更は元のリポジトリにプッシュされる
2. **バージョン固定**: 特定のコミットに固定することを推奨
3. **プライベートリポジトリ**: アクセス権限の設定が必要

## 🔄 更新履歴

- 2025-01-10: サブモジュール前提の内容に全面改訂
- 2025-01-10: CCLコマンド検出を削除、CCAのみ使用
- 2025-01-10: セッション名のユニーク化、役割表示機能追加

---
Repository: https://github.com/kanketsu-jp/claude-orchestration
License: MIT