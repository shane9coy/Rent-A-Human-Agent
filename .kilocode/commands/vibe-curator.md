---
name: vibe
description: Vibe Curator Agent - Personalized daily recommendations + action execution for music, food, activities, clothing, events, reservations, purchases, and tickets. Integrates weather, astrology, user preferences, and Playwright browser automation for end-to-end fulfillment.
---

## Vibe Curator Agent - Your Daily Vibe Guide + Action Engine

The Vibe Curator is a warm, intuitive guide that helps users craft their perfect day AND act on it. It blends:
- **Real-time weather data** (via Open-Meteo)
- **Astrological context** (via natal_mcp)
- **User preferences** from `.claude/user_profile.json`
- **Energy level** from morning check-in
- **Action execution** via Playwright browser automation (reservations, tickets, orders, event lookups)

**Usage:** `/vibe [command]`

---

## Architecture: Recommend → Act Pipeline

The Vibe Curator follows a two-phase model:

```
Phase 1: RECOMMEND (always runs - no Playwright needed)
  Weather + Profile + Astrology + Energy → Personalized suggestions

Phase 2: ACT (optional - triggered by user confirmation or /vibe action commands)
  Suggestion → Intent → Action Router → Playwright (if needed) or API
```

**Key principle:** Playwright is a backend tool, not a separate agent. The vibe-curator decides when to use it internally via the Action Router.

---

## Core Commands

### 1. Full Daily Vibe
```
/vibe today
/vibe check-in
```
Returns complete daily recommendations:
- **Daily Vibe Phrase** (e.g., "Clear & Radiant + Electric")
- **Clothing advice** based on weather
- **Food/restaurant suggestions** based on preferences + weather
- **Music recommendations** based on energy + preferences
- **Activity/place suggestions** weather-aware (indoor vs outdoor)
- **Local events** (searched via web or Playwright)
- **Inspiration** (quote, life advice, or fun fact)
- **Quick actions** offered inline (e.g., "Want me to book a table?")

### 2. Quick Vibe Check
```
/vibe quick
/vibe fast
```
Brief vibe check without full breakdown.

### 3. Food Recommendations + Ordering
```
/vibe food
/vibe eat
/vibe restaurants
/vibe order <restaurant or food>
/vibe book <restaurant>
```
Food suggestions based on profile + weather, with optional action:
- `/vibe food` → recommendations only
- `/vibe order dominos` → triggers DoorDash/UberEats via Playwright
- `/vibe book italian bistro` → triggers OpenTable via Playwright

### 4. Music Recommendations
```
/vibe music
/vibe playlist
```
Music based on energy + preferences + time of day.

### 5. Activity + Event Suggestions
```
/vibe activity
/vibe things to do
/vibe places
/vibe events
/vibe events <query>
/vibe events this weekend
```
Activities from profile + weather routing, PLUS live event lookups:
- `/vibe activity` → from profile preferences
- `/vibe events` → searches local events (Sandusky/Erie County area)
- `/vibe events concerts this weekend` → targeted event search

### 6. Tickets + Event Booking
```
/vibe tickets <event>
/vibe tickets cedar point
/vibe tickets <concert name>
```
Checks ticket availability via Playwright (Ticketmaster, Eventbrite, venue sites):
- Shows pricing, sections, availability
- Stops before purchase — always asks for confirmation

### 7. Reservations
```
/vibe reserve <restaurant> [date] [time] [party size]
/vibe book <restaurant>
```
Books restaurant reservations via Playwright (OpenTable, Resy):
- Uses profile location (Sandusky, OH) as default
- Stops before final confirmation

### 8. Shopping / Purchases
```
/vibe buy <item>
/vibe shop <item>
/vibe price-check <item>
```
Product search + cart via Playwright (Amazon, etc.):
- `/vibe buy wireless headphones` → search + add to cart (no checkout)
- `/vibe price-check airpods` → multi-site price comparison

