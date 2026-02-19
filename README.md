# Rent-A-Human-Agent

An AI-powered agent system for scanning and scoring job opportunities from the Rent-A-Human platform. The agent uses Grok AI to evaluate and rank bounties, helping you find the best opportunities.

## Features

- **AI-Powered Scoring**: Uses Grok-3-mini-fast to score job opportunities on a scale of 0-100
- **Smart Caching**: Caches results for 12 hours to avoid redundant API calls
- **Telegram Integration**: Sends top opportunities directly to your Telegram
- **CLI Interface**: Run scans from the command line with various options
- **Multiple Scan Modes**: 
  - Cached mode (fast, uses existing scores)
  - Force fresh scoring (bypass cache)
  - List all open jobs
  - List available humans for hire

## Project Structure

```
Rent-A-Human-Agent/
├── .claude/              # Claude Code configurations
│   ├── commands/         # CLI command definitions
│   └── skills/           # Claude skills
│       └── rent/         # Rent-A-Human skill
│           └── scripts/
│               └── bounty_hunter.py  # Main scanner script
├── .kilocode/            # KiloCode configurations (mirrors .claude)
└── logs/                 # Cache and log files
```

## Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/Rent-A-Human-Agent.git
cd Rent-A-Human-Agent
```

2. Install Python dependencies:
```bash
pip install -r requirements.txt
```

3. Set up environment variables:
```bash
# Create a .env file with your API keys
GROK_API_KEY=your_grok_api_key
TELEGRAM_BOT_TOKEN=your_telegram_bot_token
TELEGRAM_CHAT_ID=your_chat_id
```

## Usage

### Command Line

```bash
# Normal scan (uses cache)
python bounty_hunter.py

# Force fresh scoring
python bounty_hunter.py --force

# List all open jobs (no scoring)
python bounty_hunter.py --jobs

# List available humans
python bounty_hunter.py --humans

# Skip Telegram notification
python bounty_hunter.py --no-telegram
```

### Claude Code Integration

The project includes Claude Code skill definitions in `.claude/skills/rent/`. To use with Claude Code:

1. Copy the `.claude` folder to your Claude Code project
2. Use the `/rent` command to trigger scans

### Cron Setup

To run automatically every 12 hours:

```bash
# Add to your crontab
0 8,20 * * * cd /path/to/Rent-A-Human-Agent && python3 bounty_hunter.py >> logs/bounty_hunter.log 2>&1
```

## Configuration

### Cache Settings

- Cache file: `logs/bounties_cache.json`
- Cache TTL: 12 hours
- Seen bounties: `logs/bounties_seen.json`

### Scoring Criteria

The AI scores bounties based on:
- Budget amount (higher = better)
- Clear specifications
- Reputation of the poster
- Difficulty vs. reward ratio

## Requirements

See `requirements.txt` for Python dependencies.

## License

MIT License - see LICENSE file for details.

## Author

Built by: x.com/@shaneswrld_ | github.com/shane9coy
