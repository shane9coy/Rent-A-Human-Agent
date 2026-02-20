# RentAHuman Telegram Bot

1. Go to Telegram-Bot-Easy repo & download or git pull (don't forget to ⭐ to support): https://github.com/shane9coy/Telegram-Bot-Easy

2. Marge the .claude or .kilocode folder contents into your current project, or git clone to work directly out of the Telegram-Bot-Easy repo.

3. Create a Telegram bot and get your API token from [@BotFather](https://t.me/BotFather).

4. Install requirements:
```bash
pip install -r requirements.txt
```

5. Set up your `.env` file with your Telegram bot token and RentAHuman API key:
```bash
TELEGRAM_BOT_TOKEN=your_telegram_bot_token
RENTAHUMAN_API_KEY=your_rentahuman_api_key
```

6. Test Run the bot:
```bash
python telegram_bot.py
```

# Now drop the following prompt into your CLI agent:


Integrate our Rent-A-Human agent into our Telegram bot. The bot should have the following features and menu available:

A Telegram bot that brings [RentAHuman.ai](https://rentahuman.ai) to your Telegram chat. Browse available humans, view open bounties, post jobs, and get AI-powered opportunity recommendations — all from your phone.

## Features

- 🔍 **Scan Bounties** - Find and score job opportunities based on your location and skills
- 🧑‍💼 **Browse Humans** - View available humans for hire with skills and rates
- 💼 **View Bounties** - See open jobs and opportunities
- 📝 **Post Jobs** - Create new bounties directly from Telegram
- 🎯 **Smart Scanning** - AI-scored opportunity recommendations
- 🔒 **Private** - Bot only responds to your user ID
- 🔗 **MCP + API Integration** - Direct connection to official RentAHuman.ai MCP


## Commands

| Command | Description |
|---------|-------------|
| `/rent` | Browse available humans |
| `/rent status` | Check API connection |
| `/rent bounties` | View open jobs |
| `/rent skills` | Browse available skills |
| `/rent scan` | Get AI-scored opportunities |
| `/rent post <desc>` | Post a new bounty |
| `help` | Show all commands |

## Examples

/rent                          # List available humans
/rent bounties                 # Show open jobs
/rent scan                     # Get top opportunities
/rent post Logo design. Budget $150  # Create a bounty
