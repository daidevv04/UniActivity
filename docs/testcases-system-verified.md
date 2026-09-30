# Danh sách 55 testcase API đã đối chiếu hệ thống

Phạm vi đúng Mục 3.1.2. Chỉ dùng endpoint và HTTP method đang tồn tại trong source hiện tại. Dữ liệu `suffix` là chuỗi duy nhất theo lần chạy; token luôn dùng header `Authorization: Bearer <token>`.

| Mã TC | Endpoint & Phương thức | Mục tiêu kiểm thử | Điều kiện tiên quyết | Dữ liệu đầu vào | Các bước thực hiện | Kết quả mong đợi |
|---|---|---|---|---|---|---|
| TC-001 | POST /api/auth/login | Xác thực đăng nhập hợp lệ. | Student A tồn tại, ACTIVE. | `{ "username": "<studentA.username>", "password": "Karate123@" }` | (1) POST login. (2) Kiểm tra response. | 200; có accessToken, refreshToken, tokenType="Bearer"; user.username/role/status khớp Student A. |
| TC-002 | POST /api/auth/login | Từ chối đăng nhập sai mật khẩu. | Student A tồn tại. | `{ "username": "<studentA.username>", "password": "WrongPass123" }` | (1) POST login. | 401; có error; không có accessToken. |
| TC-003 | POST /api/auth/login | Validation username rỗng. | Không có. | `{ "username": "", "password": "Karate123@" }` | (1) POST login. | 400; error="Vui lòng nhập email hoặc mã tài khoản và mật khẩu." |
| TC-004 | POST /api/auth/refresh | Từ chối refresh token sai. | Không có. | `{ "refreshToken": "invalid-token-123" }` | (1) POST refresh. | 401; có error; không có accessToken. |
| TC-005 | GET /api/auth/me | Chặn lấy phiên khi thiếu JWT. | Không gửi JWT. | Không có body/header Authorization. | (1) GET /me. | 401. |
| TC-006 | GET /api/auth/me | Lấy phiên bằng JWT hợp lệ. | Student A đã login. | Bearer `<studentAToken>`. | (1) GET /me. | 200; id, username, role="STUDENT" khớp Student A. |
| TC-007 | POST /api/auth/refresh | Cấp access token mới từ refresh token hợp lệ. | Student A đã login. | `{ "refreshToken": "<studentARefreshToken>" }` | (1) POST refresh. | 200; accessToken kiểu string; tokenType="Bearer". |
| TC-008 | POST /api/auth/logout-jwt; GET /api/auth/me | Thu hồi JWT sau logout. | Student B đã login. | Bearer `<studentBToken>`. | (1) POST logout-jwt. (2) GET /me bằng token cũ. | Logout 200 có message; GET /me trả 401. |
| TC-009 | GET /admin/academic-years/api | Lấy danh sách năm học. | Admin đã login. | Bearer `<adminToken>`. | (1) GET danh sách. | 200; JSON array; mỗi item có id, code. |
| TC-010 | POST /admin/academic-years/api | Tạo năm học hợp lệ. | Admin đã login; code chưa tồn tại. | `{ "code": "KARATE-<suffix>", "startYear": 2026, "endYear": 2027, "status": "ACTIVE" }` | (1) POST. (2) Lưu response.id. | 200; có id; code/startYear/endYear đúng. |
| TC-011 | GET /admin/academic-years/api/{id} | Xem chi tiết năm học. | TC-010 thành công. | path id=`<academicYearId>`. | (1) GET theo id. | 200; id và code khớp TC-010. |
| TC-012 | PUT /admin/academic-years/api/{id} | Cập nhật năm học. | Năm học từ TC-010 tồn tại. | `{ "code": "KARATE-UPD-<suffix>", "startYear": 2026, "endYear": 2028, "status": "ACTIVE" }` | (1) PUT theo id. (2) GET lại. | PUT 200; GET có code/endYear mới. |
| TC-013 | GET /admin/academic-years/api/{id} | Xử lý id năm học không tồn tại. | Admin đã login. | path id=`999999999`. | (1) GET. | 404; response.status=404; có message. |
| TC-014 | POST /api/auth/oauth2/exchange | Từ chối OAuth exchange code rỗng và code giả. | Không có. | (a) `{ "code": "" }`; (b) `{ "code": "fake-oauth-code" }`. | (1) POST với (a). (2) POST với (b). | (1) 400, error="OAuth exchange code is required.". (2) 401, error="OAuth exchange code is invalid or expired."; không có accessToken. |
| TC-015 | GET /admin/semesters/api | Lấy danh sách học kỳ. | Admin đã login. | Bearer `<adminToken>`. | (1) GET danh sách. | 200; JSON array; mỗi item có id, name. |
| TC-016 | POST /admin/semesters/api | Tạo học kỳ hợp lệ. | Admin đã login. | `{ "name": "Học kỳ Karate <suffix>", "startDate": "2027-01-01", "endDate": "2027-05-31", "isCurrent": false }` | (1) POST. (2) Lưu id. | 200; có id, name, startDate, endDate. |
| TC-017 | POST /admin/semesters/api/{id}/set-current | Đặt học kỳ làm hiện tại. | TC-016 thành công. | path id=`<semesterId>`. | (1) POST set-current. (2) GET danh sách. | 200; học kỳ vừa tạo có isCurrent=true; tối đa một học kỳ hiện tại. |
| TC-018 | GET /api/profile | Xem hồ sơ cá nhân. | Student đã login. | Bearer `<studentToken>`. | (1) GET /api/profile. | 200; id, username, fullName, email, role="STUDENT", status="ACTIVE" khớp tài khoản. |

