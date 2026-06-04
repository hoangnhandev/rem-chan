# Brainstorm: Daily News Skill cho rem-chan

**Ngày:** 2026-06-05
**Trạng thái:** Đã duyệt → chuyển sang implementation

## Problem Statement

rem-chan (PicoClaw bot trên Contabo) cần skill crawl tin tức hằng ngày, tóm tắt sang tiếng Việt, gửi qua Telegram. Chạy 3 lần/ngày: 7h sáng, 11:45 trưa, 9h tối.

## Requirements

- **Nguồn tin:** HackerNews, GitHub Trending, Claude Code Changelog, CoinDesk, VnEconomy, AI News
- **Số lượng:** 5-8 tin/lần
- **Dedup:** Không gửi lại tin đã gửi (dựa URL)
- **Output:** Tiếng Việt, gồm tóm tắt + đánh giá của rem-chan + link
- **Kênh gửi:** Telegram 1-1 chat
- **Approach:** Skill + Bash Script

## Architecture

```
Cron (3 lần/ngày) → Agent (glm-5-turbo) → crawl-news.sh → JSON output → Agent tóm tắt → Telegram
```

### File Structure

```
workspace/skills/daily-news/
├── SKILL.md              # Agent instructions
├── scripts/
│   └── crawl-news.sh     # All-in-one crawler
└── data/
    └── sent-history.json  # Dedup tracking
```

### Sources (verified)

| Source | Method | Status |
|--------|--------|--------|
| HackerNews Top | Firebase API (JSON) | ✅ Working |
| GitHub Trending | Search API | ✅ Working |
| Claude Code Releases | GitHub Releases API | ✅ Working |
| CoinDesk RSS | RSS XML | ✅ Working |
| VnEconomy RSS | RSS XML (tiếng Việt) | ✅ Working |
| AI News RSS | RSS XML | ✅ Working |

### Blocked Sources (removed)

| Source | Reason |
|--------|--------|
| Reddit RSS | Server IP blocked |
| Reuters RSS | Wrong URL/returns HTML |

### Cron Jobs

| Time | Expression |
|------|-----------|
| 7:00 AM | `0 7 * * *` |
| 11:45 AM | `45 11 * * *` |
| 9:00 PM | `0 21 * * *` |

### Token Budget

~4-6K tokens/run × 3 runs/day = ~12-18K tokens/day

## Decision Log

1. **Fat Script, Thin Agent** - Script handles crawl+parse+dedup; agent only translates+adds personality+sends. More reliable, less token usage.
2. **Single script** over multiple - KISS principle, easier to maintain.
3. **jq for parsing** - Available on server, fast, lightweight.
4. **sent-history.json** - URL-based dedup, auto-cleanup after 7 days.

## Next Steps

→ Create implementation plan via `/ck:plan`
