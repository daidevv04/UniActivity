# 3.5. Đánh giá hiệu quả sử dụng Karate Framework

## 3.5.1. Tính ưu việt của Karate so với các Framework khác

Trong hệ thống UniActivity, Karate Framework được sử dụng để kiểm thử API tự động trên nền tảng Spring Boot, Java 21 và MySQL. Để đánh giá đặc điểm của Karate, đề tài đối chiếu công cụ này với REST-Assured và Postman. REST-Assured đại diện cho cách tiếp cận kiểm thử dựa trên mã nguồn Java; Postman đại diện cho cách tổ chức request bằng Collection và script JavaScript. Karate sử dụng DSL dựa trên Gherkin, kết hợp mô tả nghiệp vụ, thực thi HTTP và kiểm tra phản hồi trong Feature File.

REST-Assured được sử dụng trong bảng so sánh về đặc trưng kỹ thuật. Postman được sử dụng trong phần thực nghiệm đối chứng thông qua Postman Collection tương đương. Collection này được Newman 6.2.1 thực thi bằng dòng lệnh để tự động hóa việc chạy và đo thời gian; do đó môi trường chạy Postman tự động yêu cầu Node.js.

### Bảng 3.10. So sánh Karate, REST-Assured và Postman

| Tiêu chí so sánh | Karate Framework | REST-Assured | Postman |
|---|---|---|---|
| **Cách tiếp cận kiểm thử** | Dựa trên BDD DSL; kịch bản nghiệp vụ được mô tả bằng Feature File. | Dựa trên mã nguồn; kịch bản được xây dựng bằng Java. | Dựa trên Collection và script; request được tổ chức trong Postman Collection. |
| **Ngôn ngữ và cú pháp** | Gherkin DSL: `Feature`, `Scenario`, `Given`, `When`, `Then`, `match`, `call`. | Java Fluent API kết hợp JUnit hoặc TestNG. | Giao diện Postman để xây dựng request; Collection lưu dưới dạng JSON; script sử dụng JavaScript. |
| **Xử lý JSON và assertion** | JSON là kiểu dữ liệu gốc; `match` hỗ trợ kiểm tra giá trị, object, array, schema con và fuzzy matcher. | Hỗ trợ JSONPath và Java matcher, thường kết hợp Hamcrest. | Dùng `pm.response.json()`, `pm.test()` và `pm.expect()` để kiểm tra phản hồi. |
| **Ví dụ assertion kiểu dữ liệu** | `match response.accessToken == '#string'` | `body("accessToken", instanceOf(String.class))` | `pm.expect(json.accessToken).to.be.a('string')` |
| **Liên kết API** | Gán trực tiếp: `* def activityId = response.id`; biến được dùng trong request sau. | Lưu vào biến Java, object hoặc utility class. | Lưu bằng `pm.collectionVariables.set('activityId', json.id)`. |
| **Tái sử dụng** | `call read(...)` gọi lại Feature helper. UniActivity có helper đăng nhập, tạo Student, tạo activity, chuẩn bị đăng ký, QR động và upload evidence. | Tái sử dụng qua method Java, base class, fixture hoặc utility class. | Tái sử dụng qua Collection, Folder, Environment, Collection Variable và script chung. |
| **Thực thi song song** | Hỗ trợ chạy song song Feature, Scenario và Example row ở mức framework. | Cần cấu hình JUnit/TestNG cùng Maven hoặc Gradle; cần kiểm soát shared state. | Request trong một Collection được thực thi tuần tự; chạy nhiều Collection song song cần cơ chế điều phối bên ngoài. |
| **Báo cáo** | Tự sinh Karate HTML Report; dự án có `target/karate-reports/karate-summary.html`. | JUnit/TestNG có báo cáo cơ bản; báo cáo trực quan thường tích hợp Allure hoặc ExtentReports. | Postman hiển thị kết quả trong giao diện; Newman có thể xuất CLI, JSON và JUnit, trong khi báo cáo HTML cần reporter phù hợp. |
| **Hệ sinh thái** | Hỗ trợ API test, UI automation, mock/test double, data-driven test và performance test qua Gatling. | Tập trung vào API test; UI, mock và hiệu năng thường kết hợp các công cụ khác. | Phù hợp thiết kế, kiểm thử và chia sẻ API Collection; có Postman Mock Server. |
| **Phù hợp với UniActivity** | Đã tích hợp Maven/Java 21 qua `karate-junit5` 1.4.1. | Phù hợp khi kịch bản cần logic Java; dự án hiện chưa sử dụng dependency REST-Assured. | Đã có Collection đối chứng; khi chạy tự động bằng Newman cần môi trường Node.js. |

## 3.5.2. Các ưu điểm cốt lõi của Karate

### 1. Cú pháp BDD tối ưu, không đòi hỏi mã Java phức tạp

