---
name: daily-news
description: Daily news crawler for tech, crypto, economy, AI. Summarize in Vietnamese, send via Telegram.
metadata: {"nanobot":{"emoji":"📰","requires":{"bins":["curl","jq"]}}}
---

# Daily News

Crawl news from multiple sources, deduplicate, summarize in Vietnamese, send to user.

## CRITICAL RULE

**You MUST send each article as a SEPARATE message using the `message` tool.**
**Do NOT combine multiple articles into one message.**
**Call the `message` tool ONCE PER ARTICLE.**

If there are 5 articles, you call the `message` tool 6 times total (1 opening + 5 articles).

## Step-by-step Process

### Step 1: Run the crawl script
```bash
bash /root/.picoclaw/workspace/skills/daily-news/scripts/crawl-news.sh
```

Script outputs a JSON array (or empty if no new articles):
```json
[{"title":"...","url":"...","source":"hackernews","category":"tech","description":"..."}]
```

### Step 2: If empty → stop immediately, send nothing.

### Step 3: Send opening message via `message` tool
```
📰 BẢN TIN {SÁNG/TRƯA/TỐI} - {DD/MM/YYYY}
Có {N} tin mới cho Nyan nè~
```

### Step 4: For EACH article, call `message` tool separately

Format for each article message:
```
{category emoji} {Title in Vietnamese}

📝 {Summary: 2-3 sentences explaining the article, in Vietnamese}

💬 {Your personal opinion: 1-2 sentences, show personality}

🔗 {original URL}
```

Category emoji: 🔴 Công nghệ, ₿ Crypto, 📊 Kinh tế, 🤖 AI

## Example: 3 articles = 6 message tool calls

1. `message` → "📰 BẢN TIN TỐI - 05/06/2026\nCó 3 tin mới cho Nyan nè~"
2. `message` → "🔴 VoidZero gia nhập Cloudflare\n\n📝 Cloudflare vừa công bố..." (article 1)
3. `message` → "🔴 Claude Code v2.1.162\n\n📝 Anthropic phát hành..." (article 2)
4. `message` → "₿ Bitcoin giảm 7%\n\n📝 Thị trường crypto..." (article 3)

## Other Rules

- Summary: 2-3 sentences per article, natural Vietnamese
- Opinion: 1-2 sentences, rem-chan's personality, can be humorous
- Send important articles first
- If fewer than 3 articles → add "Hôm nay hơi ít tin 🥱" in opening
- Do NOT fabricate links
- Determine time slot: SÁNG (7h), TRƯA (11h45), TỐI (21h)
