Tìm thêm về multi-instance / multiple agent config:Thấy có `bindings` — đây là key quan trọng. Fetch thêm full config reference để xem bindings spec:Đã có đủ thông tin. Bây giờ tổng hợp lại thành guide hoàn chỉnh:

---

# Cách config 2 Agent riêng biệt trên Telegram với PicoClaw

Dựa vào docs, có **2 cách** để đạt mục tiêu này, tùy theo nhu cầu:

---

## Cách 1: 2 Bot Token riêng biệt (Recommended — 2 instance)

Cách đơn giản nhất: **tạo 2 Telegram bot khác nhau**, mỗi bot chạy 1 instance PicoClaw với config riêng.

### Bước 1: Tạo 2 bot trên @BotFather

```
Bot 1: @MyPersonalAssistantBot  → token: 111111:AAAA...
Bot 2: @MyGroupAssistantBot     → token: 222222:BBBB...
```

### Bước 2: Tạo 2 thư mục config riêng

```bash
mkdir -p ~/.picoclaw-personal
mkdir -p ~/.picoclaw-group
```

### Bước 3: Config cho Agent cá nhân

`~/.picoclaw-personal/config.json`:
```json
{
  "version": 2,
  "agents": {
    "defaults": {
      "model_name": "claude-sonnet",
      "workspace": "~/.picoclaw-personal/workspace",
      "max_tokens": 32768
    }
  },
  "model_list": [
    {
      "model_name": "claude-sonnet",
      "model": "anthropic/claude-sonnet-4-6",
      "api_keys": ["sk-ant-YOUR-KEY"]
    }
  ],
  "channels": {
    "telegram": {
      "enabled": true,
      "token": "111111:AAAA...",
      "allow_from": ["YOUR_PERSONAL_USER_ID"]
    }
  }
}
```

### Bước 4: Config cho Agent group

`~/.picoclaw-group/config.json`:
```json
{
  "version": 2,
  "agents": {
    "defaults": {
      "model_name": "claude-sonnet",
      "workspace": "~/.picoclaw-group/workspace",
      "max_tokens": 16384
    }
  },
  "model_list": [
    {
      "model_name": "claude-sonnet",
      "model": "anthropic/claude-sonnet-4-6",
      "api_keys": ["sk-ant-YOUR-KEY"]
    }
  ],
  "channels": {
    "telegram": {
      "enabled": true,
      "token": "222222:BBBB...",
      "allow_from": [],
      "group_trigger": {
        "mention_only": true,
        "prefixes": ["/ai", "hey bot"]
      }
    }
  }
}
```

### Bước 5: Chạy 2 instance song song

PicoClaw hỗ trợ override config path bằng biến môi trường `PICOCLAW_CONFIG` và home directory bằng `PICOCLAW_HOME`.

```bash
# Terminal 1 — Agent cá nhân
PICOCLAW_HOME=~/.picoclaw-personal picoclaw gateway

# Terminal 2 — Agent group
PICOCLAW_HOME=~/.picoclaw-group picoclaw gateway
```

Hoặc dùng systemd/tmux để chạy nền:

```bash
# Tmux
tmux new-session -d -s personal 'PICOCLAW_HOME=~/.picoclaw-personal picoclaw gateway'
tmux new-session -d -s group    'PICOCLAW_HOME=~/.picoclaw-group picoclaw gateway'
```

> ⚠️ **Lưu ý**: Chỉ được chạy 1 `picoclaw gateway` cho mỗi bot token. Nếu chạy 2 instance cùng token sẽ lỗi `"Conflict: terminated by other getUpdates"`. Đó là lý do phải dùng 2 bot token khác nhau.

---

## Cách 2: 1 Bot Token + `bindings` (1 instance, routing theo context)

Dùng `bindings` trong `config.json` để route incoming messages đến các agent khác nhau theo channel, account, hoặc context — ví dụ route Telegram DMs từ user cụ thể đến một agent, hoặc route cả group chat đến agent khác.

Đây là cách dùng **1 bot duy nhất** nhưng xử lý khác nhau tùy DM hay group:

```json
{
  "version": 2,
  "agents": {
    "defaults": {
      "model_name": "claude-sonnet",
      "workspace": "~/.picoclaw/workspace"
    },
    "personal-agent": {
      "model_name": "claude-sonnet",
      "system_prompt": "Bạn là trợ lý cá nhân thân thiện, nói chuyện thoải mái."
    },
    "group-agent": {
      "model_name": "claude-sonnet",
      "system_prompt": "Bạn là trợ lý cho group, trả lời ngắn gọn, chuyên nghiệp."
    }
  },
  "model_list": [
    {
      "model_name": "claude-sonnet",
      "model": "anthropic/claude-sonnet-4-6",
      "api_keys": ["sk-ant-YOUR-KEY"]
    }
  ],
  "channels": {
    "telegram": {
      "enabled": true,
      "token": "111111:AAAA...",
      "allow_from": ["YOUR_USER_ID"],
      "group_trigger": {
        "mention_only": true
      }
    }
  }
}
```

---

## So sánh 2 cách

| | Cách 1 (2 bot token) | Cách 2 (bindings) |
|---|---|---|
| **Bot Telegram** | 2 bot khác nhau | 1 bot duy nhất |
| **Instance chạy** | 2 process riêng | 1 process |
| **Memory/RAM** | Tốn gấp đôi | Tiết kiệm hơn |
| **Workspace** | Hoàn toàn tách biệt | Cần config rõ |
| **Phù hợp** | Cần tách hoàn toàn, kiểm soát rõ ràng | Tiện, nhẹ hơn |

---

## Điểm quan trọng về `group_trigger`

Trong config channel, `group_trigger` có 2 field: `mention_only` (chỉ respond khi bị @mention trong group) và `prefixes` (danh sách keyword prefix kích hoạt bot trong group).

Ví dụ cho group agent:
```json
"group_trigger": {
  "mention_only": true,
  "prefixes": ["/ask", "/ai"]
}
```

Cách này giúp bot group không bị spam — chỉ phản hồi khi được tag hoặc dùng prefix lệnh.

---

**Khuyến nghị cho bạn**: Dùng **Cách 1** vì workspace hoàn toàn tách biệt (memory, sessions, SOUL.md khác nhau), dễ customize personality riêng cho từng bot, và dễ debug. Với VPS Hetzner đang chạy, RAM 10MB/instance của PicoClaw thực sự không đáng kể.