REST-Assured yêu cầu xây dựng kịch bản bằng Java, bao gồm class kiểm thử, method kiểm thử, request specification, biến lưu phản hồi và matcher assertion. Cách tiếp cận này phù hợp với các trường hợp cần xử lý logic Java chuyên biệt, nhưng phần mô tả luồng nghiệp vụ thường phân tán qua nhiều thành phần mã nguồn.

Karate sử dụng DSL dựa trên Gherkin. Endpoint, HTTP method, request body, assertion và dữ liệu phản hồi được đặt trong cùng một Scenario. Ví dụ từ benchmark UniActivity cho thấy thao tác đăng nhập Admin, kiểm tra token và lưu token được biểu diễn trong cùng một đoạn Feature File:

```gherkin
Given path '/api/auth/login'
And request { username: '#(admin.username)', password: '#(admin.password)' }
When method post
Then status 200
And match response.accessToken == '#string'
* def adminToken = response.accessToken
```

Kịch bản Karate của luồng “Tạo và đăng ký hoạt động” có 42 dòng vật lý, trong đó có 35 dòng không rỗng hoặc comment, và thực hiện 5 request. Postman Collection tương ứng có 149 dòng JSON, trong đó có 26 dòng JavaScript cho pre-request script và test script. Khác biệt về định dạng lưu trữ khiến hai số liệu không hoàn toàn tương đương, tuy nhiên Feature File Karate tập trung phần mô tả nghiệp vụ và logic kiểm thử trong một cấu trúc thống nhất.

### 2. Cơ chế JSON Matching vượt trội

Karate cung cấp `match` như cơ chế kiểm tra JSON tích hợp trong DSL. Với phản hồi tạo activity có nhiều trường dữ liệu, đề tài chỉ kiểm tra các thuộc tính cần thiết cho bước tiếp theo như sau:

```gherkin
And match response contains { id: '#number', name: '#string' }
* def activityId = response.id
```

Trong Postman, kiểm tra tương ứng được thực hiện bằng JavaScript:

```javascript
const json = pm.response.json();
pm.test('id is a number and name is a string', () => {
  pm.expect(json.id).to.be.a('number');
  pm.expect(json.name).to.be.a('string');
});
pm.collectionVariables.set('activityId', json.id);
```

`contains` cho phép kiểm tra object con mà không yêu cầu phản hồi phải có đúng toàn bộ trường đã khai báo. Điều này phù hợp với API tạo activity của UniActivity vì phản hồi còn có các trường như `description`, `location`, `startTime`, `endTime`, `status`, `semesterId` và `createdAt`.

Karate hỗ trợ các fuzzy matcher phục vụ việc kiểm tra dữ liệu động:

| Matcher | Ý nghĩa | Ví dụ áp dụng trong UniActivity |
|---|---|---|
| `#string` | Giá trị là chuỗi | `response.accessToken`, `response.message` |
| `#number` | Giá trị là số | `response.id`, `response.semesterId` |
| `#boolean` | Giá trị Boolean | Các cờ trạng thái trong phản hồi API |
| `#array` | Giá trị là mảng | Danh sách activity hoặc registration |
| `#notnull` | Giá trị không null | Timestamp hoặc ID bắt buộc |
| `#regex` | Giá trị khớp biểu thức chính quy | Username hoặc mã số sinh viên |
| `#ignore` | Không kiểm tra trường biến động | Timestamp hoặc dữ liệu được sinh tự động |

Suite chính Karate hiện có 55 Scenario. Phần lớn assertion trong suite này đang dừng ở `Then status ...` và `print response`; các assertion `match` trong benchmark thể hiện hướng áp dụng để mở rộng mức độ kiểm tra cấu trúc phản hồi trong các kịch bản tiếp theo.

### 3. Hỗ trợ thực thi song song

Karate hỗ trợ thực thi song song Feature, Scenario và các dòng dữ liệu của Scenario Outline. Với các kịch bản độc lập dữ liệu, runner có thể sử dụng Java API `Runner.path(...).parallel(n)` để phân bổ công việc cho nhiều worker.

Luồng benchmark “Tạo và đăng ký hoạt động” được thực hiện tuần tự vì các request có quan hệ phụ thuộc dữ liệu. Request tạo activity sử dụng `adminToken` từ đăng nhập Admin; request tạo slot sử dụng `activityId` từ phản hồi tạo activity; request đăng ký sử dụng `studentToken`, `activityId` và slot đã tạo. Việc thực thi tuần tự bảo đảm tính nhất quán của chuỗi nghiệp vụ giữa Karate và Postman.

Runner `ApiTest.java` của suite chính hiện chưa sử dụng `parallel(...)`, và log thực thi ghi nhận `threads: 1`. Khả năng thực thi song song của Karate là cơ sở để mở rộng khi các Scenario được thiết kế độc lập dữ liệu. Việc áp dụng cần bảo đảm cô lập email, username, mã danh mục, activity và registration nhằm hạn chế xung đột dữ liệu trên MySQL.

