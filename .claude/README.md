# Voice-Activated Newsletter Automation Guide
## Complete Setup & Operation Manual

---

## 🎯 What This Is

A voice-controlled automation system for your Market Pulse Newsletter that lets you:
- Generate newsletters by voice: "Generate today's newsletter"
- Post to social media by voice: "Post to X and Reddit"
- Check status by voice: "What's the newsletter status?"
- Run the full pipeline: "Run everything"

**How it works:** You speak → Claude Code understands → Runs `agent_orchestrator.py` → Reports results

---

## 📁 Directory Structure

```
.claude/
├── settings.json          # Uses Claude Haiku 4.5 (fast & efficient)
├── CLAUDE.md             # Project context for Claude to understand your setup
├── README.md              # Comprehensive Voice / Newsletter Automation Guide
├── commands/
│   ├── pulse.md          # Main command: /pulse <task>
│   └── vp.md            # Voice shortcuts: /vp <action>
```

**Total size:** ~17 KB

---
## COMMANDS:
AGENT_ORCHESTRATOR OVERVIEW:
Available tasks:
    status          - Check pipeline status for a date
    gen nl          - Generate newsletter from feeds
    send nl         - Send newsletter via email
    gen content     - Generate Twitter/X content
    post-x          - Post to X/Twitter only
    post-reddit     - Post to Reddit only
    post-threads    - Post to Threads only
    post-linkedin   - Post to LinkedIn only
    post-all        - Post to all enabled platforms
    post-custom     - Post to specific platforms (use --platforms)
    full            - Run complete pipeline (no waits)
    full-cron       - Run with scheduled waits (for cron)

Execute newsletter automation tasks.

**Usage:** `/pulse <task> [options]`


**Common Tasks:**
- `status` - Check pipeline status
- `gen nl` - Generate newsletter  
- `send nl` - Send newsletter
- `gen content` - Generate social content
- `post-x` - Post to X/Twitter
- `post-all` - Post to all platforms
- `full` - Run complete pipeline

**Examples:**
```
/pulse status
/pulse gen nl --date 2026-02-03
/pulse post-x
/pulse full
```

Shorthand for common voice commands.

**Usage:** `/vp <command>`

**Commands:**
- `check` → status
- `generate newsletter` → gen nl
- `generate content` → gen content
- `send` → send nl  
- `tweet` → post-x
- `publish` → post-all
- `go` → full pipeline

**Voice examples:**
"Run vp check"
"Execute vp make"  
"Do vp publish"

**Implementation:**
Maps voice-friendly aliases to full agent_orchestrator.py commands.

--
## 🚀 Installation (3 Steps)

### Step 1: Verify Installation
```bash
cd "/Users/sc/News Letter"
ls -la .claude/
```

You should see:
- ✓ `settings.json`
- ✓ `CLAUDE.md`
- ✓ `commands/pulse.md`
- ✓ `commands/vp.md`

### Step 2: Install VoiceMode (For Voice Control)
```bash
# Install UV package manager
curl -LsSf https://astral.sh/uv/install.sh | sh

# Install VoiceMode
uvx voice-mode-install

# Connect VoiceMode to Claude Code
claude mcp add --scope user voicemode -- uvx --refresh voice-mode

# Optional: Set OpenAI API key for voice services
export OPENAI_API_KEY="your-key-here"
```

**Note:** Without VoiceMode, you can still use text commands in Claude Code terminal.

### Step 3: Test Your Setup
```bash
cd "/Users/sc/News Letter"
> claude converse
```

Then try:
```
/pulse status
/vp check
```

If you see the commands execute, you're all set! ✅

---

## 🎤 How to Use Voice Commands

### Starting a Voice Session
```bash
cd "/Users/sc/News Letter"
claude converse
```

This opens a voice conversation with Claude. Your microphone activates automatically.

### Natural Voice Commands

Just speak naturally. Claude understands context:

**Status Checks:**
- "Check the newsletter status"
- "What's the status for today?"
- "Show me what's been completed"

**Generate Newsletter:**
- "Generate today's newsletter"
- "Make the newsletter"
- "Create the newsletter for February 3rd"

**Send Newsletter:**
- "Send the newsletter"
- "Send it out"
- "Email the newsletter to subscribers"

