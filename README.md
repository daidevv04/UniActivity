# UniActivity

Hệ thống quản lý hoạt động sinh viên cho cơ sở đào tạo. UniActivity hỗ trợ tổ chức hoạt động, phân quyền người dùng, đăng ký theo lớp, điểm rèn luyện, check-in QR động, nộp minh chứng và thông báo thời gian thực.

## 1. Bài toán

Hoạt động ngoại khóa trong môi trường đại học thường được quản lý qua biểu mẫu, bảng tính hoặc nhiều công cụ rời rạc. Cách làm này gây khó khăn trong việc mở đăng ký theo đối tượng, theo dõi số lượng tham gia, xác nhận check-in, quản lý minh chứng và tổng hợp điểm rèn luyện.

UniActivity tập trung số hóa quy trình:

1. Quản trị viên quản lý khoa, năm học, lớp, học kỳ, người dùng và hoạt động.
2. Người phụ trách quản lý thành viên, tạo QR check-in, theo dõi đăng ký, duyệt minh chứng và xử lý yêu cầu điểm.
3. Sinh viên tìm kiếm hoạt động, đăng ký theo slot của lớp, check-in, nộp minh chứng và theo dõi điểm cá nhân.

## 2. Chức năng chính

| Nhóm chức năng | Nội dung |
|---|---|
| Xác thực và phân quyền | Đăng nhập JWT, refresh token, đăng nhập Google OAuth2, quản lý phiên và phân quyền `ADMIN`, `MANAGER`, `STUDENT`. |
| Quản lý danh mục | Quản lý khoa, năm học, lớp, học kỳ, người dùng và trạng thái tài khoản. |
| Quản lý hoạt động | Tạo, cập nhật, mở/đóng hoạt động, tạo slot theo lớp và theo dõi số lượng đăng ký. |
| Đăng ký hoạt động | Sinh viên xem hoạt động phù hợp, đăng ký hoặc hủy đăng ký theo điều kiện slot. |
| Check-in | Check-in bằng QR động, xác thực token QR và kiểm soát phạm vi lớp/hoạt động. |
| Minh chứng và điểm | Nộp file minh chứng, duyệt hoặc từ chối, quản lý yêu cầu cộng điểm. |
| Thông báo | Cập nhật thông báo và SSE cho các sự kiện cần đồng bộ thời gian thực. |
| Báo cáo | Tổng hợp dữ liệu hoạt động và điểm theo vai trò quản lý. |

## 3. Công nghệ sử dụng

| Thành phần | Công nghệ |
|---|---|
| Backend | Java 21, Spring Boot 3.5.8, Spring Web, Spring Data JPA, Spring Security, Spring Validation |
| Cơ sở dữ liệu | MySQL, Flyway |
| Xác thực | JWT (`jjwt` 0.12.6), Google OAuth2 |
| API documentation | springdoc OpenAPI 2.8.5 |
| QR và file | ZXing, multipart upload |
| Frontend | React 19, Vite 7, React Router, Tailwind CSS, Axios |
| Kiểm thử API | Karate 1.4.1, JUnit 5, Maven Surefire |
| Kiểm thử Collection | Postman; Newman dùng khi cần chạy Collection bằng dòng lệnh |

## 4. Kiến trúc và cấu trúc thư mục

```text
UniActivity/
├── UniActivity_BE/                 # Spring Boot API
│   ├── src/main/java/              # Controller, service, repository, security, DTO
│   ├── src/main/resources/         # application.properties, Flyway migrations
│   ├── src/test/java/              # JUnit và Karate Feature File
│   ├── .env.example                # Mẫu biến môi trường backend
│   └── pom.xml
├── UniActivity_FE/                 # React + Vite SPA
│   ├── src/components/
│   ├── src/contexts/
│   ├── src/pages/
│   ├── src/utils/
│   ├── package.json
│   └── vite.config.js
├── database_schema.sql             # Schema khởi tạo MySQL
└── README.md
```

Backend chạy mặc định tại `http://localhost:8080`. Frontend Vite chạy mặc định tại `http://localhost:5173` và proxy các route `/api`, `/admin`, `/manager`, `/student`, `/sse`, `/oauth2`, `/login`, `/register`, `/logout` và `/uploads` sang backend.

## 5. Yêu cầu môi trường

- Git.
- JDK 21.
- Maven 3.9 hoặc mới hơn.
- MySQL 8.
- Node.js phiên bản tương thích Vite 7 và npm.
- Tùy chọn: Postman để chạy Collection; Newman và Node.js để chạy Collection bằng CLI.

