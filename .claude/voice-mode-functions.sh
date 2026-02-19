#!/bin/bash
# Voice Mode Functions for Claude Code and KiloCode
# Add this to your ~/.zshrc or ~/.bashrc:
#   source "/Users/sc/News\ Letter/.claude/voice-mode-functions.sh"

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

# Function to check if a service is running
check_service() {
    local port=$1
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

# Function to start MAGI 3 Voice Server
start_magi3_server() {
    if [ -f "$VOICE_SERVER_PATH" ]; then
        node "$VOICE_SERVER_PATH" > /tmp/magi3-voice-server.log 2>&1 &
        echo $! > /tmp/magi3-voice-server.pid
        return 0
    fi
    return 1
}

# Function to start VAD
start_vad() {
    if [ -f "$VAD_SCRIPT" ]; then
        python3 "$VAD_SCRIPT" > /tmp/vad-record.log 2>&1 &
        echo $! > /tmp/vad-record.pid
        return 0
    fi
    return 1
}

# Function to display MAGI 3 status
show_magi3_status() {
    local vad_running=false
    local whisper_running=false
    local kokoro_running=false
    
    echo ""
    if check_vad; then
        echo -e "${GREEN}✓${NC} Silero VAD is running"
        vad_running=true
    else
        echo -e "${YELLOW}⚠${NC} Silero VAD is not running"
    fi
    
    if check_service $WHISPER_PORT; then
        echo -e "${GREEN}✓${NC} Whisper (STT) is running on port ${WHISPER_PORT}"
        whisper_running=true
    else
        echo -e "${YELLOW}⚠${NC} Whisper (STT) is not running on port ${WHISPER_PORT}"
    fi
    
    if check_service $KOKORO_PORT; then
        echo -e "${GREEN}✓${NC} Kokoro (TTS) is running on port ${KOKORO_PORT}"
        kokoro_running=true
    else
        echo -e "${YELLOW}⚠${NC} Kokoro (TTS) is not running on port ${KOKORO_PORT}"
    fi
    
    echo ""
    local service_count=0
    [ "$vad_running" = true ] && ((service_count++))
    [ "$whisper_running" = true ] && ((service_count++))
    [ "$kokoro_running" = true ] && ((service_count++))
    
    if [ $service_count -eq 3 ]; then
        echo -e "${GREEN}═════════════════════════════════════════════════${NC}"
        echo -e "${GREEN}     MAGI 3 - ALL CORES ONLINE - 🟢${NC}"
        echo -e "${GREEN}═════════════════════════════════════════════════${NC}"
    elif [ $service_count -gt 0 ]; then
        echo -e "${YELLOW}═════════════════════════════════════════════════${NC}"
        echo -e "${YELLOW}     MAGI 3 CORE(S) COMPROMISED | PARTIAL SYSTEM ONLINE ⚠️${NC}"
        echo -e "${YELLOW}═════════════════════════════════════════════════${NC}"
    else
        echo -e "${RED}═════════════════════════════════════════════════${NC}"
        echo -e "${RED}     MAGI 3 OFFLINE 🔴${NC}"
        echo -e "${RED}═════════════════════════════════════════════════${NC}"
    fi
    
    echo ""
}

# Function to start all voice services with spinning animation
start_voice_services() {
    # Show spinning message immediately
    echo ""
    echo -e "${YELLOW}═════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}     SPINNING MAGI 3 CORES ⚡🌀 ${NC}"
    echo -e "${YELLOW}═════════════════════════════════════════════════${NC}"
    echo ""
    
    # Start all services synchronously (in parallel)
    local need_vad=false
    local need_magi3=false
    
    # Check what needs to be started
    if ! check_vad; then
        need_vad=true
    fi
    
    if ! check_service $WHISPER_PORT || ! check_service $KOKORO_PORT; then
        need_magi3=true
    fi
    
    # Start VAD if needed
    if [ "$need_vad" = true ]; then
        start_vad
    fi
    
    # Start MAGI 3 server if needed
    if [ "$need_magi3" = true ]; then
        start_magi3_server
    fi
    
    # Wait for VAD to spin up (VAD takes longer than Whisper/Kokoro)
    if [ "$need_vad" = true ]; then
        echo -e "${BLUE}Waiting for VAD to initialize...${NC}"
        local wait_count=0
        while ! check_vad && [ $wait_count -lt 30 ]; do
            sleep 0.5
            ((wait_count++))
        done
        if check_vad; then
            echo -e "${GREEN}✓${NC} VAD initialized"
        else
            echo -e "${RED}✗${NC} VAD failed to initialize"
        fi
    fi
    
    # Brief wait for Whisper/Kokoro if we started MAGI 3
    if [ "$need_magi3" = true ]; then
        sleep 2
    fi
}

# Override claude command with voice mode support
claude() {
    # Check if --voice flag is present
    local voice_mode=false
    local args=()
    
    for arg in "$@"; do
        if [ "$arg" = "--voice" ]; then
            voice_mode=true
        else
            args+=("$arg")
        fi
    done
    
    if [ "$voice_mode" = true ]; then
        # Voice mode activation
        echo -e "${BLUE}═════════════════════════════════════════════════${NC}"
        echo -e "${BLUE}     Claude Code - Voice Mode${NC}"
        echo -e "${BLUE}═════════════════════════════════════════════════${NC}"
        
        # Start services if needed
        start_voice_services
        
        # Show status after starting services
        show_magi3_status
        
        # Enable voice mode
        export CLAUDE_VOICE_MODE=1
        export KILO_VOICE_MODE=1
        
        echo -e "${GREEN}✓${NC} Voice mode enabled"
        echo -e "${GREEN}✓${NC} Use /voice command to start listening"
        echo ""
        
        # Call original claude command using 'command' builtin to skip function
        command claude "${args[@]}"
    else
        # Normal mode - just pass through using 'command' builtin
        command claude "$@"
    fi
}

# Override kilo command with voice mode support
kilo() {
    # Check if --voice flag is present
    local voice_mode=false
    local args=()
    
    for arg in "$@"; do
        if [ "$arg" = "--voice" ]; then
            voice_mode=true
        else
            args+=("$arg")
        fi
    done
    
    if [ "$voice_mode" = true ]; then
        # Voice mode activation
        echo -e "${BLUE}═════════════════════════════════════════════════${NC}"
        echo -e "${BLUE}     KiloCode - Voice Mode${NC}"
        echo -e "${BLUE}═════════════════════════════════════════════════${NC}"
        
        # Start services if needed
        start_voice_services
        
        # Show status after starting services
        show_magi3_status
        
        # Enable voice mode
        export CLAUDE_VOICE_MODE=1
        export KILO_VOICE_MODE=1
        
        echo -e "${GREEN}✓${NC} Voice mode enabled"
        echo -e "${GREEN}✓${NC} Use /voice command to start listening"
        echo ""
        
        # Call original kilo/kilocode command using 'command' builtin
        if command -v kilocode &> /dev/null; then
            command kilocode "${args[@]}"
        elif command -v kilo &> /dev/null; then
            command kilo "${args[@]}"
        else
            echo -e "${RED}Error: Could not find kilo or kilocode command${NC}"
            return 1
        fi
    else
        # Normal mode - just pass through using 'command' builtin
        if command -v kilocode &> /dev/null; then
            command kilocode "$@"
        elif command -v kilo &> /dev/null; then
            command kilo "$@"
        else
            echo -e "${RED}Error: Could not find kilo or kilocode command${NC}"
            return 1
        fi
    fi
}

echo -e "${GREEN}Voice mode functions loaded. Use 'claude --voice' or 'kilo --voice' to start.${NC}"
