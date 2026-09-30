# 3.4.1. Cấu trúc và tổ chức Feature File

Đề tài sử dụng Karate Framework để kiểm thử tự động RESTful API của hệ thống UniActivity. Karate dùng cú pháp Gherkin, vì vậy mỗi kịch bản được mô tả bằng các bước dễ đọc như `Given`, `When`, `Then`. Framework hỗ trợ gửi HTTP request, gắn JWT vào header, kiểm tra HTTP status và ghi nhận JSON response.

Bộ test không đặt toàn bộ kịch bản trong một tệp. Mỗi Feature File phụ trách một nhóm nghiệp vụ. Cách tổ chức này giúp dễ đọc, dễ xác định nhóm API lỗi và dễ bổ sung test case sau này.

Trong phiên bản hiện tại, `ApiTest.java` chạy 55 Scenario thuộc 8 Feature File:

| Feature File | Mã Test Case | Phạm vi kiểm thử |
|---|---|---|
| `auth.feature` | TC-001–TC-008, TC-014 | Đăng nhập, refresh token, phiên hiện tại, logout JWT và OAuth exchange code không hợp lệ. |
| `profile.feature` | TC-018, TC-022, TC-026 | Xem hồ sơ, đổi mật khẩu đúng và sai mật khẩu hiện tại. |
| `admin-catalog.feature` | TC-009–TC-017, TC-019–TC-025 | Năm học, học kỳ, khoa và lớp. |
| `admin-users.feature` | TC-027–TC-034 | Quản lý tài khoản, khóa/mở, reset mật khẩu và RBAC. |
| `activities.feature` | TC-035–TC-041 | Danh sách, tạo, xem, cập nhật activity và slot. |
| `manager.feature` | TC-042–TC-044 | Điểm danh tay, xem đăng ký và duyệt minh chứng. |
| `student.feature` | TC-045–TC-053 | Danh sách activity, đăng ký, hủy đăng ký và check-in. |
| `evidence.feature` | TC-054–TC-055 | Nộp ảnh minh chứng và chặn quá ba ảnh. |

Cấu trúc thư mục kiểm thử như sau:

```text
src/test/java/
├── karate-config.js
└── com/example/uniactivity/karate/
    ├── ApiTest.java
    ├── auth.feature
    ├── profile.feature
    ├── admin-catalog.feature
    ├── admin-users.feature
    ├── activities.feature
    ├── manager.feature
    ├── student.feature
    ├── evidence.feature
    └── helpers/
        ├── setup.feature
        ├── login.feature
        ├── create-student.feature
        ├── create-activity.feature
        ├── prepare-reg.feature
        ├── manual-checkin.feature
        ├── dynamic-qr.feature
        └── upload-evidence.feature
```

`karate-config.js` khai báo `baseUrl`, tài khoản Admin, dữ liệu test và gọi `setup.feature` một lần bằng `karate.callSingle()`. `setup.feature` tạo fixture dùng chung gồm năm học, khoa, lớp, học kỳ, Student, Manager, activity, slot và token. Các Feature File dùng lại fixture qua biến `fixture`.

Các helper tách phần chuẩn bị dữ liệu khỏi Scenario chính. Ví dụ `prepare-reg.feature` tạo một Student, đăng nhập và đăng ký activity. Nhờ vậy Scenario chỉ cần gọi helper với tên test case:

```karate
* def prep = call read('helpers/prepare-reg.feature') { name: 'TC46' }
```

Sau đó Scenario gửi request nghiệp vụ và kiểm tra kết quả HTTP. Response được in vào log bằng `print response` để phục vụ quan sát khi chạy test:

```karate
Given path '/student/api/activities', fixture.liveActivityId, 'register'
* configure headers = { Authorization: '#("Bearer " + prep.token)' }
When method post
Then status 409
* print response
```

Mỗi Feature File gồm ba phần chính:

- `Feature`: tên nhóm nghiệp vụ được kiểm thử.
- `Background`: thiết lập dùng chung, như `url baseUrl` hoặc header JWT.
- `Scenario`: một test case cụ thể, gồm request, mã trạng thái mong đợi và response ghi trong log.

Cách tổ chức này tách rõ cấu hình, dữ liệu chuẩn bị và kịch bản nghiệp vụ. Các Scenario thay đổi dữ liệu vẫn tự tạo Student hoặc activity cần thiết bằng helper, nên không phụ thuộc kết quả Scenario khác.

> Lưu ý: Bộ test hiện ưu tiên kiểm tra HTTP status và ghi log response để mã dễ đọc cho người mới học Karate. Khi cần kiểm thử hồi quy chặt hơn, bổ sung lại các câu lệnh `match response` cho các field quan trọng như `id`, `status`, `accessToken` và `message`.