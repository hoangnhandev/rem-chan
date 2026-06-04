# Phase 1: Create SKILL.md

**Priority:** High | **Status:** ⬜ pending | **Effort:** Low

## Overview

Tạo SKILL.md — file hướng dẫn agent cách crawl và gửi tin tức. Agent đọc file này khi cron trigger.

## Requirements

- Frontmatter YAML: name, description, metadata
- Hướng dẫn agent: chạy script → đọc output JSON → tóm tắt tiếng Việt → gửi Telegram
- Format tin nhắn mẫu
- Dưới 100 dòng

## File to Create

`workspace/skills/daily-news/SKILL.md`

## Implementation Steps

1. Create directory: `workspace/skills/daily-news/`
2. Write SKILL.md with:
   - YAML frontmatter (name: daily-news, description, metadata)
   - Instructions cho agent:
     a. Chạy `bash /root/.picoclaw/workspace/skills/daily-news/scripts/crawl-news.sh`
     b. Đọc JSON output (array of articles)
     c. Group articles by category
     d. Tóm tắt mỗi article sang tiếng Việt (1-2 câu)
     e. Thêm đánh giá/ý kiến cá nhân (1 câu, phong cách rem-chan)
     f. Gửi qua Telegram với format mẫu
   - Format template cho Telegram message
   - Lưu ý: không gửi nếu không có tin mới (script output rỗng)

## SKILL.md Content Draft

```markdown
---
name: daily-news
description: Crawl tin tức hằng ngày từ tech, crypto, kinh tế, AI. Tóm tắt tiếng Việt và gửi qua Telegram.
metadata: {"nanobot":{"emoji":"📰","requires":{"bins":["curl","jq"]}}}
---

# Daily News

Crawl tin tức từ nhiều nguồn, lọc trùng, tóm tắt tiếng Việt, gửi cho user.

## Cách dùng

1. Chạy script crawl:
```bash
bash /root/.picoclaw/workspace/skills/daily-news/scripts/crawl-news.sh
```

2. Script output JSON array (hoặc rỗng nếu không có tin mới):
```json
[{"title":"...","url":"...","source":"hackernews","description":"...","category":"tech"}]
```

3. Nếu output rỗng → KHÔNG gửi gì, kết thúc.

4. Nếu có articles → group theo category, tóm tắt và gửi.

## Format tin nhắn

```
📰 BẢN TIN {SÁNG/TRƯA/TỐI} - {DD/MM/YYYY}

{emoji category} {Tên category}
━━━━━━━━━━━━━━━━━━━━
{stt}. {Tiêu đề tóm tắt tiếng Việt}
   💬 {Đánh giá/ý kiến của rem-chan}
   🔗 {url}
```

Category emoji: 🔴 Tech, ₿ Crypto, 📊 Kinh tế, 🤖 AI

## Quy tắc

- Tóm tắt NGẮN GỌN: 1-2 câu/tin
- Đánh giá CÁ NHÂN: 1 câu, phong cách tự nhiên, có thể hài hước
- Ưu tiên tin quan trọng, bỏ tin nhỏ
- Nếu dưới 3 tin → vẫn gửi nhưng ghi "Hôm nay ít tin"
- Không bịa link, giữ nguyên URL gốc
```

## Success Criteria

- [ ] SKILL.md created tại đúng path
- [ ] Dưới 100 dòng
- [ ] Agent hiểu được flow: run script → read JSON → summarize → send
- [ ] Format template rõ ràng cho Telegram
