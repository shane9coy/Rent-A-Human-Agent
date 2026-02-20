═══════════════════════════════════════════════════════════════════════════════
MCP CONFIGURATION  SUMMARY
═══════════════════════════════════════════════════════════════════════════════
───────────────────────────────────────────────────────────────────────────────
───────────────────────────────────────────────────────────────────────────────
SUMMARY
───────────────────────────────────────────────────────────────────────────────
Added 7 rentahuman MCP tools to the allowedTools list in .claude/settings.json:

1. mcp__rentahuman__search_humans
   - Searches for available humans by skill/location
   - Returns list of candidates with rates and profiles

2. mcp__rentahuman__create_bounty
   - Creates new bounty on RentAHuman.ai
   - Requires title, description, price, hours

3. mcp__rentahuman__list_bounties
   - Lists available bounties (public or owned)
   - Used for browsing opportunities

4. mcp__rentahuman__get_human_profile
   - Retrieves detailed profile for a specific human
   - Includes skills, rates, reviews, availability

5. mcp__rentahuman__send_message
   - Sends direct message to a human
   - Used for negotiations and inquiries

6. mcp__rentahuman__view_conversations
   - Retrieves conversation history with a human
   - Shows all prior messages and context

7. mcp__rentahuman__get_bounty_details
   - Gets full details for a specific bounty
   - Includes applications, status, timeline

───────────────────────────────────────────────────────────────────────────────
IMPLEMENTATION STRATEGY
───────────────────────────────────────────────────────────────────────────────

BOUNTY SCANNING (USE PYTHON SCRIPTS):
  ✓ Keep: bounty_hunter.py (uses Grok for scoring, cached 12hr)
  ✓ Keep: hire_team.py CLI (tested and working)
  Reason: Already optimized with caching and Grok scoring

REAL-TIME OPERATIONS (USE MCP):
  ✓ Use: mcp__rentahuman__search_humans
     When: Need live search for photographers, developers, etc.
  ✓ Use: mcp__rentahuman__get_human_profile
     When: Retrieving detailed info for a specific candidate
  ✓ Use: mcp__rentahuman__send_message
     When: Direct communication with humans (no subprocess overhead)
  ✓ Use: mcp__rentahuman__create_bounty
     When: Posting new opportunities programmatically

HYBRID WORKFLOW:
  1. Bounty scanning → bounty_hunter.py (Grok-scored, cached)
  2. Human search → rentahuman MCP (real-time, no cache)
  3. Detailed lookup → MCP get_human_profile
  4. Send messages → MCP send_message (direct API, not CLI)
  5. View history → MCP view_conversations

───────────────────────────────────────────────────────────────────────────────
FILES MODIFIED
───────────────────────────────────────────────────────────────────────────────

.claude/settings.json
  Section: permissions > allowedTools
  Lines Added: 7 new mcp__rentahuman__* entries
  Location: After "mcp__telegram__search_contacts"

───────────────────────────────────────────────────────────────────────────────
STEPS TO APPLY TO ANOTHER PROJECT
───────────────────────────────────────────────────────────────────────────────

1. Open .claude/settings.json in the target project

2. Locate: "mcp__telegram__search_contacts"

3. Replace:
   ────────────────────────────────────────────────────────────────
   OLD:
   "mcp__telegram__search_contacts"
   ],

   NEW:
   "mcp__telegram__search_contacts",
   "mcp__rentahuman__search_humans",
   "mcp__rentahuman__create_bounty",
   "mcp__rentahuman__list_bounties",
   "mcp__rentahuman__get_human_profile",
   "mcp__rentahuman__send_message",
   "mcp__rentahuman__view_conversations",
   "mcp__rentahuman__get_bounty_details"
   ],
   ────────────────────────────────────────────────────────────────

4. Verify rentahuman MCP server is configured in mcpServers:
   ```json
   "rentahuman": {
     "command": "npx",
     "args": ["-y", "rentahuman-mcp"],
     "env": {
       "RENTAHUMAN_API_KEY": "${RENTAHUMAN_API_KEY}"
     }
   }
   ```