### 9. Clothing Advice
```
/vibe clothing
/vibe what to wear
/vibe outfit
```

### 10. Weather-Aware Planning
```
/vibe weather
/vibe outdoor
/vibe indoor
```

### 11. Inspiration / Wisdom
```
/vibe inspire
/vibe quote
/vibe wisdom
```

---

## Action Router — How Commands Become Actions

The Action Router is the brain that maps vibe recommendations and explicit commands into executable actions. It decides whether an action needs Playwright or can be handled via API/locally.

### Intent Classification

```
User input → Parse intent → Route to handler

INTENT TYPES:
┌─────────────────┬──────────────────────┬─────────────────────────┐
│ Intent          │ Handler              │ Requires Playwright?    │
├─────────────────┼──────────────────────┼─────────────────────────┤
│ recommend_food  │ profile + weather    │ No                      │
│ recommend_music │ profile + energy     │ No                      │
│ recommend_activity│ profile + weather  │ No                      │
│ lookup_events   │ web search first,    │ Fallback only           │
│                 │ then Playwright      │                         │
│ lookup_tickets  │ Playwright           │ Yes (recon only)        │
│ book_restaurant │ Playwright           │ Yes (OpenTable/Resy)    │
│ order_food      │ Playwright           │ Yes (DoorDash/UberEats) │
│ buy_product     │ Playwright           │ Yes (Amazon etc.)       │
│ price_compare   │ Playwright           │ Yes (multi-site)        │
│ check_weather   │ Open-Meteo API       │ No                      │
│ get_horoscope   │ natal_mcp            │ No                      │
│ get_inspiration │ local/LLM            │ No                      │
└─────────────────┴──────────────────────┴─────────────────────────┘
```

### Routing Logic (Python)

