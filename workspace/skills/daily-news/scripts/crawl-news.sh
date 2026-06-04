#!/bin/bash
# crawl-news.sh - Daily news crawler for rem-chan
# Fetches from 6 sources, deduplicates, outputs compact JSON
set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DATA_DIR="$SCRIPT_DIR/../data"
HISTORY_FILE="$DATA_DIR/sent-history.json"
MAX_ARTICLES=8
DAYS_KEEP=7

# Curl wrapper (avoids bash array issues)
fcurl() { curl -sL --connect-timeout 10 --max-time 30 "$@"; }

# --- Init ---
mkdir -p "$DATA_DIR"
[ -f "$HISTORY_FILE" ] || echo '{"articles":[]}' > "$HISTORY_FILE"

# Collect all articles into temp file
TMPFILE=$(mktemp)
echo "[]" > "$TMPFILE"

# --- Helpers ---
is_sent() {
  local url="$1"
  grep -qF "$url" "$HISTORY_FILE" 2>/dev/null
}

add_to_history() {
  local url="$1" hash="$2"
  local now
  now=$(date +%s)
  local tmp_hist
  tmp_hist=$(mktemp)
  jq --arg url "$url" --arg hash "$hash" --argjson ts "$now" \
    '.articles += [{url: $url, hash: $hash, timestamp: $ts}]' \
    "$HISTORY_FILE" > "$tmp_hist" && mv "$tmp_hist" "$HISTORY_FILE"
}

add_article() {
  local title="$1" url="$2" source="$3" category="$4" desc="$5" score="${6:-0}"
  if is_sent "$url"; then return 0; fi
  local tmp
  tmp=$(mktemp)
  jq --arg t "$title" --arg u "$url" --arg s "$source" \
    --arg c "$category" --arg d "$desc" --argjson sc "$score" \
    '. += [{title: $t, url: $u, source: $s, category: $c, description: $d, score: $sc}]' \
    "$TMPFILE" > "$tmp" && mv "$tmp" "$TMPFILE"
}

cleanup_history() {
  local cutoff
  cutoff=$(($(date +%s) - DAYS_KEEP * 86400))
  local tmp
  tmp=$(mktemp)
  jq --argjson cutoff "$cutoff" '.articles |= map(select(.timestamp > $cutoff))' \
    "$HISTORY_FILE" > "$tmp" && mv "$tmp" "$HISTORY_FILE"
}

# Parse RSS XML to JSON via python3
rss_to_json() {
  python3 -c "
import sys, json, xml.etree.ElementTree as ET
try:
    root = ET.parse(sys.stdin).getroot()
    ch = root.find('channel') or root
    items = []
    for item in ch.iter('item'):
        items.append({
            'title': (item.findtext('title') or '').strip(),
            'url': (item.findtext('link') or '').strip(),
            'description': (item.findtext('description') or '')[:200].strip()
        })
    print(json.dumps(items[:8]))
except Exception:
    print('[]')
" 2>/dev/null
}

# --- Source: HackerNews Top ---
crawl_hackernews() {
  local ids
  ids=$(fcurl 'https://hacker-news.firebaseio.com/v0/topstories.json' | jq '.[:5][]') || return
  for id in $ids; do
    local item title url score
    item=$(fcurl "https://hacker-news.firebaseio.com/v0/item/${id}.json") || continue
    title=$(echo "$item" | jq -r '.title') || continue
    url=$(echo "$item" | jq -r '.url // "https://news.ycombinator.com/item?id='"${id}"'"') || continue
    score=$(echo "$item" | jq -r '.score // 0') || continue
    [ "$title" = "null" ] && continue
    add_article "$title" "$url" "hackernews" "tech" "" "$score"
  done
}