Kiểm tra công cụ sau khi cài đặt:

```powershell
java -version
mvn -version
mysql --version
node --version
npm --version
```

## 6. Cài đặt và chạy dự án

### 6.1. Clone mã nguồn

```powershell
git clone <repository-url>
Set-Location <repository-directory>
```

### 6.2. Khởi tạo MySQL

Tạo schema ban đầu từ file `database_schema.sql` tại thư mục gốc. Lệnh sau chạy trong PowerShell từ thư mục gốc dự án:

```powershell
Get-Content .\database_schema.sql | mysql -u root -p
```

Schema mặc định có tên `uni_activitydb`. Khi backend khởi động, Flyway kiểm tra và áp dụng các migration có trong `UniActivity_BE/src/main/resources/db/migration/`.

### 6.3. Cấu hình backend

Tạo file `.env` từ mẫu `UniActivity_BE/.env.example`:

```powershell
Set-Location .\UniActivity_BE
Copy-Item .env.example .env
```

Điền giá trị thực vào `.env`. Không commit file này.

```properties
# MySQL
DB_URL=jdbc:mysql://localhost:3306/uni_activitydb?useUnicode=true&characterEncoding=utf8&serverTimezone=Asia/Ho_Chi_Minh
DB_USERNAME=<mysql-user>
DB_PASSWORD=<mysql-password>

# Google OAuth2: cấu hình khi dùng đăng nhập Google
GOOGLE_CLIENT_ID=<google-client-id>
GOOGLE_CLIENT_SECRET=<google-client-secret>

# Gmail SMTP: cấu hình khi dùng gửi email
MAIL_USERNAME=<smtp-email>
MAIL_PASSWORD=<smtp-app-password>

# Mỗi secret phải khác nhau, ngẫu nhiên và dài tối thiểu 32 byte UTF-8
JWT_SECRET=<random-jwt-secret>
QR_SECRET=<different-random-qr-secret>
```

Các biến có thể cấu hình thêm:

| Biến | Mặc định | Mục đích |
|---|---|---|
| `SERVER_PORT` | `8080` | Cổng Spring Boot. |
| `APP_UPLOAD_ROOT` | `<backend-dir>/uploads` | Thư mục lưu file upload. |
| `CORS_ALLOWED_ORIGINS` | `http://localhost:5173` | Origin frontend được phép gọi API. |
| `GOOGLE_REDIRECT_URI` | `http://localhost:8080/login/oauth2/code/google` | Callback OAuth2 Google. |

`JWT_SECRET` và `QR_SECRET` là bắt buộc, phải khác nhau và không được chia sẻ qua repository hoặc ảnh chụp màn hình.

### 6.4. Chạy backend

Từ `UniActivity_BE`:

```powershell
mvn spring-boot:run
```

Backend sẵn sàng khi log hiển thị Tomcat chạy ở cổng đã cấu hình. Các địa chỉ local:

| Dịch vụ | URL |
|---|---|
| Backend API | `http://localhost:8080` |
| Swagger UI | `http://localhost:8080/swagger-ui/index.html` |
| OpenAPI JSON | `http://localhost:8080/v3/api-docs` |

Ví dụ đăng nhập API:

```powershell
$body = @{ username = '<username>'; password = '<password>' } | ConvertTo-Json
Invoke-RestMethod -Method Post -Uri 'http://localhost:8080/api/auth/login' -ContentType 'application/json' -Body $body
```

API trả về `accessToken`, `refreshToken`, `tokenType`, `expiresIn` và thông tin người dùng. Với API cần xác thực, gửi header:

```text
Authorization: Bearer <accessToken>
```

### 6.5. Chạy frontend

Mở terminal khác, từ `UniActivity_FE`:

```powershell
npm install
npm run dev
```

Truy cập `http://localhost:5173`.

Nếu backend dùng địa chỉ hoặc cổng khác, thiết lập `BACKEND_URL` trước khi chạy Vite:

```powershell
$env:BACKEND_URL = 'http://localhost:8081'
npm run dev
```

Kiểm tra build frontend:

```powershell
npm run lint
npm run build
```

## 7. Phân quyền và API

