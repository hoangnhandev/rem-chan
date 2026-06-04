# Phase 3: Deploy to Server + Setup Cron

**Priority:** High | **Status:** ⬜ pending | **Effort:** Low

## Overview

Deploy skill files lên Contabo server vào đúng volume path, set permissions, setup 3 cron jobs qua chat với rem-chan.

## Prerequisites

- Phase 1 & 2 completed (SKILL.md + crawl-news.sh created locally)
- SSH access to contabo_withly_vn

## Server Paths

| Local | Server (volume mount) | Container |
|-------|----------------------|-----------|
| `workspace/skills/daily-news/` | `~/rem-chan/docker/data/rem-chan/workspace/skills/daily-news/` | `/root/.picoclaw/workspace/skills/daily-news/` |

## Implementation Steps

### 1. Create directories on server
```bash
ssh contabo_withly_vn "mkdir -p ~/rem-chan/docker/data/rem-chan/workspace/skills/daily-news/{scripts,data}"
```

### 2. Copy files
```bash
# SKILL.md
scp workspace/skills/daily-news/SKILL.md contabo_withly_vn:~/rem-chan/docker/data/rem-chan/workspace/skills/daily-news/

# crawl-news.sh
scp workspace/skills/daily-news/scripts/crawl-news.sh contabo_withly_vn:~/rem-chan/docker/data/rem-chan/workspace/skills/daily-news/scripts/
```

### 3. Set permissions
```bash
ssh contabo_withly_vn "chmod +x ~/rem-chan/docker/data/rem-chan/workspace/skills/daily-news/scripts/crawl-news.sh"
```

### 4. Verify deployment
```bash
ssh contabo_withly_vn "ls -la ~/rem-chan/docker/data/rem-chan/workspace/skills/daily-news/ && ls -la ~/rem-chan/docker/data/rem-chan/workspace/skills/daily-news/scripts/"
```

### 5. Test script directly (from inside container)
```bash
ssh contabo_withly_vn "sudo docker exec rem-chan bash /root/.picoclaw/workspace/skills/daily-news/scripts/crawl-news.sh"
```

### 6. Setup Cron Jobs

Chat với rem-chan qua Telegram để tạo 3 cron jobs. Hoặc dùng exec tool qua CLI:

**Job 1: Bản tin sáng 7:00**
```
cron action=add cron_expr="0 7 * * *" message="Hãy chạy skill daily-news để crawl tin tức sáng và gửi tóm tắt cho user."
```

**Job 2: Cập nhật trưa 11:45**
```
cron action=add cron_expr="45 11 * * *" message="Hãy chạy skill daily-news để crawl tin tức trưa và gửi tóm tắt cho user."
```

**Job 3: Bản tin tối 21:00**
```
cron action=add cron_expr="0 21 * * *" message="Hãy chạy skill daily-news để crawl tin tức tối và gửi tóm tắt cho user."
```

### 7. Verify cron jobs
```
cron action=list
```

## Success Criteria

- [ ] Files deployed đúng path trên server
- [ ] Script executable
- [ ] Script chạy được từ trong container (output JSON)
- [ ] 3 cron jobs đã tạo và enabled
- [ ] Cron jobs hiển thị đúng schedule