# --- Source: GitHub Trending ---
crawl_github() {
  local yesterday
  yesterday=$(date -d 'yesterday' +%Y-%m-%d 2>/dev/null || date -v-1d +%Y-%m-%d)
  local resp
  resp=$(fcurl "https://api.github.com/search/repositories?q=created:>$yesterday&sort=stars&order=desc&per_page=5") || return
  echo "$resp" | jq -c '.items[]? | {title: .full_name, url: .html_url, desc: (.description // "" | .[:150]), score: .stargazers_count}' 2>/dev/null | while IFS= read -r line; do
    local title url desc score
    title=$(echo "$line" | jq -r '.title')
    url=$(echo "$line" | jq -r '.url')
    desc=$(echo "$line" | jq -r '.desc')
    score=$(echo "$line" | jq -r '.score')
    [ -z "$title" ] && continue
    add_article "GitHub: $title" "$url" "github" "tech" "$desc" "$score"
  done
}

# --- Source: Claude Code Releases ---
crawl_claude() {
  local resp
  resp=$(fcurl "https://api.github.com/repos/anthropics/claude-code/releases?per_page=3") || return
  echo "$resp" | jq -c '.[]? | {title: .tag_name, url: .html_url, desc: (.body // "" | .[:200])}' 2>/dev/null | while IFS= read -r line; do
    local title url desc
    title=$(echo "$line" | jq -r '.title')
    url=$(echo "$line" | jq -r '.url')
    desc=$(echo "$line" | jq -r '.desc')
    add_article "Claude Code $title" "$url" "claude-code" "tech" "$desc" 100
  done
}

# --- Source: CoinDesk RSS ---
crawl_coindesk() {
  local items
  items=$(fcurl 'https://www.coindesk.com/arc/outboundfeeds/rss/' | rss_to_json) || return
  echo "$items" | jq -c '.[]?' 2>/dev/null | while IFS= read -r line; do
    local title url desc
    title=$(echo "$line" | jq -r '.title')
    url=$(echo "$line" | jq -r '.url')
    desc=$(echo "$line" | jq -r '.description')
    [ -z "$title" ] && continue
    add_article "$title" "$url" "coindesk" "crypto" "$desc" 50
  done
}

# --- Source: VnEconomy RSS ---
crawl_vneconomy() {
  local items
  items=$(fcurl 'https://vneconomy.vn/rss.rss' | rss_to_json) || return
  echo "$items" | jq -c '.[]?' 2>/dev/null | while IFS= read -r line; do
    local title url desc
    title=$(echo "$line" | jq -r '.title')
    url=$(echo "$line" | jq -r '.url')
    desc=$(echo "$line" | jq -r '.description')
    [ -z "$title" ] && continue
    add_article "$title" "$url" "vneconomy" "economy" "$desc" 50
  done
}

# --- Source: AI News RSS ---
crawl_ai_news() {
  local items
  items=$(fcurl 'https://artificialintelligence-news.com/feed/' | rss_to_json) || return
  echo "$items" | jq -c '.[]?' 2>/dev/null | while IFS= read -r line; do
    local title url desc
    title=$(echo "$line" | jq -r '.title')
    url=$(echo "$line" | jq -r '.url')
    desc=$(echo "$line" | jq -r '.description')
    [ -z "$title" ] && continue
    add_article "$title" "$url" "ai-news" "ai" "$desc" 50
  done
}

# --- Main ---
cleanup_history

crawl_hackernews
crawl_github
crawl_claude
crawl_coindesk
crawl_vneconomy
crawl_ai_news

# Sort by score desc, limit, output
result=$(jq 'sort_by(-.score) | .[:'"$MAX_ARTICLES"']' "$TMPFILE")

# Update history with sent articles
echo "$result" | jq -c '.[]?' | while IFS= read -r line; do
  url=$(echo "$line" | jq -r '.url')
  title=$(echo "$line" | jq -r '.title')
  hash=$(echo "$title" | md5sum | cut -d' ' -f1)
  add_to_history "$url" "$hash"
done

# Output
echo "$result"
rm -f "$TMPFILE"