**Social Media Posting:**
- "Post to X"
- "Post to X and Reddit"
- "Post to all platforms"
- "Tweet the newsletter"

**Full Pipeline:**
- "Run the full pipeline"
- "Do everything"
- "Run the complete workflow"

### How Claude Translates Your Voice

```
Your Voice: "Check the newsletter status"
      ↓
Claude hears and understands intent
      ↓
Claude executes: /vp check
      ↓
Runs: python agent_orchestrator.py --task status
      ↓
Claude speaks results back to you
```

---

## 💻 Text Commands (No Voice Needed)

If you prefer typing or VoiceMode isn't installed, use these commands directly in Claude Code:

### Main Command: /pulse

**Syntax:**
```
/pulse <task> [--date YYYY-MM-DD] [--platforms x,reddit,threads,linkedin] [--json] [--dry-run]
```

**Examples:**
```bash
# Check status
/pulse status

# Generate newsletter
/pulse gen nl

# Generate for specific date
/pulse gen nl --date 2026-02-01

# Send newsletter
/pulse send nl

# Generate social content
/pulse gen content

# Post to X/Twitter
/pulse post-x

# Post to specific platforms
/pulse post-custom --platforms x,reddit

# Post to all enabled platforms
/pulse post-all

# Run complete pipeline
/pulse full

# Preview what would happen (dry-run)
/pulse full --dry-run

# Get JSON output for programmatic use
/pulse status --json
```

### Quick Shortcuts: /vp

Voice-optimized shortcuts for common tasks:

```bash
/vp check     # → /pulse status
/vp make      # → /pulse gen nl
/vp send      # → /pulse send nl
/vp tweet     # → /pulse post-x
/vp publish   # → /pulse post-all
/vp go        # → /pulse full
/vp content   # → /pulse gen content
```

**Why use /vp?** Shorter commands, easier to say with voice, faster to type.

---

## 📋 Complete Task Reference

| Task | What It Does | Command |
|------|--------------|---------|
| **status** | Check which files exist for a date | `/pulse status` or `/vp check` |
| **gen nl** | Generate newsletter from RSS feeds | `/pulse gen nl` or `/vp make` |
| **send nl** | Send newsletter via email | `/pulse send nl` or `/vp send` |
| **gen content** | Generate Twitter/social content | `/pulse gen content` or `/vp content` |
| **post-x** | Post to X/Twitter only | `/pulse post-x` or `/vp tweet` |
| **post-reddit** | Post to Reddit only | `/pulse post-reddit` |
| **post-threads** | Post to Threads only | `/pulse post-threads` |
| **post-linkedin** | Post to LinkedIn only | `/pulse post-linkedin` |
| **post-all** | Post to all enabled platforms | `/pulse post-all` or `/vp publish` |
| **post-custom** | Post to specific platforms | `/pulse post-custom --platforms x,reddit` |
| **full** | Run complete pipeline (no waits) | `/pulse full` or `/vp go` |
| **full-cron** | Run pipeline with scheduled waits | `/pulse full-cron` |

---

## 🔄 Understanding the Pipeline Workflow

Your newsletter pipeline has 7 stages:

### 1. **Fetch** - Collect Raw Data
- Fetches RSS feeds from configured sources
- Grabs X/Twitter summaries
- **Output:** `raw_rss_entries/` and `x_summaries/`

### 2. **Rank** - Prioritize Articles
- Ranks articles by relevance
- Selects top 20 stories
- **Output:** `ranked_news/ranked_news_YYYY-MM-DD.json`

### 3. **Generate** - Create Newsletter Drafts
- Writes newsletter in markdown
- Creates both full and short versions
- **Output:** `draft/` and `draft_short/`

### 4. **Style** - Format as HTML
- Converts markdown to styled HTML
- Applies newsletter template
- **Output:** `final/` and `final_short/`

### 5. **Email** - Prepare for Delivery
- Wraps in email template
- Optimizes for email clients
- **Output:** `final_email/`

### 6. **Send** - Deliver Newsletter
- Sends to subscriber list
- Uses email service (requires mailgun module)

### 7. **Social** - Post to Platforms
- Generates platform-specific content
- Posts to X, Reddit, Threads, LinkedIn
- **Output:** `socials/`

### Quick Status Check

