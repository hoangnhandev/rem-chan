---
name: daily-news
description: Daily news crawler for tech, crypto, economy, AI. Summarize in Vietnamese, send via Telegram.
metadata: {"nanobot":{"emoji":"📰","requires":{"bins":["curl","jq"]}}}
---

# Daily News

Crawl news from multiple sources, deduplicate, summarize in Vietnamese, send to user.

## How to Use

1. Run the crawl script:
```bash
bash /home/withlyvn/rem-chan/docker/data/rem-chan/workspace/skills/daily-news/scripts/crawl-news.sh
```

2. Script outputs a JSON array (or empty if no new articles):
```json
[{"title":"...","url":"...","source":"hackernews","category":"tech","description":"..."}]
```

3. If output is empty → do NOT send anything, stop immediately.

4. If articles exist → send **EACH ARTICLE AS A SEPARATE MESSAGE** via Telegram using the `message` tool.

## Format: 1 Article = 1 Message

First, send 1 opening message. Then send each article as its own message.

**Opening message (once):**
```
📰 BẢN TIN {SÁNG/TRƯA/TỐI} - {DD/MM/YYYY}
Có {N} tin mới cho Nyan nè~
```

**Each article message:**
```
{category emoji} {Title in Vietnamese}

📝 {Summary: 2-3 sentences explaining what the article is about, in natural Vietnamese}

💬 {Your personal opinion: 1-2 sentences, natural tone, show personality, can be humorous or sharp}

🔗 {original URL}
```

Category emoji: 🔴 Công nghệ, ₿ Crypto, 📊 Kinh tế, 🤖 AI

## Rules

- **1 ARTICLE = 1 MESSAGE** — use the `message` tool for each article separately, do NOT combine into one big message
- Summary: 2-3 sentences per article, clear and informative, natural Vietnamese
- Opinion: 1-2 sentences, rem-chan's personal take, show personality and character
- Send important articles first
- If fewer than 3 articles → add note "Hôm nay hơi ít tin 🥱" in opening message
- Do NOT fabricate links, keep original URLs from script output
- Do NOT send if script output is empty
- Determine time slot: SÁNG (7h), TRƯA (11h45), TỐI (21h) based on current time
