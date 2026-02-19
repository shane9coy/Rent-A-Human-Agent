# KATANA AGENT — Project Memory

**Project:** Katana Agent — Personal Life Orchestrator  
**Stack:** Claude Code + MCP servers + Python scripts  
**Root:** `/Users/sc/News Letter/`  
**Profile:** `.claude/user_profile.json`  
**Location:** Sandusky, OH (lat: 41.4489, lon: -82.708)

---

## Agent Roster

| Agent | Command | What It Does |
|-------|---------|-------------|
| **Master** | `/master-agent` | Root orchestrator — morning routine, profile mgmt, delegates to all agents |
| **Oracle** | `/oracle` | Astrology — birth charts, transits, moon phases, timing guidance |
| **Vibe Curator** | `/vibe` | Daily recs + action engine — music, food, clothing, events, orders, reservations |
| **Pulse** | `/pulse` | Newsletter pipeline — RSS ranking, gen, send, social posting |
| **Telegram** | `/telegram` | Always-listening daemon — two-way chat, task/goal tracking, scheduled alerts |
| **Voice** | `/voice` | Voice conversation loop — speak/listen via MCP voice tools |
| **Playwright** | `/playwright` | Browser automation — reservations, ordering, scraping, form filling |
| **Reddit Bot** | `/reddit-bot` | Reddit marketing — comment automation, subreddit discovery, analytics |
| **X Thread** | `/x-thread` | Twitter/X — draft and post single tweets and threads |
| **Rent** | `/rent` | Delegate to real humans via RentAHuman.ai — bounties, conversations |

---

## Key File Paths

| File | Purpose |
|------|---------|
| `.claude/user_profile.json` | All user prefs, birth data, telegram config, daily tracker |
| `.claude/commands/` | Full agent command docs (source of truth) |
| `.claude/skills/` | Auto-detection skill triggers |
| `agent_orchestrator.py` | CLI backend — `python agent_orchestrator.py --task <task>` |
| `master_life_orchestrator.py` | Master agent Python entry point |
| `oracle_personality.py` | Oracle tone/prompt config |
| `send_newsletter.py` | Newsletter email sender |
| `telegram_listener.py` | Always-listening Telegram daemon |
| `telegram_helpers.py` | Telegram helper utilities |
| `hire_team.py` | RentAHuman CLI — `/Users/sc/News Letter/hire_team.py` |
| `bounty_hunter.py` | Grok-scored bounty scanner — `logs/bounties_cache.json` |
| `post_to_x.py` | X/Twitter posting script |
| `news_letter/ranked_news/` | Ranked news JSON files by date |
| `news_letter/x_summaries/` | X feed summaries by date |
| `/tmp/telegram_agent_queue.json` | Queued Playwright tasks from Telegram |
| `/tmp/telegram_listener.pid` | Telegram daemon PID |
| `/tmp/telegram_listener_state.json` | Daemon sleep/wake state |
| `logs/telegram_listener.log` | Telegram daemon logs |

---

## MCP Servers

| Server | Key Tools | Notes |
|--------|-----------|-------|
| `playwright` | navigate, screenshot, click, fill, evaluate | Browser automation — always confirm before transact |
| `natal` | create_natal_chart, create_transit_chart, create_synastry_chart | Astrology — requires local install `pip install natal-mcp` |
| `calendar` | list_events, search_events | Google Calendar |
| `gmail` | list_messages, search_messages | Gmail — used by master morning routine |
| `telegram-mcp` | send_message, get_messages | Telegram bot @KatanaAgent_bot |
| `voice` | voice_speak, voice_listen, voice_mode | Voice conversation loop |
| `rentahuman` | search_humans, create_bounty, list_bounties | RentAHuman.ai |

---

## Environment Variables

| Var | Used By |
|-----|---------|
| `NATAL_MCP_HOME` | Oracle — `~/natal_mcp` |
| `RENTAHUMAN_API_KEY` | Rent — `rah_...` |
| `XAI_API_KEY` | Rent bounty scanner (Grok scoring), Pulse (news ranking) |
| `VIBE_PLAYWRIGHT_ENABLED` | Vibe Curator — set `false` for recs-only mode |
| `VIBE_ACTION_DEBUG` | Vibe Curator — verbose action routing logs |

---

## Behavioral Conventions

**Always-confirm before transacting.** Playwright transactional actions (orders, purchases, bookings) stop for explicit user confirmation — never auto-submit.

**Profile-first.** Check `.claude/user_profile.json` before fetching external data. If `profile_status` is not `"complete"`, prompt setup.

**Delegation chain.** Master → sub-agents. Don't reimplement what an agent already does. Vibe Curator owns food/music/activity recs. Oracle owns all astrology. Pulse owns newsletter. Telegram is the notification bus.

**Weather source.** Open-Meteo API (free, no key needed). Use WMO codes for indoor/outdoor routing.

**Telegram queue.** Playwright tasks triggered from Telegram are written to `/tmp/telegram_agent_queue.json` with `status: "pending"`. Process with `--task process-queue`.

**Morning threshold.** Master agent auto-runs morning routine only before 10:30 AM. After that, respond to explicit requests only.

**Stock symbols.** Always prefix with `$` in X threads (e.g., `$TSLA`, `$NVDA`).

**Voice mode.** Continuous speak→listen loop. Never drop to text on timeout — retry up to 3×.

**Oracle tone.** Optimistic, empowering, grounded in chart data. Never fear-monger.

---

## User Profile Schema (key fields)

```json
{
  "profile_status": "complete",
  "basic_info": { "name": "", "email": "", "timezone": "America/New_York" },
  "birth_chart": { "datetime": "", "location": { "name": "", "latitude": 0, "longitude": 0 } },
  "preferred_music": { "music_types": [] },
  "preferred_food": { "food": { "cuisines": [], "dietary_restrictions": [] } },
  "preferred_activities": { "activities": [], "places": [] },
  "telegram": { "chat_id": null, "morning_brief": true, "goal_checkin_time": "20:00", "always_listening": true },
  "daily_tracker": { "tasks": [], "goals": [], "habits": [], "streak": 0, "projects": {} }
}
```

---

## Daily Tracker Commands (via Telegram)

`add task:` / `tasks` / `done:` / `add goal:` / `goals` / `add habit:` / `habit done:` / `habits` / `add project:` / `add to <project>:` / `projects` / `progress`

---

## Pulse Pipeline

```
news update → gen nl → send nl → gen content → post-x
(or: /pulse full — runs full_pipeline_orchestrator.py end-to-end)
```

News files: `news_letter/ranked_news/ranked_news_{date}.json`

---

## Rent Rate Limits

Bounties: 5/day | Conversations: 50/day | Messages: 30/hr | API keys: 3 max
