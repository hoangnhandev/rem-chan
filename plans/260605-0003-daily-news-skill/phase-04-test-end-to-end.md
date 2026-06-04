# Phase 4: Test End-to-End

**Priority:** High | **Status:** ⬜ pending | **Effort:** Low

## Overview

Test toàn bộ flow: script crawl → agent tóm tắt → gửi Telegram. Verify dedup hoạt động.

## Test Cases

### Test 1: Script crawl output
```bash
# SSH into server, run script inside container
ssh contabo_withly_vn "sudo docker exec rem-chan bash /root/.picoclaw/workspace/skills/daily-news/scripts/crawl-news.sh"
```
**Expected:** JSON array with 5-8 articles, each with title/url/source/category/description/score

### Test 2: Dedup
```bash
# Run script again immediately
ssh contabo_withly_vn "sudo docker exec rem-chan bash /root/.picoclaw/workspace/skills/daily-news/scripts/crawl-news.sh"
```
**Expected:** Empty array `[]` (all articles already sent)

### Test 3: History file
```bash
ssh contabo_withly_vn "cat ~/rem-chan/docker/data/rem-chan/workspace/skills/daily-news/data/sent-history.json"
```
**Expected:** Valid JSON with articles array, each entry has url, hash, timestamp

### Test 4: Full agent flow (manual trigger)
Chat với rem-chan qua Telegram:
```
Hãy chạy skill daily-news và gửi tin tức cho tôi
```
**Expected:** Agent runs script, summarizes, sends formatted Telegram message

### Test 5: Cron trigger
- Wait for next cron slot OR manually verify cron job exists
- Check agent processes the cron message correctly

### Test 6: Error resilience
- Temporarily break one source URL in script → verify other sources still work
- Verify script outputs articles from working sources only

## Success Criteria

- [ ] Script outputs valid JSON with 5-8 articles (first run)
- [ ] Second run returns empty array (dedup works)
- [ ] sent-history.json valid and auto-updates
- [ ] Agent generates Vietnamese summary with opinions
- [ ] Telegram message format correct
- [ ] One source failure doesn't break others
