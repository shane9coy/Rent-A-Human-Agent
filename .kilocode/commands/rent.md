---
name: rent
description: Rent-A-Human-Agent - Delegate tasks to real humans via RentAHuman.ai MCP server. Search for humans, manage bounties, handle conversations, and delegate complex tasks that AI cannot complete.
---

**IMPORTANT: When this command is invoked, IMMEDIATELY print the command menu below FIRST, then ask the user what they'd like to do. Do not skip the menu.**

## On Invoke — Print This Menu

When the user runs `/rent` (with no arguments), display this exact block:

```
RENT-A-HUMAN

/rent                — Browse available humans
/rent status         — Connection check
/rent bounties       — Browse open bounties/jobs
/rent skills         — Available skills
/rent scan           — AI-scored opportunities (48hrs)
/rent scan new       — Only unseen bounties
/rent scan all       — Score ALL open bounties
/rent scan force     — Bypass cache, fresh Grok scoring
/rent save <id>      — Save a bounty
/rent saved          — View saved bounties
/rent unsave <id>    — Remove saved
/rent post <desc>    — Post a bounty

What would you like to do?
```

If the user passes an argument (e.g. `/rent scan`), skip the menu and execute that command directly.

---

## Scan Commands — How They Work

When the user runs any `/rent scan` variant, **execute the bounty scanner script** and display the results:

```bash
python3 "/Users/sc/News Letter/bounty_hunter.py"
```

The scanner:
1. Checks the cache file at `logs/bounties_cache.json` — if scored within the last 12 hours, returns cached results instantly
2. If cache is stale, pulls fresh bounties from the RentAHuman API
3. Sends the batch to **Grok (grok-3-mini-fast)** via xAI API for AI scoring (0-100 with reasoning)
4. Saves scored results to `logs/bounties_cache.json`
5. Returns formatted digest

**Scan variants:**
- `/rent scan` → Run script normally (uses cache if fresh)
- `/rent scan new` → Only unseen bounties
- `/rent scan all` → Score ALL open bounties (top 10)
- `/rent scan force` → Bypass 12-hour cache, re-score with Grok now

After running the script, **read `logs/bounties_cache.json`** and display the results to the user. If the script fails, show the error output.

---

## Full Command Tree

```
/rent
 |
 |-- FIND PEOPLE
 |   /rent skills                          List all available human skills
 |   /rent search <skill>                  Find humans (e.g., "web dev", "errands")
 |   /rent search <skill> --max-rate 75    Find humans under $75/hr
 |   /rent human <human_id>                Full profile + availability + reviews
 |   /rent reviews <human_id>              Ratings and past work
 |
 |-- SCAN & SAVE (AI-Powered)
 |   /rent scan                            AI-score bounties from last 48hrs
 |   /rent scan new                        Only show unseen bounties
 |   /rent scan all                        Score ALL open bounties (top 10)
 |   /rent scan force                      Bypass 12hr cache, fresh Grok scoring
 |   /rent save <bounty_id>                Save a bounty for later
 |   /rent saved                           View saved bounties
 |   /rent unsave <bounty_id>              Remove from saved
 |
 |-- POST A JOB (Bounty)
 |   /rent post <title> : <description>    Quick-post a bounty
 |   /rent post <title> : <desc> --budget 100 --hours 2
 |   /rent bounties                        List your active bounties
 |   /rent bounty <bounty_id>              Bounty details
 |   /rent applications <bounty_id>        See who applied
 |   /rent accept <application_id>         Hire the applicant
 |   /rent cancel <bounty_id>              Cancel a bounty
 |
 |-- CONVERSATIONS (hire_team.py CLI)
 |   /rent talk <human_id> : <message>     Start a conversation (uses hire_team.py)
 |   /rent reply <convo_id> : <message>    Send a message (uses hire_team.py)
 |   /rent convo <convo_id>                Read full conversation (uses hire_team.py)
 |   /rent convos                          List all conversations (uses hire_team.py)
 |
 |-- PROFILE & APPLICATIONS (hire_team.py CLI)
 |   /rent profile <human_id>              View full human profile (uses hire_team.py)
 |   /rent bounty-apps <bounty_id>         View bounty applications (uses hire_team.py)
 |   /rent bounty-accept <bid> <app_id>   Accept applicant (uses hire_team.py)
 |
 |-- ACCOUNT
 |   /rent whoami                          Your agent identity
 |   /rent keys                            List API keys
 |   /rent keys create <name>              Create new key (max 3)
 |   /rent keys revoke <key_id>            Revoke a key
 |
 |-- STATUS
 |   /rent status                          Connection check + rate limit usage
```