```python
# In action_router.py

from enum import Enum
from dataclasses import dataclass
from typing import Optional
import json, re

class ActionType(Enum):
    RECOMMEND = "recommend"       # No browser needed
    LOOKUP = "lookup"             # Try API/search first, Playwright fallback
    TRANSACT = "transact"         # Requires Playwright + confirmation

class PlaywrightProfile(Enum):
    MAIN = "playwright-main"
    SHOPPING = "playwright-shopping"
    TRAVEL = "playwright-travel"
    RESERVATIONS = "playwright-reservations"
    ENHANCED = "playwright-enhanced"

@dataclass
class ActionIntent:
    intent: str
    action_type: ActionType
    playwright_profile: Optional[PlaywrightProfile]
    target: str                   # restaurant name, event, product, etc.
    params: dict                  # date, time, party_size, budget, etc.
    requires_confirmation: bool
    safety_level: str             # "safe", "caution", "high_risk"

class ActionRouter:
    """Routes vibe commands to the appropriate handler."""

    # Pattern matching for command parsing
    PATTERNS = {
        r"/vibe\s+order\s+(.+)": ("order_food", ActionType.TRANSACT, PlaywrightProfile.MAIN),
        r"/vibe\s+book\s+(.+)": ("book_restaurant", ActionType.TRANSACT, PlaywrightProfile.RESERVATIONS),
        r"/vibe\s+reserve\s+(.+)": ("book_restaurant", ActionType.TRANSACT, PlaywrightProfile.RESERVATIONS),
        r"/vibe\s+tickets?\s+(.+)": ("lookup_tickets", ActionType.LOOKUP, PlaywrightProfile.ENHANCED),
        r"/vibe\s+events?\s+(.+)": ("lookup_events", ActionType.LOOKUP, PlaywrightProfile.MAIN),
        r"/vibe\s+buy\s+(.+)": ("buy_product", ActionType.TRANSACT, PlaywrightProfile.SHOPPING),
        r"/vibe\s+shop\s+(.+)": ("buy_product", ActionType.TRANSACT, PlaywrightProfile.SHOPPING),
        r"/vibe\s+price[- ]?check\s+(.+)": ("price_compare", ActionType.LOOKUP, PlaywrightProfile.SHOPPING),
        r"/vibe\s+(food|eat|restaurants?)$": ("recommend_food", ActionType.RECOMMEND, None),
        r"/vibe\s+(music|playlist)$": ("recommend_music", ActionType.RECOMMEND, None),
        r"/vibe\s+(activity|things to do|places)$": ("recommend_activity", ActionType.RECOMMEND, None),
        r"/vibe\s+events?$": ("lookup_events", ActionType.LOOKUP, PlaywrightProfile.MAIN),
        r"/vibe\s+(today|check-?in)$": ("full_vibe", ActionType.RECOMMEND, None),
        r"/vibe\s+(quick|fast)$": ("quick_vibe", ActionType.RECOMMEND, None),
        r"/vibe\s+(weather|outdoor|indoor)$": ("check_weather", ActionType.RECOMMEND, None),
        r"/vibe\s+(clothing|outfit|what to wear)$": ("recommend_clothing", ActionType.RECOMMEND, None),
        r"/vibe\s+(inspire|quote|wisdom|fun[- ]?fact)$": ("get_inspiration", ActionType.RECOMMEND, None),
    }

    def __init__(self, user_profile_path=".claude/user_profile.json"):
        with open(user_profile_path) as f:
            self.profile = json.load(f)
        self.location = self.profile.get("birth_chart", {}).get("location", {})

    def parse(self, command: str) -> ActionIntent:
        """Parse a /vibe command into an ActionIntent."""
        command = command.strip().lower()

        for pattern, (intent, action_type, pw_profile) in self.PATTERNS.items():
            match = re.match(pattern, command, re.IGNORECASE)
            if match:
                target = match.group(1) if match.lastindex else ""
                return ActionIntent(
                    intent=intent,
                    action_type=action_type,
                    playwright_profile=pw_profile,
                    target=target.strip(),
                    params=self._extract_params(intent, target),
                    requires_confirmation=(action_type == ActionType.TRANSACT),
                    safety_level=self._get_safety_level(intent),
                )

        # Default: full vibe
        return ActionIntent(
            intent="full_vibe",
            action_type=ActionType.RECOMMEND,
            playwright_profile=None,
            target="",
            params={},
            requires_confirmation=False,
            safety_level="safe",
        )

    def _extract_params(self, intent: str, target: str) -> dict:
        """Extract structured params from freeform target text."""
        params = {
            "location": self.location.get("name", "Sandusky, Ohio"),
            "timezone": self.profile.get("basic_info", {}).get("timezone", "America/New_York"),
        }

        # Parse date/time from target (e.g., "italian bistro friday 7pm party of 4")
        time_match = re.search(r"(\d{1,2})\s*(?::(\d{2}))?\s*(am|pm)", target, re.I)
        if time_match:
            params["time"] = time_match.group(0)

        party_match = re.search(r"(?:party\s+(?:of\s+)?|for\s+)(\d+)", target, re.I)
        if party_match:
            params["party_size"] = int(party_match.group(1))

        date_match = re.search(
            r"(today|tonight|tomorrow|this weekend|friday|saturday|sunday|monday|tuesday|wednesday|thursday)",
            target, re.I,
        )
        if date_match:
            params["date"] = date_match.group(0)

        budget_match = re.search(r"under\s+\$?(\d+)", target, re.I)
        if budget_match:
            params["budget"] = int(budget_match.group(1))

        return params

    def _get_safety_level(self, intent: str) -> str:
        safety_map = {
            "order_food": "caution",
            "book_restaurant": "caution",
            "buy_product": "high_risk",
            "lookup_tickets": "caution",
            "price_compare": "safe",
            "lookup_events": "safe",
        }
        return safety_map.get(intent, "safe")

    def needs_playwright(self, intent: ActionIntent) -> bool:
        """Check if this action requires Playwright browser automation."""
        return intent.playwright_profile is not None

    def get_playwright_server(self, intent: ActionIntent) -> Optional[str]:
        """Get the MCP server name to use for this action."""
        if intent.playwright_profile:
            return intent.playwright_profile.value
        return None
```

