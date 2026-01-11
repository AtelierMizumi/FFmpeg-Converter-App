# Hướng dẫn Setup PostgreSQL trên Aiven

## Bước 1: Kết nối với Aiven PostgreSQL

### Cách 1: Sử dụng Aiven Console (Web Interface)
1. Đăng nhập vào [Aiven Console](https://console.aiven.io)
2. Chọn PostgreSQL service của bạn
3. Click vào tab **Query Editor** hoặc **Database**
4. Copy và paste từng câu lệnh SQL (từng file một)

### Cách 2: Sử dụng psql CLI
```bash
# Lấy connection string từ Aiven Console
# Format: postgres://username:password@host:port/database?sslmode=require

psql "postgres://avnadmin:your-password@your-host.aivencloud.com:12345/defaultdb?sslmode=require"
```

### Cách 3: Sử dụng pgAdmin hoặc DBeaver
1. Tải thông tin kết nối từ Aiven Console
2. Import CA certificate nếu cần
3. Kết nối và chạy SQL files

---

## Bước 2: Chạy các SQL Files theo thứ tự

### File 1: Create Tables (01_create_tables.sql)
```bash
# Nếu dùng psql CLI:
psql "your-connection-string" -f database/01_create_tables.sql

# Hoặc copy-paste toàn bộ nội dung vào Query Editor
```

**Lưu ý:** File này đã được format lại để tương thích với Aiven. Tất cả các câu CREATE TABLE đã được viết trên một dòng duy nhất (compact syntax).

### File 2: Create Indexes (02_create_indexes.sql)
```bash
psql "your-connection-string" -f database/02_create_indexes.sql
```

Tạo các indexes để tối ưu performance cho các query analytics.

### File 3: Create User (03_create_user.sql)
```bash
psql "your-connection-string" -f database/03_create_user.sql
```

**QUAN TRỌNG:** Trước khi chạy, thay thế `YOUR_STRONG_PASSWORD_HERE` bằng mật khẩu mạnh:
```sql
-- Tạo password mạnh:
openssl rand -base64 32

-- Sau đó thay vào file:
CREATE ROLE analytics_worker WITH LOGIN PASSWORD 'password-ban-vua-tao';
```

### File 4: Metabase Queries (04_metabase_queries.sql)
File này chứa các query mẫu cho Metabase dashboard. **KHÔNG** cần chạy file này, chỉ copy từng query khi cần thiết.

---

## Bước 3: Verify Setup

### Kiểm tra Tables đã được tạo:
```sql
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND table_type = 'BASE TABLE';
```

Kết quả mong đợi:
- app_sessions
- app_events
- app_errors

### Kiểm tra Indexes:
```sql
SELECT tablename, indexname 
FROM pg_indexes 
WHERE schemaname = 'public' 
  AND tablename IN ('app_sessions', 'app_events', 'app_errors')
ORDER BY tablename, indexname;
```

### Kiểm tra User permissions:
```sql
SELECT grantee, table_name, privilege_type
FROM information_schema.role_table_grants
WHERE grantee = 'analytics_worker'
ORDER BY table_name, privilege_type;
```

---

## Troubleshooting

### Lỗi: "functions in index expression must be marked IMMUTABLE"
- **Nguyên nhân:** Hàm DATE() không được đánh dấu IMMUTABLE trong PostgreSQL
- **Giải pháp:** Đã fix bằng cách dùng `::date` thay vì `DATE()` - phiên bản mới đã được cập nhật

### Lỗi: "syntax error at or near..."
- **Nguyên nhân:** Syntax xuống dòng không tương thích
- **Giải pháp:** Đã fix trong các file SQL mới, hãy sử dụng phiên bản mới nhất

### Lỗi: "permission denied"
- **Nguyên nhân:** User không có quyền
- **Giải pháp:** Đảm bảo bạn đang dùng user `avnadmin` hoặc user có quyền superuser

### Lỗi: "role already exists"
- **Nguyên nhân:** User `analytics_worker` đã tồn tại
- **Giải pháp:** Bỏ qua hoặc xóa user cũ:
```sql
DROP ROLE IF EXISTS analytics_worker;
```

### Lỗi: "SSL connection required"
- **Nguyên nhân:** Aiven yêu cầu SSL
- **Giải pháp:** Thêm `?sslmode=require` vào connection string

---

## Connection String cho Cloudflare Worker

Sau khi setup xong, sử dụng connection string này cho Cloudflare Worker:

```
postgresql://analytics_worker:YOUR_PASSWORD@your-host.aivencloud.com:12345/defaultdb?sslmode=require
```

Lưu vào Cloudflare Worker Secrets:
```bash
wrangler secret put DATABASE_URL
# Paste connection string khi được hỏi
```

---

## Security Checklist

- [ ] Đã thay password mặc định trong file 03_create_user.sql
- [ ] Password có ít nhất 32 ký tự, random
- [ ] Connection string được lưu trong secrets, KHÔNG commit lên Git
- [ ] User `analytics_worker` chỉ có quyền INSERT và SELECT
- [ ] SSL được bật (sslmode=require)

---

## Các thay đổi đã thực hiện

### 01_create_tables.sql
- ✅ Format lại CREATE TABLE statements thành single-line
- ✅ Xóa inline comments gây lỗi syntax
- ✅ Giữ nguyên tất cả columns và constraints

### 02_create_indexes.sql
- ✅ Format lại multi-line indexes thành single-line
- ✅ Thay `DATE()` bằng `::date` (cast operator - IMMUTABLE)
- ✅ Giữ nguyên WHERE clauses và GIN indexes
- ✅ Tất cả composite indexes đã được compact

### 03_create_user.sql
- ✅ Format lại CREATE ROLE thành single-line
- ✅ Giữ nguyên tất cả GRANT statements

### 04_metabase_queries.sql
- ✅ Thay tất cả `DATE()` bằng `::date` để tương thích hoàn toàn
- ✅ File này chỉ là reference queries, không bắt buộc phải chạy