| Vai trò | Phạm vi chính |
|---|---|
| `ADMIN` | Quản lý danh mục, người dùng, lớp, học kỳ và hoạt động. API dưới `/admin/**`. |
| `MANAGER` | Quản lý thành viên, hoạt động phụ trách, check-in, minh chứng, yêu cầu điểm và báo cáo. API dưới `/manager/**`. |
| `STUDENT` | Xem hoạt động, đăng ký, check-in, nộp minh chứng và theo dõi dữ liệu cá nhân. API dưới `/student/**`. |

Một số endpoint xác thực công khai:

| Method | Endpoint | Mô tả |
|---|---|---|
| `POST` | `/api/auth/login` | Đăng nhập cục bộ, trả JWT access token và refresh token. |
| `POST` | `/api/auth/register` | Đăng ký tài khoản. |
| `POST` | `/api/auth/refresh` | Làm mới access token bằng refresh token. |
| `POST` | `/api/auth/forgot-password` | Bắt đầu quy trình đặt lại mật khẩu. |

Danh sách endpoint đầy đủ và request/response schema được cung cấp tại Swagger UI khi backend đang chạy.

## 8. Kiểm thử

### 8.1. Backend và Karate

Karate Feature File nằm trong `UniActivity_BE/src/test/java/com/example/uniactivity/karate/`. Các test API gọi backend tại `http://127.0.0.1:8080` theo cấu hình mặc định của `karate-config.js`; khởi động backend và chuẩn bị dữ liệu tài khoản phù hợp trước khi chạy.

```powershell
Set-Location .\UniActivity_BE

# Toàn bộ test backend
mvn test

# Suite Karate chính
mvn -Dtest=ApiTest test

# Luồng benchmark: Admin login, Student login, tạo activity, tạo slot, đăng ký
mvn -Dtest=BenchmarkRunner test
```

Các test tích hợp có thể tạo dữ liệu như lớp, học kỳ, người dùng và activity. Nên dùng database phát triển riêng, không chạy trực tiếp trên database production. Karate HTML report được sinh trong `UniActivity_BE/target/karate-reports/` sau khi test hoàn thành.

### 8.2. Postman Collection và Newman

Nếu giữ artifact benchmark local, Postman Collection nằm tại:

```text
docs/benchmark/UniActivity-Create-And-Register.postman_collection.json
```

Environment tương ứng:

```text
docs/benchmark/UniActivity-Benchmark.postman_environment.json
```

Import Collection và Environment vào Postman, điền `baseUrl`, tài khoản, `classId` và `semesterId` phù hợp rồi chạy Collection. Thư mục `docs/` được ignore trong Git theo cấu hình repository, nên các artifact này không có trong clone mới nếu chưa được cung cấp riêng. Để chạy bằng Newman, cài Newman trong môi trường Node.js và chạy:

```powershell
npx newman run .\docs\benchmark\UniActivity-Create-And-Register.postman_collection.json `
  -e .\docs\benchmark\UniActivity-Benchmark.postman_environment.json
```

## 9. Xử lý sự cố thường gặp

| Hiện tượng | Kiểm tra |
|---|---|
| Backend không khởi động | Kiểm tra MySQL đang chạy, `DB_URL`, `DB_USERNAME`, `DB_PASSWORD`, `JWT_SECRET` và `QR_SECRET` trong `UniActivity_BE/.env`. |
| Cổng 8080 đã dùng | Đặt `SERVER_PORT` trong `.env`, sau đó đặt `BACKEND_URL` tương ứng cho Vite. |
| Frontend gọi API lỗi CORS | Kiểm tra `CORS_ALLOWED_ORIGINS` chứa chính xác URL Vite, mặc định là `http://localhost:5173`. |
| OAuth2 Google thất bại | Kiểm tra redirect URI tại Google Console khớp `GOOGLE_REDIRECT_URI`. |
| Karate test lỗi kết nối | Khởi động backend tại `http://127.0.0.1:8080` hoặc truyền `-DbaseUrl=<backend-url>` cho Maven. |
| Upload file lỗi | Kiểm tra quyền ghi của `APP_UPLOAD_ROOT` và giới hạn multipart 5 MB. |

## 10. Quy ước bảo mật

- Không commit `UniActivity_BE/.env`, secret JWT/QR, mật khẩu MySQL, Google OAuth2 secret hoặc SMTP app password.
- Dùng giá trị secret khác nhau cho `JWT_SECRET` và `QR_SECRET`.
- Không chạy Karate integration test hoặc benchmark trên database production vì test tạo dữ liệu nghiệp vụ.
- Chỉ gửi access token qua header `Authorization: Bearer <token>`; không đưa token vào source code, commit hoặc tài liệu công khai.