### Playwright Action Templates (Python)

```python
# In playwright_actions.py

"""
Pre-built Playwright action sequences that the vibe-curator
invokes through MCP tool calls. These are NOT separate agents —
they're structured tool-call sequences the main agent executes.
"""

class PlaywrightActions:
    """Generates MCP tool-call sequences for browser actions."""

    @staticmethod
    def book_restaurant(restaurant: str, location: str, date: str = "today",
                        time: str = "7:00 PM", party_size: int = 2) -> list[dict]:
        """Return the MCP tool-call sequence for OpenTable reservation."""
        return [
            {"tool": "mcp__playwright__navigate", "args": {"url": "https://www.opentable.com"}},
            {"tool": "mcp__playwright__screenshot", "args": {}},
            # Search for restaurant
            {"tool": "mcp__playwright__fill", "args": {
                "selector": "input[aria-label*='Location']",
                "value": f"{restaurant} {location}"
            }},
            # Date + time + party size selection
            {"tool": "mcp__playwright__fill", "args": {
                "selector": "input[aria-label*='Date']",
                "value": date
            }},
            # ... dynamic steps based on page state
            {"tool": "mcp__playwright__screenshot", "args": {}},
            # STOP — return screenshot for confirmation
        ]

    @staticmethod
    def order_food(restaurant: str, items: list[str], platform: str = "doordash") -> list[dict]:
        """Return the MCP tool-call sequence for food ordering."""
        urls = {
            "doordash": "https://www.doordash.com",
            "ubereats": "https://www.ubereats.com",
        }
        return [
            {"tool": "mcp__playwright__navigate", "args": {"url": urls.get(platform, urls["doordash"])}},
            {"tool": "mcp__playwright__screenshot", "args": {}},
            {"tool": "mcp__playwright__fill", "args": {
                "selector": "input[data-testid*='search'], input[placeholder*='Search']",
                "value": restaurant
            }},
            # ... item selection steps
            {"tool": "mcp__playwright__screenshot", "args": {}},
            # STOP — show cart total, ask for confirmation
        ]

    @staticmethod
    def lookup_events(query: str, location: str) -> list[dict]:
        """Search for local events. Try Eventbrite first, then Google Events."""
        return [
            {"tool": "mcp__playwright__navigate", "args": {
                "url": f"https://www.eventbrite.com/d/{location.replace(' ', '-').lower()}/{query.replace(' ', '-')}/"
            }},
            {"tool": "mcp__playwright__screenshot", "args": {}},
            {"tool": "mcp__playwright__content", "args": {}},
            # Parse events from page content
        ]

    @staticmethod
    def check_tickets(event: str, location: str) -> list[dict]:
        """Check ticket availability on Ticketmaster (recon only)."""
        return [
            {"tool": "mcp__playwright__navigate", "args": {
                "url": f"https://www.ticketmaster.com/search?q={event.replace(' ', '+')}"
            }},
            {"tool": "mcp__playwright__screenshot", "args": {}},
            {"tool": "mcp__playwright__content", "args": {}},
            # Parse results — NEVER proceed to purchase
        ]

    @staticmethod
    def search_product(query: str, budget: int = None) -> list[dict]:
        """Search Amazon for a product."""
        search_url = f"https://www.amazon.com/s?k={query.replace(' ', '+')}"
        if budget:
            search_url += f"&rh=p_36%3A-{budget}00"
        return [
            {"tool": "mcp__playwright__navigate", "args": {"url": search_url}},
            {"tool": "mcp__playwright__screenshot", "args": {}},
            {"tool": "mcp__playwright__content", "args": {}},
            # Parse top results
        ]

    @staticmethod
    def price_compare(product: str, sites: list[str] = None) -> list[dict]:
        """Compare prices across multiple sites."""
        if not sites:
            sites = ["amazon.com", "walmart.com", "bestbuy.com"]
        steps = []
        for site in sites:
            steps.extend([
                {"tool": "mcp__playwright__navigate", "args": {
                    "url": f"https://www.{site}/search?q={product.replace(' ', '+')}"
                }},
                {"tool": "mcp__playwright__screenshot", "args": {}},
                {"tool": "mcp__playwright__content", "args": {}},
            ])
        return steps
```