Run `/vp check` to see which stages are complete:

```
✓ Fetch      2/2 complete
✓ Rank       2/2 complete
✓ Generate   2/2 complete
✓ Style      2/2 complete
○ Email      0/1 complete  ← Missing email wrapper
○ Twitter    0/2 complete  ← Missing social content
```

---

## 🎬 Common Workflows

### Daily Newsletter (Full Automation)
```bash
# Voice:
"Run the full pipeline"

# Text:
/vp go
```

**What happens:**
1. Generates newsletter from feeds
2. Sends to subscribers
3. Creates social content
4. Posts to all enabled platforms

### Selective Social Posting
```bash
# Voice:
"Post to X and Reddit"

# Text:
/pulse post-custom --platforms x,reddit
```

### Status → Generate → Post Workflow
```bash
# 1. Check what's missing
/vp check

# 2. Generate newsletter
/vp make

# 3. Post to social
/vp tweet
```

### Working with Past Dates
```bash
# Generate for Feb 1st
/pulse gen nl --date 2026-02-01

# Check status for Feb 1st
/pulse status --date 2026-02-01

# Post Feb 1st content
/pulse post-x --date 2026-02-01
```

### Preview Before Running (Dry-Run)
```bash
# See what would happen without executing
/pulse full --dry-run

# Output:
[DRY RUN] Would execute: Run complete pipeline
  → Generate newsletter for 2026-02-03
  → Send newsletter via email
  → Generate social media content
  → Post to all enabled platforms
```

### Get Structured Data (JSON Mode)
```bash
# Get status as JSON for scripts/automation
/pulse status --json

# Output:
{
  "date": "2026-02-03",
  "overall": {
    "total": 11,
    "completed": 8,
    "complete": false,
    "percentage": 72.73
  },
  "stages": {...}
}
```

---

## 🛠️ Configuration & Customization

### Current Settings (settings.json)

```json
{
  "model": "claude-haiku-4-5",
  "permissions": {
    "allowedTools": ["Read", "Write", "Edit", "Bash", "Glob", "Grep"],
    "deny": [
      "Bash(rm -rf *)",
      "Write(.env*)"
    ]
  }
}
```

**Why Haiku 4.5?**
- ⚡ Fast response times (perfect for automation)
- 💰 Cost-effective for repetitive tasks
- 🎯 Sufficient for command routing and status checking
- 🎤 Optimized for voice workflows

The orchestrator script (`agent_orchestrator.py`) handles all complex logic. Claude just needs to:
1. Parse your intent
2. Map to the correct command
3. Execute via bash
4. Report results

### Changing the Model

Edit `.claude/settings.json`:

```json
{
  "model": "claude-sonnet-4-5-20250929"  // More powerful, slower, more expensive
}
```

**When to use Sonnet:**
- Complex reasoning needed
- Multi-step planning
- Code generation/debugging

**When to use Haiku (default):**
- Command routing
- Status checks
- Simple automation
- Voice commands

### Auto-Approving Actions (Use Carefully!)

**Current:** You approve each action (safer)

**Auto-approve file edits only:**
```json
{
  "model": "claude-haiku-4-5-20251001",
  "permissions": {
    "permissionMode": "acceptEdits"
  }
}
```

**Auto-approve everything (dangerous!):**
```json
{
  "model": "claude-haiku-4-5-20251001",
  "permissions": {
    "permissionMode": "bypassPermissions"
  }
}
```

⚠️ **Warning:** Only use auto-approval in trusted environments!

### Platform Configuration

Your orchestrator tracks which platforms are enabled:

**Default:**
- ✅ X/Twitter (always enabled)
- ❌ Reddit (disabled)
- ❌ Threads (disabled)
- ❌ LinkedIn (disabled)

**Enable platforms:**
1. Run in interactive mode: `python agent_orchestrator.py`
2. Select option `12. platforms`
3. Toggle platforms on/off

Or use `post-custom` to post to any combination:
```bash
/pulse post-custom --platforms x,reddit,threads
```

---

## 🎙️ Voice Mode Details

### How Voice Recognition Works

```
Your Speech → Microphone
      ↓
VoiceMode captures audio
      ↓
Converts to text (OpenAI Whisper API or local)
      ↓
Sends to Claude Code
      ↓
Claude processes as normal text
```

