# RENT-A-HUMAN-AGENT

💰 **An agentic CLI that scans Rentahuman.ai in real time via MCP + API.**
🧠 **Custom [Grok](https://x.ai)-powered framework that filters spam, ranks by your location + skills + how easy the cash is, and beams the winners straight to your Telegram, terminal, or messenger of choice.**
🎮 **Bringing the power of robot bounty hunting to the everyday player.**

<img width="1053" height="1138" alt="rentahumanagent" src="https://github.com/user-attachments/assets/590943eb-6649-4296-bdd8-5e5a08add654" />

## What It Does

This 'drag & drop' agentic system is ready to be powered by your favorite CLI agent. Built for scanning and scoring job opportunities on the [Rentahuman.ai](https://rentahuman.ai) platform via MCP and API framework. The custom `bounty_hunter` script utilizes Grok AI to evaluate, filter spam, and rank bounties based on your location, skills, and ease of completion — helping you find the best opportunities for easy cash.

The agent features Rent-A-Human MCP server access (bring your own key), a customizable `/rent` agent mode in your CLI editor, the modern `.claude` SKILLS framework, and AI-powered bounty scoring using Grok-4-1-fast-reasoning to search, filter spam, evaluate, and rank opportunities.

## Features

- **Rent-A-Human MCP Server Integration**: Full agentic access to the RentAHuman.ai platform
- **CLI Interface**: Fully customizable `/rent` agent mode
- **AI-Powered Scoring**: Uses Grok-4-1-fast-reasoning to score job opportunities on a scale of 0-100
- **Smart Caching**: Caches results for 12 hours to avoid redundant API calls
- **Telegram Integration**: Sends top opportunities directly to your Telegram
- **Drag & Drop Skills**: Compatible with Claude Code and OpenClaw — drop the `.claude/skills/` folder into any project
- **Multiple Scan Modes**:
  - Cached mode (fast, uses existing scores)
  - Force fresh scoring (bypass cache)
  - List all open jobs
  - List available humans for hire

## Project Structure

```
Rent-A-Human-Agent/
├── .claude/              # Claude Code configurations
│   ├── CLAUDE.md         # Project-specific system prompt
│   ├── settings.json     # MCP server configuration
│   ├── commands/         # CLI command definitions
│   │   └── rent.md       # /rent command reference
│   └── skills/           # Claude skills
│       └── rent/         # Rent-A-Human skill
│           ├── SKILL.md  # Skill triggers and quick reference
│           ├── cache/    # Cache files (auto-created)
│           │   ├── bounties_cache.json    # Scored bounties (JSON)
│           │   └── bounties_ranked.txt    # Human-readable output
│           └── scripts/
│               └── bounty_hunter.py  # Main scanner script
├── logs/                 # Log files (optional)
├── .env                  # API keys (create from template)
└── requirements.txt      # Python dependencies
```

## Installation

1. Clone the repository:
```bash
git clone https://github.com/shane9coy/Rent-A-Human-Agent.git
cd Rent-A-Human-Agent
```

2. Install Python dependencies:
```bash
pip install -r requirements.txt
```

3. Set up environment variables:
```bash
# Create a .env file with your API keys
RENTAHUMAN_API_KEY=your_rentahuman_api_key    # Required: from rentahuman.ai/dashboard
XAI_API_KEY=your_xai_api_key                  # Required: from x.ai for Grok scoring
TELEGRAM_BOT_TOKEN=your_telegram_bot_token    # Optional: for Telegram notifications
TELEGRAM_CHAT_ID=your_chat_id                 # Optional: for Telegram notifications
```

## Usage

### Command Line

```bash
# Normal scan (uses cache if fresh)
python3 .claude/skills/rent/scripts/bounty_hunter.py

# Force fresh scoring (bypass 12-hour cache)
python3 .claude/skills/rent/scripts/bounty_hunter.py --force

# List all open jobs (no scoring)
python3 .claude/skills/rent/scripts/bounty_hunter.py --jobs

# List available humans for hire
python3 .claude/skills/rent/scripts/bounty_hunter.py --humans

# Skip Telegram notification
python3 .claude/skills/rent/scripts/bounty_hunter.py --no-telegram
```

### Claude Code Integration

The project includes Claude Code skill definitions in `.claude/skills/rent/`. To use with Claude Code:

1. Copy the `.claude` folder to your Claude Code project (or use this repo as your project)
2. Use the `/rent` command to trigger scans and access all features

### OpenClaw / ClawHub

The skills in `.claude/skills/` are drag & drop compatible. Copy the `rent/` skill folder into any OpenClaw-compatible agent to add bounty hunting capabilities.

### Cron Setup

To run automatically every 12 hours:

```bash
# Add to your crontab
0 8,20 * * * cd /path/to/Rent-A-Human-Agent && python3 .claude/skills/rent/scripts/bounty_hunter.py >> logs/bounty_hunter.log 2>&1
```

## Configuration

### Cache Settings

- Cache directory: `.claude/skills/rent/cache/`
- Cache file: `bounties_cache.json` (JSON format)
- Human-readable output: `bounties_ranked.txt`
- Cache TTL: 12 hours

### Scoring Criteria

The AI scores bounties based on:
- Budget amount and hourly rate
- Description quality and clarity
- Skill match with your profile
- Remote work availability
- Competition (spots available vs. filled)
- Scam signal detection (crypto transfers, wallet addresses, etc.)

## Requirements

See `requirements.txt` for Python dependencies:
- `requests` - HTTP client for API calls
- `python-dotenv` - Environment variable management

## License

MIT License - see LICENSE file for details.

## Author

Built by [@shaneswrld_](https://x.com/shaneswrld_) | [github.com/shane9coy](https://github.com/shane9coy)
