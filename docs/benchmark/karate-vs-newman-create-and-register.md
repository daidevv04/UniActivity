# Thực nghiệm đối chứng Karate và Postman/Newman

## 1. Luồng nghiệp vụ và phạm vi đo

Luồng đề xuất “Đăng nhập → Lấy token → Tạo hoạt động → Đăng ký tham gia” cần hai vai trò. Admin tạo activity; Student mới có quyền đăng ký. Activity cũng phải có slot gán cho lớp Student, nếu không API đăng ký không đủ điều kiện nghiệp vụ.

Vì vậy luồng đo có **5 HTTP request**:

| STT | Vai trò | Request | Dữ liệu nhận hoặc dùng ở bước sau |
|---:|---|---|---|
| 1 | Admin | `POST /api/auth/login` | `adminToken` |
| 2 | Student | `POST /api/auth/login` | `studentToken` |
| 3 | Admin | `POST /admin/activities/api` | `activityId` |
| 4 | Admin | `POST /admin/activities/api/{activityId}/slots` | Mở chỉ tiêu cho `classId` của Student |
| 5 | Student | `POST /student/api/activities/{activityId}/register` | Xác nhận đăng ký |

“Lấy token” là dữ liệu trả về của hai request đăng nhập, không phải endpoint riêng. `semesterId`, `classId` và Student là fixture trước đo. Không đưa thời gian tạo fixture vào kết quả của luồng 5 request.

Mã Karate: `D:\PROJECT\UniActivity\UniActivity_BE\src\test\java\com\example\uniactivity\karate\benchmark-create-and-register.feature`.

Mã Postman: `D:\PROJECT\UniActivity\docs\benchmark\UniActivity-Create-And-Register.postman_collection.json`.

## 2. Mã Karate dùng để đối chứng

```gherkin
Scenario: Đăng nhập Admin, đăng nhập Student, tạo activity, tạo slot, đăng ký
  * def now = java.time.LocalDateTime.now()

  Given path '/api/auth/login'
  And request { username: '#(admin.username)', password: '#(admin.password)' }
  When method post
  Then status 200
  And match response.accessToken == '#string'
  * def adminToken = response.accessToken

  Given path '/api/auth/login'
  And request { username: '#(fixture.studentA.username)', password: '#(config.test.password)' }
  When method post
  Then status 200
  And match response.accessToken == '#string'
  * def studentToken = response.accessToken

  Given path '/admin/activities/api'
  And header Authorization = 'Bearer ' + adminToken
  And request { name: '#("Benchmark " + config.test.suffix)', description: 'Benchmark Karate va Newman', location: 'Campus', startTime: '#(now.plusDays(5).withNano(0).toString())', endTime: '#(now.plusDays(5).plusHours(2).withNano(0).toString())', registrationDeadline: '#(now.plusDays(4).withNano(0).toString())', scope: 'SCHOOL', status: 'OPEN', semesterId: '#(fixture.semesterId)' }
  When method post
  Then status 200
  And match response contains { id: '#number', name: '#string' }
  * def activityId = response.id

  Given path '/admin/activities/api', activityId, 'slots'
  And header Authorization = 'Bearer ' + adminToken
  And request { classId: '#(fixture.classAId)', maxQuantity: 50 }
  When method post
  Then status 200
  And match response.id == '#number'

  Given path '/student/api/activities', activityId, 'register'
  And header Authorization = 'Bearer ' + studentToken
  When method post
  Then status 200
  And match response.message == '#string'
```

Karate dùng `match` để xác nhận token, ID, kiểu dữ liệu và response. Collection Postman dùng JavaScript `pm.expect(...)` để kiểm tra cùng các điều kiện đó.

## 3. Chạy đối chứng

### 3.1 Chuẩn bị fixture chung

1. Khởi động backend tại `http://127.0.0.1:8080` với MySQL và dữ liệu test.
2. Chạy một lần suite Karate để tạo fixture động:

```powershell
Set-Location 'D:\PROJECT\UniActivity\UniActivity_BE'
.\mvnw test
```

3. Trong log `setup.feature`, ghi lại ba dữ liệu vừa tạo: username Student A, `classAId`, `semesterId`. Không đưa access token hoặc password vào ảnh chụp báo cáo/Git.
4. Điền các giá trị này vào Environment Postman. Password lấy từ cấu hình local, không commit environment đã điền secret.

### 3.2 Chạy Karate benchmark

`ApiTest.java` cố ý không gọi benchmark này. `BenchmarkRunner.java` không khớp tên test mặc định của Surefire, nên `mvn test` vẫn giữ suite 55 Scenario. Chạy riêng benchmark:

```powershell
Set-Location 'D:\PROJECT\UniActivity\UniActivity_BE'
.\mvnw -Dtest=BenchmarkRunner test
```