### How Claude Responds with Voice

```
Claude generates response text
      ↓
VoiceMode converts to speech (OpenAI TTS or local)
      ↓
Plays through speakers
      ↓
You hear the results
```

### Voice Services Options

**Option 1: Cloud (OpenAI)**
- Requires: `OPENAI_API_KEY`
- Pros: High quality, fast
- Cons: Requires internet, costs money

**Option 2: Local (Free & Private)**
```bash
# Install local speech-to-text
voicemode whisper install

# Install local text-to-speech
voicemode kokoro install
```
- Pros: Free, private, offline
- Cons: Slower, requires setup

### Voice Tips

✅ **Do:**
- Speak clearly and naturally
- Use a quiet environment
- Say complete thoughts: "Generate the newsletter for today"
- Use the shortcuts: "vp check" instead of "run the pulse command with status task"

❌ **Don't:**
- Speak too fast or mumble
- Use background noise (fans, TV, etc.)
- Use overly technical syntax: "Execute slash pulse hyphen hyphen task equals status"
- Expect it to work offline without local services

---

## 🔍 Troubleshooting

### Commands Not Showing Up

**Problem:** `/pulse` or `/vp` commands don't work

**Solution:**
```bash
# Check if .claude folder exists in project root
ls -la "/Users/sc/News Letter/.claude"

# Restart Claude Code
claude --help

# Look for your commands in the list
```

### Voice Mode Not Working

**Problem:** Voice commands aren't recognized

**Solution:**
```bash
# Check VoiceMode installation
uvx voice-mode --version

# Re-add to Claude Code
claude mcp add --scope user voicemode -- uvx --refresh voice-mode

# Test microphone
# Say something and see if VoiceMode captures it
```

### "Module Not Found" Errors

**Problem:** Warnings like `No module named 'mailgun'`

**These are expected!** The orchestrator handles missing modules gracefully. The warnings appear during normal operation but won't appear in:
- `--dry-run` mode
- `--json` mode

**If you want to install the modules:**
```bash
pip install mailgun  # For email sending
pip install google-generativeai  # For content generation
pip install linkedin-api  # For LinkedIn posting
```

### Orchestrator Script Not Found

**Problem:** Command fails with "file not found"

**Solution:**
```bash
# Verify you're in the correct directory
pwd
# Should output: /Users/sc/News Letter

# Check script exists
ls -la agent_orchestrator.py

# If not in correct directory:
cd "/Users/sc/News Letter"
```

### Permission Errors

**Problem:** Can't read/write files

**Solution:**
```bash
# Check .claude permissions
ls -la .claude/

# Fix permissions
chmod -R 755 .claude/

# Fix orchestrator permissions
chmod +x agent_orchestrator.py
```

### No Output from Commands

**Problem:** Commands run but show nothing

**Solution:**
1. Check if you're in `--json` mode (suppresses colored output)
2. Run without flags: `/pulse status`
3. Check for errors in the output
4. Verify date exists: `/pulse status --date 2026-02-03`

---

## 📊 Understanding Status Output

### Normal Output
```
PIPELINE STATUS CHECK
Date: 2026-02-03

✓ Raw RSS entries fetched
✓ Ranked news articles (top 20)
✓ X/Twitter summaries
✓ Newsletter markdown draft
✓ Short newsletter draft
✓ Styled newsletter (full)
✓ Styled newsletter (short)
✗ Email-wrapped newsletter
✗ Twitter thread content
✗ Breaking news post

Stage Summary:
✓ Fetch         2/2 complete
✓ Rank          2/2 complete
✓ Generate      2/2 complete
✓ Style         2/2 complete
○ Email         0/1 complete
○ Twitter       0/2 complete
```

**What it means:**
- ✓ = File exists, stage complete
- ✗ = File missing, needs to be generated
- ○ = Partial completion

### JSON Output
```json
{
  "date": "2026-02-03",
  "overall": {
    "total": 11,
    "completed": 7,
    "complete": false,
    "percentage": 63.64
  },
  "stages": {
    "Fetch": {
      "total": 2,
      "completed": 2,
      "complete": true,
      "percentage": 100.0
    },
    "Email": {
      "total": 1,
      "completed": 0,
      "complete": false,
      "percentage": 0.0
    }
  }
}
```

