#!/bin/bash

# Claude Codeフックをグローバルにインストールするスクリプト

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETTINGS_FILE="$HOME/.claude/settings.json"

echo "Claude Code TMUXフックのインストール"
echo "===================================="

# .claudeディレクトリの作成
mkdir -p "$HOME/.claude"

# 既存の設定ファイルのバックアップ
if [ -f "$SETTINGS_FILE" ]; then
    echo "既存の設定ファイルをバックアップしています..."
    cp "$SETTINGS_FILE" "$SETTINGS_FILE.backup.$(date +%Y%m%d_%H%M%S)"
fi

# フックパスを現在の場所に更新
echo "フック設定を生成しています..."
sed "s|\$HOME/.claude/agents/.claude-orchestration|$SCRIPT_DIR/..|g" \
    "$SCRIPT_DIR/global-settings.json" > "$SCRIPT_DIR/temp-settings.json"

# 既存の設定とマージするか、新規作成
if [ -f "$SETTINGS_FILE" ]; then
    echo "既存の設定とマージしています..."
    # 簡易的なマージ（実際のプロダクション環境ではjqなどを使用推奨）
    echo "警告: 手動で設定をマージする必要があります"
    echo "生成された設定: $SCRIPT_DIR/temp-settings.json"
    echo "既存の設定: $SETTINGS_FILE"
else
    cp "$SCRIPT_DIR/temp-settings.json" "$SETTINGS_FILE"
    echo "新しい設定ファイルを作成しました: $SETTINGS_FILE"
fi

# クリーンアップ
rm -f "$SCRIPT_DIR/temp-settings.json"

echo ""
echo "インストール完了！"
echo ""
echo "使用方法:"
echo "1. Claude Codeを再起動してフックを有効化"
echo "2. /hooks コマンドでフックの状態を確認"
echo ""
echo "主な機能:"
echo "- TMUXコマンドの自動検出と提案"
echo "- Git操作時のブランチ戦略確認"
echo "- タスク完了時の自動通知"
echo "- セッション終了時の自動クリーンアップ"
echo ""
echo "アンインストール:"
echo "  rm $SETTINGS_FILE"
echo "  または手動で hooks セクションを削除"