### 4. Mô hình All-in-One

Karate cung cấp hệ sinh thái bao gồm API testing, UI automation, mock/test double, data-driven test và performance testing qua Gatling. Mô hình này tạo điều kiện duy trì cách tổ chức Feature và Scenario nhất quán khi phạm vi kiểm thử được mở rộng.

Đối với UniActivity, các khả năng này có thể được sử dụng để phát triển mock service cho API phụ thuộc, mở rộng kiểm thử giao diện, hoặc tái sử dụng luồng API cho đánh giá tải. Trong phạm vi hiện tại, đề tài thực hiện kiểm thử API bằng Karate; mock server, UI test và Gatling được xem là các hướng mở rộng của framework.

## 3.5.3. Thực nghiệm đối chứng Karate và Postman

### a. Thiết kế thực nghiệm

Thực nghiệm sử dụng luồng nghiệp vụ “Tạo và đăng ký hoạt động”. Luồng gồm 5 HTTP request thực tế. Sau khi Admin và Student đăng nhập để nhận token, Admin tạo activity và tạo slot cho lớp của Student; cuối cùng Student thực hiện đăng ký activity. Request tạo slot được đưa vào luồng do điều kiện nghiệp vụ yêu cầu Student chỉ có thể đăng ký khi activity đã có slot phù hợp với lớp.

| STT | Vai trò | Endpoint | Dữ liệu dùng cho bước sau |
|---:|---|---|---|
| 1 | Admin | `POST /api/auth/login` | `adminToken` |
| 2 | Student | `POST /api/auth/login` | `studentToken` |
| 3 | Admin | `POST /admin/activities/api` | `activityId` |
| 4 | Admin | `POST /admin/activities/api/{activityId}/slots` | Mở slot cho `classId` của Student |
| 5 | Student | `POST /student/api/activities/{activityId}/register` | Xác nhận đăng ký |

Token được lấy trực tiếp từ phản hồi của hai request đăng nhập, do đó không hình thành request độc lập cho thao tác lấy token. `semesterId`, `classId` và Student được tạo trước bởi `helpers/setup.feature`; thời gian tạo fixture không thuộc thời gian thực thi Scenario gồm 5 request.

Kịch bản Karate được lưu tại:

```text
D:\PROJECT\UniActivity\UniActivity_BE\src\test\java\com\example\uniactivity\karate\benchmark-create-and-register.feature
```

Postman Collection tương đương được lưu tại:

```text
D:\PROJECT\UniActivity\docs\benchmark\UniActivity-Create-And-Register.postman_collection.json
```

Collection Postman được thực thi tự động bằng Newman 6.2.1 trên backend Spring Boot tại `http://127.0.0.1:8080`. Newman là công cụ dòng lệnh dùng để chạy Postman Collection và thu thập thời gian thực thi, do đó yêu cầu môi trường Node.js. Mỗi lượt chạy tạo activity mới bằng `runSuffix` để tránh trùng tên dữ liệu.

### b. Mã Postman dùng trong thực nghiệm

Pre-request script tạo thời gian activity và hậu tố dữ liệu động:

```javascript
if (!pm.collectionVariables.get('runSuffix')) {
  const now = Date.now();
  const localIso = (offsetMs) => new Date(now + offsetMs).toISOString().slice(0, 19);
  pm.collectionVariables.set('runSuffix', String(now));
  pm.collectionVariables.set('startTime', localIso(5 * 24 * 60 * 60 * 1000));
  pm.collectionVariables.set('endTime', localIso((5 * 24 + 2) * 60 * 60 * 1000));
  pm.collectionVariables.set('registrationDeadline', localIso(4 * 24 * 60 * 60 * 1000));
}
```

Test script đăng nhập lưu access token:

```javascript
pm.test('HTTP 200', () => pm.response.to.have.status(200));
const json = pm.response.json();
pm.test('accessToken is a string', () =>
  pm.expect(json.accessToken).to.be.a('string').and.not.empty
);
pm.collectionVariables.set('adminToken', json.accessToken);
```

Test script tạo activity kiểm tra JSON và truyền `activityId`:

```javascript
pm.test('HTTP 200', () => pm.response.to.have.status(200));
const json = pm.response.json();
pm.test('id is a number and name is a string', () => {
  pm.expect(json.id).to.be.a('number');
  pm.expect(json.name).to.be.a('string');
});
pm.collectionVariables.set('activityId', json.id);
```

### Bảng 3.11. Kết quả thực nghiệm luồng “Tạo và đăng ký hoạt động”

