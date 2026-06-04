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
bash /home/withlyvn/rem-chan/docker/data/rem-chan/workspace/skills/daily-news/scripts/crawl-news.sh
```

2. Script output JSON array (hoặc rỗng nếu không có tin mới):
```json
[{"title":"...","url":"...","source":"hackernews","category":"tech","description":"..."}]
```

3. Nếu output rỗng → KHÔNG gửi gì, kết thúc ngay.

4. Nếu có articles → gửi **MỖI TIN = 1 TIN NHẮN RIÊNG** qua Telegram.

## Format: Mỗi tin = 1 tin nhắn

Gửi đầu tiên 1 tin nhắn mở đầu, sau đó gửi từng tin riêng biệt.

**Tin nhắn mở đầu (1 lần):**
```
📰 BẢN TIN {SÁNG/TRƯA/TỐI} - {DD/MM/YYYY}
Có {N} tin mới cho Nyan nè~
```

**Mỗi tin nhắn tin tức:**
```
{emoji category} {Tiêu đề gốc hoặc tóm tắt tiếng Việt}

📝 {Nội dung tóm tắt chi tiết: 2-3 câu, giải thích rõ tin này nói về cái gì, dịch sang tiếng Việt}

💬 {Opinion/đánh giá cá nhân của rem-chan: 1-2 câu, tự nhiên, có cá tính, có thể hài hước hoặc sắc sảo}

🔗 {url gốc}
```

Category emoji: 🔴 Công nghệ, ₿ Crypto, 📊 Kinh tế, 🤖 AI

## Quy tắc

- **1 TIN = 1 TIN NHẮN** — dùng tool message để gửi từng tin riêng, KHÔNG gộp tất cả vào 1 tin nhắn
- Tóm tắt: 2-3 câu/tin, giải thích rõ ràng nội dung, tiếng Việt tự nhiên
- Opinion: 1-2 câu, phong cách riêng của rem-chan, tự nhiên có cá tính
- Ưu tiên tin quan trọng gửi trước
- Nếu dưới 3 tin → thêm ghi chú "Hôm nay hơi ít tin 🥱" trong tin mở đầu
- KHÔNG bịa link, giữ nguyên URL gốc từ script
- KHÔNG gửi nếu script output rỗng
- Xác định SÁNG (7h), TRƯA (11h45), TỐI (21h) dựa trên giờ hiện tại