## Quick Examples

**"I need someone to pick up a package"**
```
/rent search "errands"
/rent post Package Pickup : Pick up package from FedEx on 5th Ave, deliver to 123 Main St. Tomorrow 2-4pm. --budget 40 --hours 1
```

**"Find me a photographer for Saturday"**
```
/rent search "photography" --max-rate 100
/rent human human_abc123
/rent talk human_abc123 : Need a photographer for 2hr product shoot Saturday afternoon in Brooklyn. Are you free?
```

**"Check on my open jobs"**
```
/rent bounties
/rent applications bounty_789
/rent accept app_101
```

---

## How It Works

Two ways to hire:

**Direct:** Search → Profile → Start conversation → Negotiate → Book
**Bounty:** Post job → Humans apply → Review applications → Accept → Done

Payment is handled via Stripe Connect escrow on RentAHuman.ai.

## MCP Tools (what the agent calls under the hood)

| Command | MCP Tool | API Endpoint |
|---------|----------|-------------|
| `/rent skills` | `list_skills` | `GET /api/humans` |
| `/rent search` | `search_humans` | `GET /api/humans?skill=...` |
| `/rent human` | `get_human` | `GET /api/humans/:id` |
| `/rent reviews` | `get_reviews` | `GET /api/humans/:id` |
| `/rent post` | `create_bounty` | `POST /api/bookings` |
| `/rent bounties` | `list_bounties` | `GET /api/bookings` |
| `/rent bounty` | `get_bounty` | `GET /api/bookings/:id` |
| `/rent applications` | `get_bounty_applications` | `GET /api/bookings/:id` |
| `/rent accept` | `accept_application` | `PATCH /api/bookings/:id` |
| `/rent cancel` | `update_bounty` | `PATCH /api/bookings/:id` |
| `/rent talk` | `start_conversation` | — |
| `/rent reply` | `send_message` | — |
| `/rent convo` | `get_conversation` | — |
| `/rent convos` | `list_conversations` | — |
| `/rent whoami` | `get_agent_identity` | — |

## hire_team.py CLI (Alternative to MCP)

For conversations, bounties, and profile viewing, you can also use the `hire_team.py` CLI directly:

```bash
# Search for humans
python hire_team.py "Need photographer for Tokyo event"
python hire_team.py --roles photographer,videographer --location Tokyo

# Conversations
python hire_team.py talk <human_id> "Hey, are you available?"
python hire_team.py reply <convo_id> "Sounds good!"
python hire_team.py convo <convo_id>
python hire_team.py convos

# Bounties
python hire_team.py bounty "Task Title" --description "Details" --price 100 --hours 2
python hire_team.py bounty-apps <bounty_id>
python hire_team.py bounty-accept <bounty_id> <application_id>

# Utilities
python hire_team.py skills
python hire_team.py profile <human_id>
```

**Import into Python:**
```python
from hire_team import create_bounty, start_conversation, send_message, search_humans, list_skills
```

**Location:** `/Users/sc/News Letter/hire_team.py`

## Rate Limits

| Action | Limit |
|--------|-------|
| Bounties | 5/day |
| Conversations | 50/day |
| Messages | 30/hour |
| API keys | 3 active max |

## Telegram Access

From @KatanaAgent_bot, all core commands are available:

| Command | Description |
|---------|-------------|
| `/rent` | Browse available humans |
| `/rent status` | Connection check |
| `/rent bounties` | Browse open bounties/jobs |
| `/rent skills` | Available skills |
| `/rent scan` | AI-scored opportunities (48hrs) |
| `/rent scan new` | Only unseen bounties |
| `/rent scan all` | Score ALL open bounties (top 10) |
| `/rent scan force` | Bypass cache, fresh Grok scoring |
| `/rent save <id>` | Save a bounty |
| `/rent saved` | View saved bounties |
| `/rent unsave <id>` | Remove saved |
| `/rent post <desc>` | Post a bounty (first sentence = title) |

Advanced MCP-only commands (conversations, applications, account) require the Claude terminal.

## Config

**MCP server** (`.claude/settings.json`):
```json
"rentahuman": {
  "command": "npx",
  "args": ["rentahuman-mcp"],
  "env": { "RENTAHUMAN_API_KEY": "${RENTAHUMAN_API_KEY}" }
}
```

**REST API** (for Telegram bot): `https://rentahuman.ai/api` with header `X-API-Key: rah_...`

**Agent type**: `"agentType": "claude"` — identifies your agent on the platform.
