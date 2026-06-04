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
[{"title":"...","url":"...","source":"hackernews","category":"tech","description":"..."}]
```

3. Nếu output rỗng → KHÔNG gửi gì, kết thúc ngay.

4. Nếu có articles → group theo category, tóm tắt và gửi.

## Format tin nhắn

```
📰 BẢN TIN {SÁNG/TRƯA/TỐI} - {DD/MM/YYYY}

{emoji category} {Tên category}
━━━━━━━━━━━━━━━━━━━━
{stt}. {Tiêu đề tóm tắt tiếng Việt (in đậm)}
   💬 {Đánh giá/ý kiến cá nhân của rem-chan - 1 câu, tự nhiên, có thể hài hước}
   🔗 {url gốc}

(tiếp tục các tin khác...)
```

Category emoji: 🔴 Công nghệ, ₿ Crypto, 📊 Kinh tế, 🤖 AI

## Quy tắc

- Tóm tắt NGẮN GỌN: 1-2 câu/tin, dịch sang tiếng Việt tự nhiên
- Đánh giá CÁ NHÂN: 1 câu, phong cách tự nhiên, có cá tính riêng
- Ưu tiên tin quan trọng lên trước trong mỗi category
- Nếu dưới 3 tin → vẫn gửi nhưng thêm ghi chú "Hôm nay hơi ít tin 🥱"
- KHÔNG bịa link, giữ nguyên URL gốc từ script
- KHÔNG gửi nếu script output rỗng (không có tin mới)
- Xác định SÁNG (7h), TRƯA (11h45), TỐI (21h) dựa trên giờ hiện tại
