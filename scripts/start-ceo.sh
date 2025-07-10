#!/bin/bash
# CEO Model Startup Script - シンプルで現実的な実装
# M4 MacBook Pro対応

set -e

# Configuration
PROJECT_NAME=$(basename $(pwd))
SESSION_NAME="ceo-model"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}🤖 CEO Model 起動準備${NC}"
echo "プロジェクト: $PROJECT_NAME"

# Kill existing session if exists
tmux kill-session -t "$SESSION_NAME" 2>/dev/null || true

# Step 1: Create main session with CEO
echo -e "${YELLOW}1. CEOセッション作成...${NC}"
tmux new-session -d -s "$SESSION_NAME" -n "CEO" -c "$(pwd)"

# Step 2: Setup monitoring pane
tmux split-window -h -t "${SESSION_NAME}:0" -c "$(pwd)"
tmux send-keys -t "${SESSION_NAME}:0.1" 'watch -n 2 "echo \"=== Git Worktrees ===\" && git worktree list && echo && echo \"=== Active Branches ===\" && git branch -r | grep -E \"agent-|issue-\" | head -10"' Enter

# Step 3: Create notification file
NOTIFY_FILE="/tmp/${PROJECT_NAME}-ceo-notifications.txt"
echo "# CEO通知ファイル - $(date)" > "$NOTIFY_FILE"
echo "部下からの完了通知がここに記録されます" >> "$NOTIFY_FILE"

# Step 4: Setup CEO monitoring of notifications
tmux split-window -v -t "${SESSION_NAME}:0.1" -c "$(pwd)"
tmux send-keys -t "${SESSION_NAME}:0.2" "tail -f $NOTIFY_FILE" Enter

# Step 5: Create helper functions file
cat > "/tmp/ceo-helpers.sh" << 'EOF'
#!/bin/bash
# Helper functions for CEO operations

# 部下を作成する関数
create_agent() {
    local AGENT_TYPE=$1
    local ISSUE_NUM=$2
    local SESSION="ceo-model"
    
    echo "Creating agent: $AGENT_TYPE for Issue #$ISSUE_NUM"
    
    # Create worktree
    git worktree add "../$(basename $(pwd))-agent-$AGENT_TYPE" -b "issue-$ISSUE_NUM-$AGENT_TYPE"
    
    # Create new window for agent
    tmux new-window -t "$SESSION" -n "Agent-$AGENT_TYPE" -c "../$(basename $(pwd))-agent-$AGENT_TYPE"
    
    # Start Claude Code
    tmux send-keys -t "$SESSION:Agent-$AGENT_TYPE" "cca" Enter
    
    echo "Agent $AGENT_TYPE created in window 'Agent-$AGENT_TYPE'"
}

# 部下に指示を送る関数
send_to_agent() {
    local AGENT_TYPE=$1
    shift
    local MESSAGE="$@"
    local SESSION="ceo-model"
    
    echo "Sending to $AGENT_TYPE: $MESSAGE"
    tmux send-keys -t "$SESSION:Agent-$AGENT_TYPE" "$MESSAGE" Enter
}

# 部下からの通知を記録する関数
notify_ceo() {
    local AGENT_TYPE=$1
    shift
    local MESSAGE="$@"
    local NOTIFY_FILE="/tmp/$(basename $(pwd))-ceo-notifications.txt"
    
    echo "[$(date +%H:%M:%S)] Agent-$AGENT_TYPE: $MESSAGE" >> "$NOTIFY_FILE"
}

# 全エージェントのステータス確認
check_all_agents() {
    local SESSION="ceo-model"
    echo "=== Agent Status ==="
    tmux list-windows -t "$SESSION" | grep Agent
}

export -f create_agent
export -f send_to_agent
export -f notify_ceo
export -f check_all_agents
EOF

chmod +x "/tmp/ceo-helpers.sh"

# Instructions
echo -e "\n${GREEN}✅ CEO Model 起動完了！${NC}"
echo ""
echo "📋 使い方:"
echo ""
echo "1. CEOにアタッチ:"
echo -e "   ${YELLOW}tmux attach -t $SESSION_NAME${NC}"
echo ""
echo "2. 部下の作成（CEO Claude Codeで実行）:"
echo '   source /tmp/ceo-helpers.sh'
echo '   create_agent frontend 34'
echo ""
echo "3. 部下への指示:"
echo '   send_to_agent frontend "Issue #34のノート機能を実装してください"'
echo ""
echo "4. 部下からの完了通知（部下のClaude Codeで実行）:"
echo '   echo "[完了] Issue #34のUI実装が完了しました" >> '$NOTIFY_FILE
echo ""
echo "通知ファイル: $NOTIFY_FILE"
echo ""

# Save the notification file path for later use
echo "$NOTIFY_FILE" > "/tmp/${PROJECT_NAME}-notify-path.txt"