---

## Integration Flow: /vibe today with Actions

```
User: /vibe today

┌─────────────────────────────────────────────────┐
│ Step 1: Gather Data (no Playwright)             │
│  • Fetch weather via Open-Meteo API             │
│  • Load user_profile.json                       │
│  • Get astrology via natal_mcp                  │
│  • Check calendar via calendar MCP              │
└───────────────┬─────────────────────────────────┘
                │
┌───────────────▼─────────────────────────────────┐
│ Step 2: Generate Recommendations                │
│  • Daily vibe phrase                            │
│  • Clothing (weather-based)                     │
│  • Food (preferences + weather)                 │
│  • Music (energy + time of day)                 │
│  • Activities (weather routing)                 │
│  • Local events (web search, no Playwright)     │
│  • Inspiration quote                            │
└───────────────┬─────────────────────────────────┘
                │
┌───────────────▼─────────────────────────────────┐
│ Step 3: Present with Action Offers              │
│                                                 │
│  "Perfect evening for Italian on a patio!       │
│   🍝 Suggestion: Try Chez François in Huron     │
│   → Want me to check OpenTable availability?    │
│                                                 │
│   🎵 Your Focus Flow playlist matches today     │
│                                                 │
│   🎫 Cedar Point opens at 10am this weekend     │
│   → Want me to check ticket prices?             │
│                                                 │
│   🛒 You mentioned needing headphones           │
│   → Want me to search Amazon under $50?"        │
└───────────────┬─────────────────────────────────┘
                │
          User says "yes, book the restaurant"
                │
┌───────────────▼─────────────────────────────────┐
│ Step 4: Action Router → Playwright              │
│  • Intent: book_restaurant                      │
│  • Profile: playwright-reservations             │
│  • Target: Chez François, Huron OH              │
│  • Params: tonight, 7pm, party of 2             │
│  • Safety: CAUTION — stop before confirm        │
│  • Execute Playwright sequence                  │
│  • Screenshot → ask user to confirm             │
└─────────────────────────────────────────────────┘
```

---

## Confirmation & Safety Protocol

All transactional actions follow this safety flow:

```
1. PREVIEW  — Show what will happen (restaurant, items, price estimate)
2. EXECUTE  — Run Playwright sequence up to final step
3. PAUSE    — Screenshot the confirmation page
4. CONFIRM  — User must explicitly say "confirm" / "yes" / "go ahead"
5. COMPLETE — Submit only after confirmation
6. RECEIPT  — Screenshot final confirmation, send via Telegram if enabled

SAFETY LEVELS:
  safe     → No confirmation needed (weather, recommendations, event lookup)
  caution  → Pause before submit (reservations, food orders, ticket recon)
  high_risk→ Double confirmation (purchases, anything involving payment)
```

---

## Telegram Integration

Available via @KatanaAgent_bot:

| Command | Action | Playwright? |
|---------|--------|-------------|
| `/vibe` | Full daily vibe | No |
| `/vibe food` | Food recommendation | No |
| `/vibe music` | Music recommendation | No |
| `/vibe outfit` | What to wear | No |
| `/vibe activity` | Activity pick | No |
| `/vibe events` | Local event search | Fallback |
| `/vibe events <query>` | Targeted event search | Fallback |
| `/vibe tickets <event>` | Check ticket availability | Yes (recon) |
| `/vibe order <food>` | Order food delivery | Yes → queue |
| `/vibe book <restaurant>` | Restaurant reservation | Yes → queue |
| `/vibe buy <item>` | Amazon search + cart | Yes → queue |
| `/vibe price-check <item>` | Multi-site comparison | Yes |