| Tiêu chí đo lường | Karate Framework | Postman | Nhận xét từ thực nghiệm |
|---|---:|---:|---|
| Số API / request | 5 | 5 | Cùng endpoint, request body, vai trò và chuỗi dữ liệu. |
| Kết quả chạy | 5/5 lượt pass | 5/5 lượt pass; 25/25 request pass; 50/50 assertion pass | Cả hai công cụ thực thi thành công luồng nghiệp vụ của UniActivity. |
| Số dòng mô tả | 42 dòng Feature; 35 dòng không rỗng/comment | 149 dòng JSON; 26 dòng JavaScript | Feature File và Collection JSON có cách tổ chức khác nhau; Karate tập trung mô tả nghiệp vụ và assertion trong Scenario. |
| Lưu token | `* def adminToken = response.accessToken` | `pm.collectionVariables.set('adminToken', json.accessToken)` | Karate sử dụng biến trực tiếp từ phản hồi; Postman lưu biến Collection qua JavaScript. |
| Kiểm tra activity | `match response contains { id: '#number', name: '#string' }` | `pm.expect(...)` trong `pm.test(...)` | Cả hai kiểm tra kiểu dữ liệu của `id` và `name`; Karate biểu diễn điều kiện bằng DSL. |
| Thời gian luồng 5 request | **235,903 ms** trung bình 5 lượt; min 219,235 ms; max 250,803 ms | **688 ms** trung bình 5 lượt; min 674 ms; max 703 ms | Hai công cụ đều được đo 5 lượt trên cùng luồng nghiệp vụ gồm 5 request. |
| Cách chạy | Maven + `karate-junit5` | Postman; Newman 6.2.1 chạy tự động qua Node.js | Karate sử dụng stack Maven/Java của dự án; Postman chạy tự động qua Newman yêu cầu Node.js. |
| Báo cáo | Karate HTML Report tự sinh | Kết quả trong Postman; Newman xuất JSON | Karate có báo cáo HTML trong quy trình Maven hiện tại; báo cáo HTML từ Newman cần reporter phù hợp. |

Thời gian Karate được trích từ `durationMillis` của Scenario trong Karate JSON Report và chỉ tính luồng 5 request. Thời gian thực thi Maven Surefire của `BenchmarkRunner` bao gồm quá trình khởi tạo framework và `karate.callSingle()` thực hiện `setup.feature`, nên không được sử dụng làm thời gian của luồng nghiệp vụ. Thời gian Postman được Newman xác định bằng `run.timings.completed - run.timings.started` trên từng lượt Collection và chỉ bao gồm 5 request của Collection.

### Bảng 3.12. Thời gian thực thi Karate và Postman

| Lượt | Karate Framework | Postman qua Newman |
|---:|---:|---:|
| 1 | 250,803 ms | 674 ms |
| 2 | 230,755 ms | 701 ms |
| 3 | 219,235 ms | 683 ms |
| 4 | 242,757 ms | 703 ms |
| 5 | 235,965 ms | 679 ms |
| **Trung bình** | **235,903 ms** | **688 ms** |
| **Nhỏ nhất** | **219,235 ms** | **674 ms** |
| **Lớn nhất** | **250,803 ms** | **703 ms** |

Kết quả thực nghiệm xác nhận cả Karate và Postman đều thực hiện được luồng nghiệp vụ đã chọn trong 5/5 lượt chạy. Trong môi trường đo của đề tài, thời gian Scenario trung bình của Karate là `235,903 ms`, còn thời gian trung bình của Postman chạy qua Newman là `688 ms`. Kết quả này phản ánh luồng, cấu hình backend và môi trường đo hiện tại; việc khái quát hiệu năng cho các hệ thống hoặc cấu hình khác cần thực hiện thêm các phép đo mở rộng.

Thời gian xây dựng kịch bản (*Test Authoring Time*) chưa được ghi nhận trong quá trình phát triển nên không được đưa vào so sánh.

## 3.5.4. Kết luận

Kết quả đánh giá cho thấy Karate phù hợp với kiểm thử API tự động trong UniActivity nhờ khả năng mô tả luồng nghiệp vụ bằng Gherkin, xử lý JSON trực tiếp, liên kết dữ liệu giữa các request và tích hợp với Maven/Java 21 thông qua `karate-junit5` 1.4.1. Thực nghiệm luồng “Tạo và đăng ký hoạt động” xác nhận Karate và Postman đều thực thi thành công các request nghiệp vụ; Karate có báo cáo HTML tự sinh, còn Postman có thể được tự động hóa bằng Newman trong môi trường Node.js. Khả năng chạy song song, mock, UI test và performance test tạo cơ sở mở rộng phạm vi kiểm thử khi dự án có nhu cầu tương ứng. Từ các kết quả trên, Karate là giải pháp cân bằng giữa tính đơn giản của Postman và sức mạnh lập trình của REST-Assured.