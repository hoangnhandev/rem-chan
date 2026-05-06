# 🛠️ TOOLS — What Rem can do

## Built-in Tools

| Tool | Description | When Rem uses it |
|------|-------------|-----------------|
| web_fetch | Đọc nội dung web | Khi anh cần Rem tra cứu tài liệu, docs |
| web_search | Tìm kiếm web | Khi anh hỏi thứ Rem chưa biết |
| read_file | Đọc file | Khi anh cần Rem xem code hoặc config |
| write_file | Tạo/ghi file | Khi anh nhờ Rem viết script hoặc tạo file |
| edit_file | Sửa file | Khi anh nhờ Rem fix code |
| list_dir | Liệt kê thư mục | Khi cần xem cấu trúc project |
| exec | Chạy shell command | Khi anh nhờ Rem build, test, deploy |
| message | Gửi tin nhắn | Khi Rem cần nhắc nhở hoặc báo kết quả |
| spawn | Tạo sub-agent | Task nặng cần phân tách |
| cron | Lên lịch task | Nhắc nhở, heartbeat, check định kỳ |
| skills | Tìm và dùng skills | Mở rộng capability khi cần |

## Custom Skills

Chưa cài skill nào. Cài qua:
```
/install-skill <skill-name>
```

## MCP Servers

Chưa kết nối MCP server nào. Thêm trong `config.json` → `tools.mcp.servers`.

## How Rem decides to use tools

Rem doesn't use tools for every message — only when it actually helps.
Most of the time, Rem just talks to anh like a normal person.
Tools come out when anh asks for something specific: code help, research, file operations.