| TC-019 | GET /admin/faculties/api | Lấy danh sách khoa. | Admin đã login. | Bearer `<adminToken>`. | (1) GET danh sách. | 200; JSON array; item có id, code, name. |
| TC-020 | POST /admin/faculties/api | Tạo khoa hợp lệ. | Admin; code chưa tồn tại. | `{ "code": "KARATE-<suffix>", "name": "Khoa Karate <suffix>", "status": "ACTIVE" }` | (1) POST. (2) Lưu id. | 200; có id, code, name. |
| TC-021 | PUT /admin/faculties/api/{id} | Cập nhật khoa. | TC-020 thành công. | `{ "code": "KARATE-UPD-<suffix>", "name": "Khoa Karate Updated", "status": "ACTIVE" }` | (1) PUT. (2) GET theo id. | 200; code/name mới được lưu. |
| TC-022 | PUT /api/profile/password; POST /api/auth/login | Đổi mật khẩu cá nhân. | Student local đã login. | `{ "currentPassword": "Karate123@", "newPassword": "Karate999@", "confirmPassword": "Karate999@" }`. | (1) PUT password. (2) Login bằng password mới. | PUT 200, message="Đổi mật khẩu thành công"; login 200 có accessToken. |
| TC-023 | GET /admin/classes/api | Lấy danh sách lớp. | Admin đã login. | Bearer `<adminToken>`. | (1) GET. | 200; JSON array; item có id, code, name, joinCode. |
| TC-024 | POST /admin/classes/api | Tạo lớp hợp lệ. | Admin; faculty và năm học tồn tại; code chưa tồn tại. | `{ "code": "KARATE-<suffix>", "name": "Lớp Karate <suffix>", "facultyId": <facultyId>, "academicYearId": <academicYearId> }` | (1) POST. (2) Lưu id và joinCode. | 200; có id; joinCode kiểu string. |
| TC-025 | POST /admin/classes/api/{id}/regenerate-code | Sinh lại mã join lớp. | TC-024 thành công. | path id=`<classId>`. | (1) Lưu joinCode cũ. (2) POST regenerate-code. | 200; joinCode mới khác joinCode cũ. |
| TC-026 | PUT /api/profile/password | Từ chối đổi mật khẩu khi sai mật khẩu hiện tại. | Student local đã login. | `{ "currentPassword": "WrongPass123", "newPassword": "Karate999@", "confirmPassword": "Karate999@" }`. | (1) PUT password. | 400; message="Mật khẩu hiện tại không đúng". |
| TC-027 | GET /admin/users/api?page=0&size=20 | Danh sách user phân trang. | Admin đã login. | Query page=0,size=20. | (1) GET. | 200; content array; totalElements number. |
| TC-028 | POST /admin/users/api | Tạo Student tự sinh mã 8 số. | Admin; class tồn tại; email chưa tồn tại. | `{ "email": "student-<suffix>@example.test", "fullName": "Karate Student", "password": "Karate123@", "role": "STUDENT", "classId": <classAId> }` | (1) POST. (2) Lưu id/username. | 200; id; username khớp `^[0-9]{8}$`; status=ACTIVE. |
| TC-029 | GET /admin/users/api/{id} | Xem chi tiết user vừa tạo. | TC-028 thành công. | path id=`<studentId>`. | (1) GET. | 200; id, email, role="STUDENT" khớp. |
| TC-030 | PUT /admin/users/api/{id} | Cập nhật user. | User từ TC-028 tồn tại. | `{ "email": "student-upd-<suffix>@example.test", "fullName": "Karate Student Updated", "phone": "0987654321", "role": "STUDENT", "classId": <classAId> }` | (1) PUT. (2) GET lại. | 200; email/fullName/phone mới được lưu. |
| TC-031 | POST /admin/users/api/{id}/toggle-status | Khóa user ACTIVE. | Student ACTIVE. | path id=`<studentId>`. | (1) POST toggle. (2) GET user. | POST 200; GET status="LOCKED". |
| TC-032 | POST /admin/users/api/{id}/toggle-status | Mở lại user LOCKED. | Student LOCKED từ TC-031. | path id=`<studentId>`. | (1) POST toggle. (2) GET user. | POST 200; GET status="ACTIVE". |
| TC-033 | POST /admin/users/api/{id}/reset-password; POST /api/auth/login | Reset mật khẩu bởi Admin. | Student ACTIVE tồn tại. | reset `{ "newPassword": "Karate456@" }`; login username+password mới. | (1) POST reset. (2) POST login. | Reset 200; login 200 có accessToken. |
| TC-034 | GET /admin/users/api | Chặn Student truy cập Admin API. | Student đã login. | Bearer `<studentToken>`. | (1) GET. | 403. |