Không thay đổi `ApiTest.java` hoặc kết quả báo cáo chính 55 Scenario.

### 3.3 Chạy Postman/Newman

Import hai file dưới đây vào Postman rồi chọn Environment `UniActivity Benchmark local`:

- `D:\PROJECT\UniActivity\docs\benchmark\UniActivity-Create-And-Register.postman_collection.json`
- `D:\PROJECT\UniActivity\docs\benchmark\UniActivity-Benchmark.postman_environment.json`

Cài Newman nếu chưa có:

```powershell
npm install --global newman
```

Chạy và xuất kết quả JSON/JUnit:

```powershell
Set-Location 'D:\PROJECT\UniActivity'
newman run '.\docs\benchmark\UniActivity-Create-And-Register.postman_collection.json' `
  -e '.\docs\benchmark\UniActivity-Benchmark.postman_environment.json' `
  -r cli,json,junit `
  --reporter-json-export '.\docs\benchmark\newman-result.json' `
  --reporter-junit-export '.\docs\benchmark\newman-result.xml'
```

Chạy mỗi công cụ 5 lần sau một lần warm-up. Ghi thời gian `run duration` của mỗi lần, lấy trung bình. Không chạy song song luồng này: năm request phụ thuộc token và `activityId` từ request trước.

## 4. Bảng kết quả thực nghiệm

### 4.1 Số liệu đã xác nhận từ mã nguồn và báo cáo

| Tiêu chí | Karate Framework | Postman / Newman | Nhận xét |
|---|---:|---:|---|
| Request nghiệp vụ đo | 5 | 5 | Hai bên dùng đúng endpoint, body và assertion tương đương. |
| Vai trò cần dùng | ADMIN và STUDENT | ADMIN và STUDENT | Đúng rule phân quyền của UniActivity. |
| Dữ liệu chuỗi | `adminToken`, `studentToken`, `activityId` | Collection variables cùng tên | Karate gán biến trực tiếp; Postman cần `pm.collectionVariables.set(...)`. |
| Kiểm tra token | `match response.accessToken == '#string'` | `pm.expect(json.accessToken).to.be.a('string')` | Karate ngắn hơn, không cần JavaScript test block. |
| Kiểm tra activity | `match response contains { id: '#number', name: '#string' }` | `pm.expect(json.id)...; pm.expect(json.name)...` | `match` kiểm tra object response trong một assertion mà không buộc response chỉ có hai field. |
| Điều kiện tạo slot | Có `POST /admin/activities/api/{activityId}/slots` | Có cùng request | Bắt buộc để Student đăng ký activity thuộc lớp. |
| Dependency chạy CLI | Java 21, Maven, `karate-junit5` 1.4.1 | Node.js và Newman | Máy hiện tại có Node.js `v24.21.0`, chưa có lệnh `newman`. |
| Báo cáo | Karate HTML tự sinh | `cli,json,junit`; HTML cần reporter riêng | Karate Report hiện có tại `UniActivity_BE/target/karate-reports/karate-summary.html`. |

### 4.2 Kết quả thời gian — chỉ điền sau khi chạy

| Tiêu chí đo lường | Karate Framework | Postman / Newman | Nhận xét |
|---|---:|---:|---|
| Lần warm-up | Chưa đo riêng | Chưa đo: Newman chưa cài, backend chưa chạy | Không dùng số liệu 14,78 giây của suite 55 Scenario. |
| Trung bình 5 lần chạy tuần tự | Chưa đo riêng | Chưa đo | Đo trên cùng máy, DB, dữ liệu fixture và backend. |
| Min / max 5 lần | Chưa đo riêng | Chưa đo | Ghi từ Karate Report/log và Newman CLI/JSON report. |
| Tỷ lệ pass | Chưa đo riêng | Chưa đo | Chỉ so sánh khi cả hai chạy với dữ liệu cùng điều kiện. |

**Không ghi số 1,2 giây, 3,8 giây, 50–60% hoặc thời gian viết kịch bản khi chưa có log đo.** Báo cáo Surefire hiện chỉ xác nhận toàn suite: `55` tests, `0` failures, `0` errors, `0` skipped, `14.78 s`; không phải benchmark 5 request.

## 5. Nhận xét dùng trong báo cáo

Đối chứng được thiết kế theo cùng một luồng nghiệp vụ có phân quyền và API chaining thật của UniActivity. Karate giữ request, biến và assertion trong Feature File Gherkin. Postman/Newman cần Collection JSON, collection variable và JavaScript `pm.test` để lưu token, activity ID và kiểm tra response. Karate vì vậy có ưu thế rõ về tính đọc được và lượng cú pháp phụ trợ trong luồng đa API. Kết luận về chênh lệch thời gian chỉ được đưa ra sau khi Newman đã cài, backend đang chạy và hai công cụ được đo lặp trên cùng điều kiện.