5. Test with: /rent search photographer
   Should now use MCP instead of CLI subprocess

───────────────────────────────────────────────────────────────────────────────
BENEFITS OF THIS CHANGE
───────────────────────────────────────────────────────────────────────────────

✓ Reduced subprocess overhead (no shell spawning)
✓ Better error handling and retry logic
✓ Real-time API access (no caching delays for human search)
✓ Structured tool access (proper MCP integration)
✓ Agent orchestration alignment (all skills use MCP)
✓ Future-proof (ready for multi-agent coordination)

Keep Python scripts for:
  ✗ Bounty scanning (already Grok-scored and cached, no need to change)

───────────────────────────────────────────────────────────────────────────────
TESTING CHECKLIST FOR TARGET PROJECT
───────────────────────────────────────────────────────────────────────────────

[ ] /rent skills — Lists available human skills
[ ] /rent search photographer — Searches for photographers (uses MCP)
[ ] /rent status — Checks connection status
[ ] /rent scan — Bounty scanning still works (via Python script)
[ ] /rent post "test bounty" — Can create bounty via MCP
[ ] Voice mode: "search for developers" → MCP search_humans called

───────────────────────────────────────────────────────────────────────────────
NOTES & GOTCHAS
───────────────────────────────────────────────────────────────────────────────

• RENTAHUMAN_API_KEY must be set in environment for MCP server to start
• Verify npx is available: `which npx` or `npm -g list -depth=0`
• If MCP server fails to start, check logs: ~/.claude/logs/
• Rate limits still apply: 5 bounties/day, 50 conversations/day
• Hybrid approach: Python for scored batches, MCP for real-time individual lookups

───────────────────────────────────────────────────────────────────────────────
DEFAULT BEHAVIOR — BOUNTY OPERATIONS (TESTED 2026-02-19)
───────────────────────────────────────────────────────────────────────────────

**DECISION: bounty_hunter.py is the PRIMARY/DEFAULT for all bounty searches**

When user asks "show me bounties" or agent proactively offers "should I scan for bounties?":
  → ALWAYS run: python3 bounty_hunter.py
  → Display Grok-ranked results (scored 0-100)
  → Show cache age (12hr TTL)
  → Do NOT use raw MCP list_bounties unless explicitly requested

WHY? Raw MCP vs Grok-Scored Comparison:

Raw MCP list_bounties (GET /bounties):
  ✗ Returns only 20 bounties, unfiltered
  ✗ No scoring or ranking
  ✗ Includes ~40% scams: OTP hacks, account creation, currency pump, DM farms
  ✗ Mixes "for hire" self-ads with actual job postings
  ✓ Real-time, no cache

bounty_hunter.py + Grok (Primary):
  ✓ Filters out scam signals + "for hire" ads (removes 40% noise)
  ✓ AI-scores each bounty 0-100 based on:
     - Feasibility assessment
     - Alignment with YOUR_SKILLS
     - Scam risk detection
  ✓ Ranked top-to-bottom by quality
  ✓ Cached 12 hours for efficiency (fast re-runs)
  ✓ Smart filtering: detects OTP, account creation, pump schemes

TESTING DATA:
  Raw API:      20 bounties (unranked, 40% scams)
  Grok-Scored:  11 bounties (scored 100→45, top pick is 100/100 Tech/AI creator role)
  Top 3 are:
    1. Tech/AI Content Creator (100/100) — Aligned with YOUR_SKILLS
    2. LinkedIn Outreach (90/100) — Real marketing opportunity
    3. AI Rating Task (75/100) — Scalable, repeatable work

═══════════════════════════════════════════════════════════════════════════════
IMPLEMENTATION GUIDELINE
═══════════════════════════════════════════════════════════════════════════════

Rule 1: User says "what bounties are available?" or "scan for bounties"
  → Execute: python3 bounty_hunter.py
  → Return formatted output (top 10 ranked by Grok score)
  → Cache keeps it fast on second call within 12 hours