| TC-035 | GET /admin/activities/api?page=0&size=20 | Danh sách hoạt động Admin. | Admin đã login. | Query page,size. | (1) GET. | 200; content array; totalElements number. |
| TC-036 | POST /admin/activities/api | Tạo activity hợp lệ. | Admin; học kỳ tồn tại. | `{ "name": "Karate Activity <suffix>", "description": "...", "location": "Campus", "startTime": <tương lai>, "endTime": <tương lai>, "registrationDeadline": <tương lai>, "scope": "SCHOOL", "status": "OPEN", "semesterId": <semesterId> }` | (1) POST. (2) Lưu activityId. | 200; có id, name; status="OPEN". |
| TC-037 | GET /admin/activities/api/{id} | Chi tiết activity. | TC-036 thành công. | path id=`<activityId>`. | (1) GET. | 200; id, name khớp. |
| TC-038 | PUT /admin/activities/api/{id} | Cập nhật activity. | TC-036 thành công. | Body ActivityDto hợp lệ, name="Karate Updated <suffix>". | (1) PUT. (2) GET lại. | 200; name mới được lưu. |
| TC-039 | POST /admin/activities/api | Validation tên activity rỗng. | Admin; học kỳ tồn tại. | Body ActivityDto hợp lệ nhưng `name:""`. | (1) POST. | 400; errors.name="Tên hoạt động không được để trống". |
| TC-040 | POST /admin/activities/api/{activityId}/slots | Tạo slot cho lớp. | Activity + class tồn tại. | `{ "classId": <classId>, "maxQuantity": 50 }` | (1) POST. | 200; slot có id, maxQuantity=50. |
| TC-041 | GET /admin/activities/api/{activityId}/slots | Xem slot của activity. | TC-040 thành công. | path activityId. | (1) GET. | 200; array chứa slot vừa tạo. |
| TC-042 | POST /manager/api/registrations/{registrationId}/checkin | Manager điểm danh thủ công. | Manager cùng lớp; registration ở trạng thái REGISTERED. | path registrationId. | (1) POST checkin. (2) GET registrations. | 200; message chứa "Đã điểm danh thành công"; status="ATTENDED". |
| TC-043 | GET /manager/api/activities/{activityId}/registrations?page=0&size=20 | Manager xem registrations thuộc lớp mình. | Manager cùng lớp activity; có ít nhất một đăng ký. | path activityId; query page,size. | (1) GET. | 200; content array; totalElements number; item có id, studentId, studentName, status. |
| TC-044 | POST /manager/api/registrations/{registrationId}/approve | Manager duyệt minh chứng và cộng điểm. | Registration ATTENDED, evidenceUrl khác null, isApproved=null; activity có scoreOption. | path registrationId. | (1) POST approve. (2) Gọi approve lần hai. | Lần 1: 200; isApproved=true; điểm cộng đúng 1 lần. Lần 2: 409, message="Minh chứng này đã được xử lý". |
| TC-045 | GET /student/api/activities | Danh sách activity cho Student. | Student có class, đã login. | Bearer `<studentToken>`. | (1) GET. | 200; hasClass=true; activities array; registeredActivityIds array. |
| TC-046 | POST /student/api/activities/{activityId}/register | Đăng ký activity hợp lệ. | Activity OPEN, còn hạn, còn slot; Student chưa đăng ký. | path activityId. | (1) POST. (2) GET /student/api/my-registrations. | POST 200; registration.status="REGISTERED". |
| TC-047 | POST /student/api/activities/{activityId}/register | Chặn đăng ký trùng. | Student đã REGISTERED activity. | path activityId. | (1) POST lần 2. | 409; message="Bạn đã đăng ký hoạt động này rồi". |
| TC-048 | DELETE /student/api/activities/{activityId}/register | Hủy đăng ký. | Student đã REGISTERED activity. | path activityId. | (1) DELETE. (2) GET my-registrations. | DELETE 200; status="CANCELLED". |
| TC-049 | GET /student/api/my-registrations | Xem đăng ký cá nhân. | Student đã login. | Bearer `<studentToken>`. | (1) GET. | 200; response.registrations array; item có activity, status. |
| TC-050 | POST /student/api/checkin/{activityId} | Chặn thiếu mã check-in. | Student đã REGISTERED; activity trong khung giờ. | Không truyền `token`. | (1) POST. | 400; message="Thiếu mã QR hoặc mã check-in". |
| TC-051 | POST /student/api/checkin/{activityId}?token=SAI123 | Chặn mã check-in sai/hết hạn. | Student đã REGISTERED. | query token sai. | (1) POST. | 400; message="Mã QR hoặc mã check-in không hợp lệ hoặc đã hết hạn". |

