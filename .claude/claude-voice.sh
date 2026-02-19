#!/bin/bash
# claude --voice wrapper script
# This script launches Claude Code with voice mode enabled
# Usage: claude --voice [additional claude arguments]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Voice server configuration
VOICE_SERVER_PATH="/Users/sc/mcp-servers/magi3-mcp-voice-server/src/index.js"
VAD_SCRIPT="/Users/sc/News Letter/utility_scripts/vad-record.py"
WHISPER_PORT=2022
KOKORO_PORT=8880

# Find original claude command (skip our wrapper)
ORIGINAL_CLAUDE=$(command -v claude 2>/dev/null | grep -v "/usr/local/bin/claude" | head -1)
if [ -z "$ORIGINAL_CLAUDE" ]; then
    # Try common installation paths
    for path in "/opt/homebrew/bin/claude" "/usr/local/bin/claude.real" "/opt/homebrew/Caskroom/claude"; do
        if [ -x "$path" ]; then
            ORIGINAL_CLAUDE="$path"
            break
        fi
    done
fi

# If already in voice mode, just call the original claude command
if [ "$CLAUDE_VOICE_MODE" = "1" ]; then
    exec "$ORIGINAL_CLAUDE" "$@"
fi

# Function to check if a service is running
check_service() {
    local port=$1
    local name=$2
    if curl -s "http://localhost:${port}/health" > /dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Function to check if VAD is running
check_vad() {
    if pgrep -f "vad-record.py" > /dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Function to start voice server
start_voice_server() {
    echo -e "${BLUE}Starting MAGI 3 Voice Server...${NC}"
    if [ -f "$VOICE_SERVER_PATH" ]; then
        # Start voice server in background
        node "$VOICE_SERVER_PATH" > /tmp/magi3-voice-server.log 2>&1 &
        VOICE_SERVER_PID=$!
        echo $VOICE_SERVER_PID > /tmp/magi3-voice-server.pid
        echo -e "${GREEN}✓${NC} Voice server started (PID: $VOICE_SERVER_PID)"
        
        # Wait for services to be ready
        echo -e "${BLUE}Waiting for voice services to initialize...${NC}"
        sleep 3
    else
        echo -e "${RED}✗${NC} Voice server not found at: $VOICE_SERVER_PATH"
        echo -e "${YELLOW}Continuing without voice server...${NC}"
    fi
}

# Function to start VAD if not running
start_vad_if_needed() {
    if ! check_vad; then
        echo -e "${BLUE}Starting Silero VAD...${NC}"
        if [ -f "$VAD_SCRIPT" ]; then
            python3 "$VAD_SCRIPT" > /tmp/vad-record.log 2>&1 &
            VAD_PID=$!
            echo $VAD_PID > /tmp/vad-record.pid
            echo -e "${GREEN}✓${NC} VAD started (PID: $VAD_PID)"
            sleep 2
        else
            echo -e "${RED}✗${NC} VAD script not found at: $VAD_SCRIPT"
        fi
    fi
}

# Function to stop voice server
stop_voice_server() {
    # Stop VAD if we started it
    if [ -f /tmp/vad-record.pid ]; then
        PID=$(cat /tmp/vad-record.pid)
        if kill -0 $PID 2>/dev/null; then
            echo -e "${BLUE}Stopping VAD (PID: $PID)...${NC}"
            kill $PID
            rm /tmp/vad-record.pid
            echo -e "${GREEN}✓${NC} VAD stopped"
        fi
    fi
    
    # Stop voice server
    if [ -f /tmp/magi3-voice-server.pid ]; then
        PID=$(cat /tmp/magi3-voice-server.pid)
        if kill -0 $PID 2>/dev/null; then
            echo -e "${BLUE}Stopping voice server (PID: $PID)...${NC}"
            kill $PID
            rm /tmp/magi3-voice-server.pid
            echo -e "${GREEN}✓${NC} Voice server stopped"
        fi
    fi
}

# Trap to stop voice server on exit
trap stop_voice_server EXIT

# Main execution
echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo -e "${BLUE}     Claude Code - Voice Mode${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo ""

# Check voice server status
VAD_RUNNING=false
WHISPER_RUNNING=false
KOKORO_RUNNING=false

# Check VAD status
if check_vad; then
    echo -e "${GREEN}✓${NC} Silero VAD is running"
    VAD_RUNNING=true
else
    echo -e "${YELLOW}⚠${NC} Silero VAD is not running"
fi

# Check Whisper status
if check_service $WHISPER_PORT; then
    echo -e "${GREEN}✓${NC} Whisper (STT) is running on port ${WHISPER_PORT}"
    WHISPER_RUNNING=true
else
    echo -e "${YELLOW}⚠${NC} Whisper (STT) is not running on port ${WHISPER_PORT}"
fi

# Check Kokoro status
if check_service $KOKORO_PORT; then
    echo -e "${GREEN}✓${NC} Kokoro (TTS) is running on port ${KOKORO_PORT}"
    KOKORO_RUNNING=true
else
    echo -e "${YELLOW}⚠${NC} Kokoro (TTS) is not running on port ${KOKORO_PORT}"
fi

# Display MAGI 3 status
echo ""
SERVICE_COUNT=0
[ "$VAD_RUNNING" = true ] && SERVICE_COUNT=$((SERVICE_COUNT + 1))
[ "$WHISPER_RUNNING" = true ] && SERVICE_COUNT=$((SERVICE_COUNT + 1))
[ "$KOKORO_RUNNING" = true ] && SERVICE_COUNT=$((SERVICE_COUNT + 1))

if [ $SERVICE_COUNT -eq 3 ]; then
    echo -e "${GREEN}═══════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}     MAGI 3 ONLINE - 🟢${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════${NC}"
elif [ $SERVICE_COUNT -gt 0 ]; then
    echo -e "${YELLOW}═══════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}     MAGI 3 CORE(S) COMPROMISED | PARTIAL SYSTEM ONLINE ⚠️${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════════════════${NC}"
else
    echo -e "${RED}═══════════════════════════════════════════════════${NC}"
    echo -e "${RED}     MAGI 3 OFFLINE 🔴${NC}"
    echo -e "${RED}═══════════════════════════════════════════════════${NC}"
fi

# Start voice server if not running
if [ "$WHISPER_RUNNING" = false ] || [ "$KOKORO_RUNNING" = false ]; then
    echo ""
    start_voice_server
    echo ""
fi

# Start VAD if not running
start_vad_if_needed

# Set voice mode environment variable
export CLAUDE_VOICE_MODE=1
export KILO_VOICE_MODE=1

echo -e "${GREEN}✓${NC} Voice mode enabled"
echo -e "${GREEN}✓${NC} Use /voice command to start listening"
echo ""

# Pass all arguments to claude command
# Remove --voice from arguments if present
ARGS=()
for arg in "$@"; do
    if [ "$arg" != "--voice" ]; then
        ARGS+=("$arg")
    fi
done

# Launch claude with remaining arguments
echo -e "${BLUE}Launching Claude Code...${NC}"
echo ""

exec "$ORIGINAL_CLAUDE" "${ARGS[@]}"