Rule 2: Agent proactively checks (morning routine or periodic check)
  → Execute: python3 bounty_hunter.py
  → Summarize: "Found 11 bounties, top pick scores 100/100: [title]"
  → Ask: "Want me to pull details on the top ones?"

Rule 3: User explicitly asks for "raw bounty list" or "unscored"
  → Use MCP list_bounties (raw API)
  → Note to user: "Unfiltered list from API (includes scams, use with caution)"

Rule 4: Creating bounties (posting jobs)
   → Use MCP mcp__rentahuman__create_bounty
   → This is agent-to-platform, doesn't need Grok scoring

═══════════════════════════════════════════════════════════════════════════════
BOUNTY_HUNTER.PY REFACTOR (2026-02-19)
═══════════════════════════════════════════════════════════════════════════════

ISSUE: Previous agent made partial changes that left the code in a broken state:
  • Cache paths pointed to logs/ folder inside scripts directory
  • Leftover files in .claude/skills/rent/cache/ from previous changes
  • SEEN_FILE and SAVED_FILE variables still referenced but cache folder existed

RESOLUTION: Complete refactor to use single cache location

CHANGES MADE TO .claude/skills/rent/scripts/bounty_hunter.py:

1. Updated File Path Variables (lines 27-42):
   • Changed PROJECT_DIR to point to .claude/skills/rent/ (parent of scripts)
   • Removed SEEN_FILE variable (no longer tracking "seen" bounties)
   • Removed SAVED_FILE variable (no longer tracking "saved" bounties)
   • Added CACHE_DIR = PROJECT_DIR / "cache"
   • Updated CACHE_FILE to use CACHE_DIR
   • Added CACHE_TXT_FILE for human-readable output

2. Removed Seen-Tracking Functions:
   • Deleted load_seen() function
   • Deleted save_seen() function
   • Removed all seen-tracking logic from scan functions

3. Removed Saved-Bounty Functions:
   • Deleted load_saved() function
   • Deleted save_bounty() function
   • Deleted unsave_bounty() function
   • Deleted format_saved() function
   • Removed "Save a bounty: `/rent save <id>`" from format_digest()

4. Added TXT Generation:
   • Added generate_cache_txt(cache) function
   • Creates human-readable ranked output file
   • Updated save_cache() to call generate_cache_txt()

5. Updated Scan Functions:
   • _background_rescore(): Removed only_new parameter and seen-tracking
   • scan(): Removed only_new parameter and all seen-tracking logic
   • main(): Updated scan() call to remove only_new=False

6. Cleaned Up Cache Folder:
   • Deleted .claude/skills/rent/cache/bounties_seen.json

FINAL CACHE FOLDER STRUCTURE:
.claude/skills/rent/cache/
├── bounties_cache.json    # Single JSON with all scored bounties
└── bounties_ranked.txt    # Human-readable TXT output

BENEFITS:
  ✓ Single source of truth for cache data
  ✓ Human-readable TXT file for quick reference
  ✓ Simplified code (no seen/saved tracking overhead)
  ✓ Consistent cache location across all skills

───────────────────────────────────────────────────────────────────────────────
Conditional checks for approval:
Summary of Changes
bounty_hunter.py
Updated file paths - Cache now uses .claude/skills/rent/cache/ folder
Removed seen-tracking - Deleted load_seen() and save_seen() functions
Removed saved-bounty features - Deleted load_saved(), save_bounty(), unsave_bounty(), format_saved() functions
Added TXT generation - New generate_cache_txt() function creates human-readable output
Simplified scan logic - Removed only_new parameter and all seen-tracking
Cache Folder Structure
.claude/skills/rent/cache/
├── bounties_cache.json    # Single JSON with all scored bounties
└── bounties_ranked.txt    # Human-readable TXT output
MCP_CONFIGURATION_UPDATE_SUMMARY.txt
Added new section "BOUNTY_HUNTER.PY REFACTOR (2026-02-19)" documenting:

Issue identified (partial changes left code broken)
Resolution (complete refactor)
All 6 changes made with details
Final cache folder structure