| TC-052 | POST /student/api/checkin/{activityId} | Check-in QR động thành công. | Student REGISTERED; activity OPEN trong khung giờ; Manager cùng lớp. | query classId, token=`<checkinCode>` từ GET `/manager/api/qrcode/dynamic/{activityId}`, lat/lng/accuracy hợp lệ. | (1) Manager lấy token. (2) Student POST checkin. (3) GET my-registrations. | 200; message="Check-in thành công! Cảm ơn bạn đã tham gia."; status="ATTENDED". |
| TC-053 | POST /student/api/checkin/{activityId} | Chặn check-in ngoài GPS. | Student REGISTERED; activity có lat/lng/checkinRadius; token hợp lệ. | lat/lng cách xa vị trí > checkinRadius. | (1) POST checkin. | 400; message="Bạn đang ở ngoài phạm vi check-in". |
| TC-054 | POST /student/api/activities/{activityId}/evidence?scoreOptionId={id} | Nộp minh chứng hợp lệ. | Student ATTENDED, chưa nộp; activity có score option. | multipart part `files`: 1 PNG/JPEG ≤5 MB; query scoreOptionId. | (1) POST multipart. (2) GET my-registrations. | 200; message chứa "Đã nộp 1 ảnh minh chứng"; evidenceUrl có giá trị; isApproved=null. |
| TC-055 | POST /student/api/activities/{activityId}/evidence?scoreOptionId={id} | Chặn quá 3 ảnh minh chứng. | Student ATTENDED, chưa nộp minh chứng. | multipart `files`: 4 PNG/JPEG hợp lệ; query scoreOptionId. | (1) POST multipart. | 400; message="Tối đa 3 ảnh"; evidenceUrl vẫn null. |

## Xác nhận phạm vi Mục 3.1.2

Bảng trên chỉ dùng endpoint đang có thật và phủ toàn bộ nhóm yêu cầu:

| Nhóm yêu cầu | TC phủ |
|---|---|
| Xác thực và quản lý phiên: `/api/auth/login`, `/api/auth/refresh`, `/api/auth/me`, `/api/auth/oauth2/exchange` | TC-001 → TC-014 |
| Quản lý tài khoản cá nhân: `/api/profile`, `/api/profile/password` | TC-018, TC-022, TC-026 |
| Danh mục Admin: academic years, semesters, faculties, classes | TC-009 → TC-017; TC-019 → TC-025 |
| Quản lý user: `/admin/users/api`, khóa/mở, reset password | TC-027 → TC-034 |
| Quản lý activity: `/admin/activities/api` | TC-035 → TC-041 |
| Manager: `/manager/api/activities/{activityId}/registrations`, `/manager/api/registrations/{id}/checkin` | TC-042 → TC-044 |
| Student: `/student/api/activities/{activityId}/register`, `/student/api/checkin/{activityId}` | TC-045 → TC-053 |
| Minh chứng: `/student/api/activities/{activityId}/evidence` | TC-054 → TC-055 |

**Xác nhận:** danh sách chỉ dùng endpoint có thật trong source hiện tại. Suite chuẩn tách theo nhóm nghiệp vụ: `auth.feature` (TC-001→008, TC-014), `profile.feature` (TC-018, TC-022, TC-026), `admin-catalog.feature` (TC-009→017, TC-019→025), `admin-users.feature` (TC-027→034), `activities.feature` (TC-035→041), `manager.feature` (TC-042→044), `student.feature` (TC-045→053), `evidence.feature` (TC-054→055). `ApiTest` chạy đúng một lần toàn bộ 8 feature này. Danh sách này là phạm vi API tiêu biểu đúng Mục 3.1.2.