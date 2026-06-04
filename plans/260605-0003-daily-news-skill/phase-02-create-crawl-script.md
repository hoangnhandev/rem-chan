# Phase 2: Create crawl-news.sh

**Priority:** High | **Status:** ⬜ pending | **Effort:** Medium

## Overview

Tạo bash script all-in-one: crawl 6 nguồn → parse → dedup → output JSON compact.

## File to Create

`workspace/skills/daily-news/scripts/crawl-news.sh`

## Requirements

- Executable (`chmod +x`)
- Dưới 200 dòng
- Dependencies: curl, jq (verified trên server)
- Output: compact JSON array to stdout
- Dedup: check against `data/sent-history.json`
- Auto-cleanup history cũ hơn 7 ngày
- Handle errors gracefully (source fail → skip, không crash toàn bộ)

## Script Structure

```
#!/bin/bash
# crawl-news.sh - Daily news crawler for rem-chan

# --- Config ---
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
HISTORY_FILE="$SCRIPT_DIR/../data/sent-history.json"
MAX_ARTICLES=8
DAYS_KEEP=7

# --- Init ---
mkdir -p "$(dirname "$HISTORY_FILE")"
[ -f "$HISTORY_FILE" ] || echo '{"articles":[]}' > "$HISTORY_FILE"

# --- Helper functions ---
is_sent(url)      # Check if URL already in history
add_sent(url, title_hash)  # Add to history
cleanup_old()     # Remove entries older than 7 days
output_article()  # Echo JSON article to stdout

# --- Source: HackerNews ---
crawl_hackernews() {
  # Fetch top 10 story IDs
  ids=$(curl -s 'https://hacker-news.firebaseio.com/v0/topstories.json' | jq '.[:5][]')
  for id in $ids; do
    item=$(curl -s "https://hacker-news.firebaseio.com/v0/item/$id.json")
    title=$(echo "$item" | jq -r '.title')
    url=$(echo "$item" | jq -r '.url // "https://news.ycombinator.com/item?id=$id"')
    score=$(echo "$item" | jq -r '.score // 0')
    # Check dedup, output if new
  done
}

# --- Source: GitHub Trending ---
crawl_github() {
  yesterday=$(date -d 'yesterday' +%Y-%m-%d)
  curl -s "https://api.github.com/search/repositories?q=created:>$yesterday&sort=stars&order=desc&per_page=5" \
    | jq -r '.items[] | "\(.full_name)|\(.description)|\(.html_url)|\(.stargazers_count)"'
  # Parse, dedup, output
}

# --- Source: Claude Code Releases ---
crawl_claude() {
  curl -s "https://api.github.com/repos/anthropics/claude-code/releases?per_page=3" \
    | jq -r '.[] | "\(.tag_name)|\(.name)|\(.html_url)|\(.body[:200])"'
  # Parse, dedup, output
}

# --- Source: CoinDesk RSS ---
crawl_coindesk() {
  curl -sL 'https://www.coindesk.com/arc/outboundfeeds/rss/' \
    | jq -r '.rss.channel.item[:5][] | "\(.title)|\(.link)|\(.description[:150])"'
  # Parse, dedup, output
}

# --- Source: VnEconomy RSS ---
crawl_vneconomy() {
  curl -sL 'https://vneconomy.vn/rss.rss' \
    | jq -r '.rss.channel.item[:5][] | ...'
  # Parse, dedup, output (already Vietnamese)
}

# --- Source: AI News RSS ---
crawl_ai_news() {
  curl -sL 'https://artificialintelligence-news.com/feed/' \
    | jq -r '...'
  # Parse, dedup, output
}

# --- Main ---
cleanup_old
articles="[]"
articles=$(crawl_hackernews "$articles")
articles=$(crawl_github "$articles")
articles=$(crawl_claude "$articles")
articles=$(crawl_coindesk "$articles")
articles=$(crawl_vneconomy "$articles")
articles=$(crawl_ai_news "$articles")

# Sort by relevance, limit to MAX_ARTICLES
echo "$articles" | jq "sort_by(-.score) | .[:$MAX_ARTICLES]"

# Update history
update_history "$articles"
```

## Key Implementation Details

### RSS Parsing with jq
RSS is XML. Need to convert to JSON first:
```bash
# Method: use python3 to convert XML to JSON
curl -sL 'URL' | python3 -c "
import sys, json, xml.etree.ElementTree as ET
root = ET.parse(sys.stdin).getroot()
# ... parse RSS items to JSON
"
```

OR use a simpler approach - pipe through `jq` doesn't work with XML directly. Use python3 as XML→JSON bridge:
```bash
xml_to_json() {
  python3 -c "
import sys, json, xml.etree.ElementTree as ET
root = ET.parse(sys.stdin).getroot()
ns = {'rss': 'http://purl.org/rss/1.0/'}
items = []
for item in root.iter('item'):
    items.append({
        'title': item.findtext('title',''),
        'url': item.findtext('link',''),
        'description': (item.findtext('description','') or '')[:200]
    })
print(json.dumps(items[:5]))
"
}
```

### Dedup Logic
```bash
is_sent() {
  local url="$1"
  jq -r '.articles[].url' "$HISTORY_FILE" | grep -qF "$url"
}

add_sent() {
  local url="$1" title_hash="$2"
  local now=$(date +%s)
  local entry=$(jq -n --arg url "$url" --arg hash "$title_hash" --arg ts "$now" \
    '{url: $url, hash: $hash, timestamp: ($ts|tonumber)}')
  jq --argjson entry "$entry" '.articles += [$entry]' "$HISTORY_FILE" > tmp.json \
    && mv tmp.json "$HISTORY_FILE"
}
```

### Cleanup Logic
```bash
cleanup_old() {
  local cutoff=$(($(date +%s) - DAYS_KEEP * 86400))
  jq --argjson cutoff "$cutoff" '.articles |= map(select(.timestamp > $cutoff))' \
    "$HISTORY_FILE" > tmp.json && mv tmp.json "$HISTORY_FILE"
}
```

### Output Format
```json
[
  {
    "title": "Original title",
    "url": "https://...",
    "source": "hackernews",
    "category": "tech",
    "description": "Brief description excerpt",
    "score": 450
  }
]
```

### Category Mapping
| Source | Category |
|--------|----------|
| hackernews | tech |
| github | tech |
| claude-code | tech |
| coindesk | crypto |
| vneconomy | economy |
| ai-news | ai |

## Error Handling

- `curl` fail → `2>/dev/null`, skip source, continue
- `jq` parse fail → skip item, continue
- Empty response → skip source
- History file corrupt → recreate with `{"articles":[]}`
- Script never exits with error code for transient failures

## Success Criteria

- [ ] Script executable, under 200 lines
- [ ] All 6 sources crawl correctly
- [ ] Dedup works: articles already sent are filtered
- [ ] Output is valid JSON array
- [ ] History auto-cleanup works
- [ ] Graceful error handling (one source fails → others continue)
