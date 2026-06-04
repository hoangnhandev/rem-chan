---
name: daily-news-skill
status: pending
created: 2026-06-05
blockedBy: []
blocks: []
---

# Plan: Daily News Skill cho rem-chan

## Overview

Implement skill crawl tin tức hằng ngày cho rem-chan (PicoClaw bot). Script bash crawl từ 6 nguồn, agent tóm tắt tiếng Việt + gửi qua Telegram. Chạy 3 lần/ngày qua cron.

## Phases

| # | Phase | File | Status |
|---|-------|------|--------|
| 1 | Create SKILL.md | `workspace/skills/daily-news/SKILL.md` | ⬜ pending |
| 2 | Create crawl-news.sh | `workspace/skills/daily-news/scripts/crawl-news.sh` | ⬜ pending |
| 3 | Deploy to server + setup cron | Server: `~/rem-chan/docker/data/rem-chan/workspace/skills/daily-news/` | ⬜ pending |
| 4 | Test end-to-end | SSH → run script → verify output → test cron | ⬜ pending |

## Key Files

- `workspace/skills/daily-news/SKILL.md` — Agent instructions
- `workspace/skills/daily-news/scripts/crawl-news.sh` — All-in-one crawler
- `workspace/skills/daily-news/data/sent-history.json` — Dedup (auto-created)

## Server Paths

- Local workspace: `workspace/skills/daily-news/`
- Server workspace: `~/rem-chan/docker/data/rem-chan/workspace/skills/daily-news/`
- Docker mount: `~/rem-chan/docker/data/rem-chan` → `/root/.picoclaw`
- Container path: `/root/.picoclaw/workspace/skills/daily-news/`

## Sources (verified working)

1. HackerNews Top — Firebase API (JSON)
2. GitHub Trending — GitHub Search API
3. Claude Code Releases — GitHub Releases API
4. CoinDesk — RSS XML
5. VnEconomy — RSS XML (Vietnamese)
6. AI News — RSS XML

## References

- Brainstorm report: `plans/reports/brainstorm-260605-0002-daily-news-skill.md`
- Cron tool: `pkg/tools/cron.go`
- Cron service: `pkg/cron/service.go`
- Skill example: `workspace/skills/weather/SKILL.md`