**Use JSON when:**
- Integrating with other scripts
- Parsing status programmatically
- Building dashboards
- Automating workflows

---

## 🎯 Quick Command Reference Card

### Voice Commands (Natural Language)
```
"Check status"           → /vp check
"Make newsletter"        → /vp make
"Send it"               → /vp send
"Tweet it"              → /vp tweet
"Post everywhere"       → /vp publish
"Run everything"        → /vp go
```

### Text Commands (Shortcuts)
```
/vp check     Status check
/vp make      Generate newsletter
/vp send      Send email
/vp tweet     Post to X
/vp publish   Post to all platforms
/vp go        Full pipeline
/vp content   Generate social content
```

### Full Commands (Detailed Control)
```
/pulse status                                   Check status
/pulse gen nl --date 2026-02-01                Generate for date
/pulse send nl                                  Send newsletter
/pulse post-custom --platforms x,reddit        Post to specific platforms
/pulse full --dry-run                          Preview pipeline
/pulse status --json                           Get JSON output
```

---

## 🎬 Demo Script (For Portfolio/Resume)

### 10-Second Version
```bash
claude converse

# Speak:
"Check status"
[Shows completion: 63%]

"Generate the newsletter"
[Creates all files]

"Post to all platforms"
[Posts to X, Reddit, Threads, LinkedIn]

Done! ✓
```

### 30-Second Version
```bash
claude converse

# Speak:
"What's the newsletter status for today?"
→ Claude shows: 7/11 files complete, missing email and social

"Generate today's newsletter"
→ Claude runs generation, shows progress

"Now send it via email"
→ Claude sends to subscribers

"Post to X and Reddit"
→ Claude posts to both platforms

"Great, show me the final status"
→ Claude shows: 11/11 complete ✓
```

### Full Workflow Demo
```bash
# Start fresh
claude converse

# 1. Check what exists
"Check the newsletter status"

# 2. Generate if needed
"Generate the newsletter for today"

# 3. Review (optional - manually check files)

# 4. Send email
"Send the newsletter to subscribers"

# 5. Social media
"Generate the social content"
"Post to X and Reddit"

# 6. Verify
"Show me the final status"

Result: Complete automation via voice! 🎉
```

---

## 📚 Additional Resources

### Official Documentation
- **Claude Code:** https://code.claude.com/docs
- **VoiceMode:** https://github.com/mbailey/voicemode
- **Claude API:** https://docs.anthropic.com

### Project Files
- **agent_orchestrator.py** - Main automation script (all tasks defined here)
- **CLAUDE.md** - Full project context for Claude
- **settings.json** - Claude Code configuration
- **commands/pulse.md** - Full command documentation
- **commands/vp.md** - Voice shortcuts documentation

### Getting Help
1. Check this guide first
2. Run `python agent_orchestrator.py --help` for task list
3. Review error messages (they're descriptive)
4. Check CLAUDE.md for project-specific details
5. Visit Claude Code docs for platform issues

---

## ✅ Installation Checklist

- [ ] Copied `.claude` folder to `/Users/sc/News Letter/`
- [ ] Verified files exist with `ls -la .claude/`
- [ ] Installed VoiceMode with `uvx voice-mode-install`
- [ ] Connected VoiceMode: `claude mcp add --scope user voicemode -- uvx --refresh voice-mode`
- [ ] (Optional) Set `OPENAI_API_KEY` for cloud voice services
- [ ] Tested text command: `/pulse status`
- [ ] Tested voice command: "Check status" in `claude converse`
- [ ] Confirmed agent_orchestrator.py is executable
- [ ] Ran dry-run test: `/pulse full --dry-run`
- [ ] Ready to automate! 🚀

---

## 🎉 You're Ready!

Your voice-activated newsletter automation is now set up and ready to use.

**Quick Start:**
1. `cd "/Users/sc/News Letter"`
2. `claude converse`
3. Say: "Check the newsletter status"
4. Start automating! 

**Next Steps:**
- Record a demo for your portfolio
- Set up cron job for daily automation
- Customize platform settings
- Build more custom commands

Happy automating! 🎤✨

---

*Generated: February 3, 2026*  
*Model: Claude Haiku 4.5*  
*Version: 1.0*