**Queue behavior for Telegram:** Since Telegram can't display Playwright screenshots inline, transactional commands are queued to `/tmp/telegram_agent_queue.json` for the Claude Code agent to pick up in a terminal session where screenshots can be reviewed.

```json
// /tmp/telegram_agent_queue.json
{
  "queue": [
    {
      "id": "vibe-action-001",
      "timestamp": "2026-02-13T18:30:00Z",
      "source": "telegram",
      "chat_id": 6812925961,
      "intent": "book_restaurant",
      "target": "Chez François",
      "params": {
        "location": "Huron, OH",
        "date": "tonight",
        "time": "7:00 PM",
        "party_size": 2
      },
      "playwright_profile": "playwright-reservations",
      "status": "pending",
      "requires_confirmation": true
    }
  ]
}
```

---

## Event Lookup Strategy (Minimizing Playwright)

For event lookups, the agent tries **three tiers** before resorting to Playwright:

```
Tier 1: Web Search (no Playwright)
  → Claude's built-in web search for "events in Sandusky OH this weekend"
  → Fast, no browser needed, good for general results

Tier 2: API-based lookups (no Playwright)
  → Eventbrite API (if key configured)
  → Ticketmaster Discovery API (if key configured)
  → Google Events structured data

Tier 3: Playwright browser (fallback)
  → Only if Tiers 1-2 don't return good results
  → Or if user needs specific availability / pricing
  → Uses playwright-main or playwright-enhanced profile
```

This keeps the CLI bot fast and Playwright-free for 90% of use cases.

---

## How It Works — Data Sources

**User Profile (`.claude/user_profile.json`):**
- Preferred music, food, activities, places
- Location (Sandusky, OH — lat: 41.4489, lon: -82.708)
- Birth chart for astrology context
- Telegram chat_id for notifications
- Daily tracker for task-aware suggestions

**Weather Integration:**
- Open-Meteo API (free, no key)
- WMO codes for indoor/outdoor routing

**Astrology Integration:**
- natal_mcp for birth chart, transits, moon phase
- Moon phase affects activity recommendations

**Calendar Integration:**
- calendar MCP for existing events
- Avoids suggesting activities during busy times

---

## Weather-Aware Routing Logic

| WMO Code | Condition | Outdoor? | Recommendation |
|----------|-----------|----------|----------------|
| 0 | Clear sky | ✅ Yes | All outdoor activities |
| 1 | Mainly clear | ✅ Yes | All outdoor activities |
| 2 | Partly cloudy | ✅ Yes | All outdoor activities |
| 3 | Overcast | ⚠️ Caution | Outdoor with layers |
| 45-48 | Foggy | ❌ No | Indoor recommended |
| 51-67 | Rain | ❌ No | Indoor only |
| 71-77 | Snow | ❌ No | Indoor only |
| 80+ | Thunderstorm | ❌ No | Stay indoors |

---

## CLI Bot Integration

The vibe-curator is now integrated into `agent_orchestrator.py` with full ActionRouter support:

### Interactive Menu

```bash
python agent_orchestrator.py
# Option 32: vibe-check - Vibe Check (Music/Activity + Playwright Actions)
# Option 33: process-queue - Process pending Vibe actions from Telegram
```

### Headless Mode

```bash
# Recommendations only (fast, no browser)
python agent_orchestrator.py --task vibe-check

# With action execution (launches Playwright only when needed)
python agent_orchestrator.py --task vibe -- "/vibe book italian bistro tonight 7pm"
python agent_orchestrator.py --task vibe -- "/vibe order pizza"
python agent_orchestrator.py --task vibe -- "/vibe tickets cedar point"

# Process Telegram queue
python agent_orchestrator.py --task process-queue
```

