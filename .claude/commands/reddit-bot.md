# Reddit Bot Agent Commands

## Overview
The Reddit bot is a full marketing automation agent with Supabase-backed analytics.
It supports manual curation, agent discovery, and performance tracking.

## Available Operations

### Quick Status
```
Check Reddit bot status — show current targets, recent comments, and top performers.
Query Supabase tables: targets, comments, comment_performance.
```

### Targets Management
```
Show all active Reddit targets (manual + agent, deduplicated).
Query: SELECT * FROM targets WHERE is_active = true ORDER BY target_type, source, created_at DESC
```

### Trending Discovery
```
Find trending subreddits and threads relevant to our niche.
Run the discovery scan via reddit_bot.py discover_subreddits().
Report back: new subs found, member counts, relevance.
```

### Analytics Dashboard
```
Pull Reddit analytics from Supabase:

1. COMMENT PERFORMANCE (last 7 days):
   SELECT * FROM v_latest_performance ORDER BY engagement_ratio DESC

2. SUBREDDIT RANKINGS:
   SELECT * FROM v_subreddit_performance ORDER BY avg_engagement DESC

3. STRATEGY EFFECTIVENESS:
   SELECT * FROM v_strategy_performance

4. KEYWORD PERFORMANCE:
   SELECT * FROM v_keyword_performance ORDER BY avg_engagement DESC

5. REMOVED COMMENTS (need attention):
   SELECT * FROM v_latest_performance WHERE comment_is_visible = false

Report findings with actionable recommendations:
- Which subs to double down on
- Which keywords are catching fire
- Which strategies (carpet vs sniper) perform better
- Any comments getting removed (adjust approach)
- Controversy/engagement ratio trends
```

### Run Modes
```
Execute Reddit bot operations:
- Manual mode: Scan manual subreddits for keyword matches, engage manual threads
- Agent mode: Discovery + sniper rising/hot in agent-discovered subs
- Dynamic mode: Deduplicated union of both (no double-posting)
- Single cycle or continuous

Command: python reddit_bot.py
Or call functions directly: run_manual_mode(), run_agent_mode(), run_dynamic_mode()
```

### Create Post
```
Help craft and publish a Reddit post:
1. Suggest best subreddit based on content topic
2. Draft title and body optimized for the sub's style
3. Post via reddit_bot.py post_to_reddit()
4. Optionally add to manual targets for monitoring
```

### Performance Check
```
Run manual performance check on recent comments:
1. Query comments table for date window
2. Re-check each via Reddit API (score, visibility, thread stats)
3. Compute engagement_ratio and controversy_engagement
4. Insert snapshots into comment_performance table
5. Print summary with top/bottom performers

Command: python reddit_bot.py → option 7 → pick date range
Or call: check_comment_performance(days_back=7)
```

## Supabase Tables Reference

| Table | Purpose |
|-------|---------|
| `targets` | What to monitor (manual + agent entries) |
| `comments` | Every comment posted (dedup key: submission_id) |
| `comment_performance` | Time-series engagement snapshots |

## Views (pre-built analytics)

| View | What it shows |
|------|--------------|
| `v_active_targets` | Deduplicated scan list |
| `v_latest_performance` | Most recent snapshot per comment |
| `v_subreddit_performance` | Stats aggregated by subreddit |
| `v_strategy_performance` | Stats aggregated by strategy |
| `v_keyword_performance` | Which keywords drive engagement |

## Key Metrics

- **engagement_ratio** = comment_score / thread_num_comments (visibility relative to thread size)
- **controversy_engagement** = engagement_ratio × (1 + controversiality) (polarizing + visible = winning)
- **comment_score_delta** = current score - 1 (growth since posting)
- **thread_score_delta** = thread score now - thread score when we commented (did we catch a rocket?)
