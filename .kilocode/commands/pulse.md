---
name: pulse
description: Control Market Pulse Newsletter pipeline
---

Execute newsletter automation tasks.

**Usage:** `/pulse <task> [options]`

**News Feed Tasks:**
- `news update` - Pull RSS/X feeds and rank with Grok (saves to files, no newsletter gen)
- `read ranked` - Read today's ranked news from news_letter/ranked_news/
- `read x` - Read today's X summaries from news_letter/x_summaries/
- `read all` - Read both ranked news and X summaries
- `analyze` - Analyze today's news for key themes and insights

**Newsletter Tasks:**
- `gen nl` - Generate newsletter from current ranked_news file
- `run nl pipeline` - Run complete newsletter_gen.py (pulls feeds, ranks, generates)
- `send nl` - Send newsletter via email

**Social Media Tasks:**
- `gen content` - Generate Twitter/X content
- `post-x` - Post to X/Twitter only
- `post-all` - Post to all enabled platforms

**Utility Tasks:**
- `status` - Check pipeline status for a date
- `full` - Run full_pipeline_orchestrator.py (complete newsletter + social media pipeline)

**Options:**
- `--date YYYY-MM-DD` - Specify date (defaults to today)
- `--json` - Output in JSON format
- `--dry-run` - Show what would happen without executing

**Examples:**
```
/pulse status
/pulse news update
/pulse read ranked
/pulse read x
/pulse read all
/pulse analyze
/pulse gen nl 
/pulse run nl pipeline
/pulse post-x
/pulse full
```

**Task Details:**

**`news update`** - Pulls RSS feeds and X summaries, ranks top 15 stories with Grok API, saves to:
- `news_letter/ranked_news/ranked_news_{date}.json`
- `news_letter/x_summaries/x_summaries_{date}.json`

**`gen nl`** - Generates newsletter using already-ranked news file for today (fast, no ranking)

**`run nl pipeline`** - Runs full newsletter_gen.py: pulls feeds, ranks, then generates newsletter

**`read ranked`** - Reads from: `news_letter/ranked_news/ranked_news_{date}.json` (top 15 stories)

**`read x`** - Reads from: `news_letter/x_summaries/x_summaries_{date}.json`

**`full`** - Runs full_pipeline_orchestrator.py: newsletter → send → generate content → post to social media

**Telegram Commands:**
Available via @KatanaAgent_bot:
- `/pulse` — Pipeline status (ranked news + final email file check)
- `/pulse news` — Top 5 headlines from ranked_news
- `/pulse stats` — Subscriber count from Supabase
- `/pulse newsletter` — Send today's newsletter content to you via Telegram
- `/pulse newsletter gen` — Generate newsletter (subprocess: `agent_orchestrator.py --task gen nl`)
- `/pulse send` — Send newsletter to subscribers (subprocess: `send_newsletter.py`)

**Implementation:**
1. Change to project directory: `/Users/sc/News Letter`
2. Execute: `python agent_orchestrator.py --task {task} {args}`
3. Parse output and report results
4. If errors occur, show traceback and suggest fixes