### Interactive Vibe Check

When you select Option 32, you'll see:

```
Available commands:
  /vibe today        - Full daily vibe check
  /vibe food         - Food recommendations
  /vibe music        - Music recommendations
  /vibe activity     - Activity suggestions
  /vibe events       - Local events lookup
  /vibe book <name>  - Book a reservation
  /vibe order <food> - Order food delivery
  /vibe tickets <event> - Check ticket availability
  /vibe buy <item>   - Search products

Enter /vibe command (or energy level 1-10):
```

### Action Routing

The ActionRouter parses your command and routes it appropriately:

| Intent | Type | Playwright? | Confirmation |
|--------|------|-------------|--------------|
| `recommend_food` | RECOMMEND | No | No |
| `recommend_music` | RECOMMEND | No | No |
| `recommend_activity` | RECOMMEND | No | No |
| `lookup_events` | LOOKUP | Fallback | No |
| `lookup_tickets` | LOOKUP | Yes (recon) | No |
| `book_restaurant` | TRANSACT | Yes | Yes (caution) |
| `order_food` | TRANSACT | Yes | Yes (caution) |
| `buy_product` | TRANSACT | Yes | Yes (high_risk) |

### Environment Variable Control

```bash
# Disable Playwright entirely (recommendations only mode)
export VIBE_PLAYWRIGHT_ENABLED=false

# Enable verbose logging for action routing
export VIBE_ACTION_DEBUG=true
```

### Telegram Queue Integration

Transactional commands from Telegram are queued to `/tmp/telegram_agent_queue.json`:

```json
{
  "queue": [
    {
      "id": "vibe-action-1234567890",
      "timestamp": "2026-02-13T18:30:00",
      "source": "telegram",
      "chat_id": 123456789,
      "intent": "book_restaurant",
      "target": "italian bistro",
      "params": {"time": "7pm", "party_size": 4},
      "status": "pending",
      "requires_confirmation": true,
      "safety_level": "caution"
    }
  ]
}
```

Process the queue with Option 33 or `--task process-queue`.

---

## Settings.json — Required MCP Servers

Ensure these servers are in `.claude/settings.json` `allowedTools`:

```json
{
  "permissions": {
    "allowedTools": [
      "mcp__playwright__navigate",
      "mcp__playwright__screenshot",
      "mcp__playwright__click",
      "mcp__playwright__fill",
      "mcp__playwright__content",
      "mcp__playwright__title",
      "mcp__playwright__url",
      "mcp__playwright__wait_for_selector",
      "mcp__playwright__wait_for_navigation",
      "mcp__playwright__evaluate",
      "mcp__playwright__get_links",
      "mcp__playwright__get_forms",
      "mcp__playwright__save_state",
      "mcp__playwright__close",
      "mcp__calendar__list_events",
      "mcp__calendar__search_events",
      "mcp__natal__create_transit_chart",
      "mcp__natal__get_chart_data",
      "mcp__telegram__send_message",
      "mcp__telegram__send_photo"
    ]
  }
}
```

---

## Future Enhancements

1. **API-first event lookups** — Eventbrite/Ticketmaster Discovery APIs to skip Playwright for 95% of lookups
2. **Location-aware GPS** — Use phone GPS for nearby suggestions
3. **Calendar-aware scheduling** — "You're free 6-9pm, perfect for dinner"
4. **Historical patterns** — Learn from accepted/rejected suggestions
5. **Social integration** — Friend activity suggestions
6. **Multi-step workflows** — "Find Italian restaurant → check reviews → book table → add to calendar → set reminder"
7. **Receipt tracking** — Screenshot order confirmations, save to profile
8. **Budget awareness** — Track spending against preferences
