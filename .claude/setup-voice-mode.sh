#!/bin/bash
# Setup script for voice mode functions
# This script adds voice mode support to claude and kilo commands

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Determine shell config file
if [ -n "$ZSH_VERSION" ] || [ "$SHELL" = "/bin/zsh" ]; then
    SHELL_CONFIG="$HOME/.zshrc"
elif [ -n "$BASH_VERSION" ] || [ "$SHELL" = "/bin/bash" ]; then
    SHELL_CONFIG="$HOME/.bashrc"
else
    SHELL_CONFIG="$HOME/.bashrc"
fi

echo -e "${BLUE}═════════════════════════════════════════════════${NC}"
echo -e "${BLUE}     Voice Mode Setup${NC}"
echo -e "${BLUE}═════════════════════════════════════════════════${NC}"
echo ""

# Check if functions file exists
FUNCTIONS_FILE="/Users/sc/News Letter/.claude/voice-mode-functions.sh"
if [ ! -f "$FUNCTIONS_FILE" ]; then
    echo -e "${RED}Error: Voice mode functions file not found at:${NC}"
    echo -e "  $FUNCTIONS_FILE"
    exit 1
fi

# Remove old wrapper scripts if they exist
if [ -f "/usr/local/bin/claude" ]; then
    echo -e "${YELLOW}Removing old claude wrapper from /usr/local/bin...${NC}"
    sudo rm -f /usr/local/bin/claude
    echo -e "${GREEN}✓${NC} Removed"
fi

if [ -f "/usr/local/bin/kilo" ]; then
    echo -e "${YELLOW}Removing old kilo wrapper from /usr/local/bin...${NC}"
    sudo rm -f /usr/local/bin/kilo
    echo -e "${GREEN}✓${NC} Removed"
fi

# Add source line to shell config
SOURCE_LINE='source "/Users/sc/News Letter/.claude/voice-mode-functions.sh"'

if grep -q "$SOURCE_LINE" "$SHELL_CONFIG" 2>/dev/null; then
    echo -e "${GREEN}Voice mode functions already sourced in $SHELL_CONFIG${NC}"
else
    echo -e "${BLUE}Adding voice mode functions to $SHELL_CONFIG...${NC}"
    echo "" >> "$SHELL_CONFIG"
    echo "# Voice mode functions for Claude Code and KiloCode" >> "$SHELL_CONFIG"
    echo "$SOURCE_LINE" >> "$SHELL_CONFIG"
    echo -e "${GREEN}✓${NC} Added to $SHELL_CONFIG"
fi

echo ""
echo -e "${GREEN}═════════════════════════════════════════════════${NC}"
echo -e "${GREEN}     Setup Complete!${NC}"
echo -e "${GREEN}═════════════════════════════════════════════════${NC}"
echo ""
echo -e "${GREEN}Voice mode functions have been installed.${NC}"
echo ""
echo -e "${YELLOW}To use voice mode:${NC}"
echo -e "  1. Run: ${BLUE}source $SHELL_CONFIG${NC}  (or restart your terminal)"
echo -e "  2. Then use: ${BLUE}claude --voice${NC}  or  ${BLUE}kilo --voice${NC}"
echo ""
echo -e "${YELLOW}The commands will:${NC}"
echo -e "  • Check and display MAGI 3 status (VAD, Whisper, Kokoro)"
echo -e "  • Start any missing voice services automatically"
echo -e "  • Launch Claude Code or KiloCode in voice mode"
echo ""
