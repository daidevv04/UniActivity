Feature: Đăng ký hoạt động và check-in (TC-31 đến TC-39)

  Background:
    * url baseUrl

  Scenario: TC-31 Danh sách hoạt động cho sinh viên
    Given path '/student/api/activities'
    * configure headers = { Authorization: '#("Bearer " + fixture.studentAToken)' }
    When method get
    Then status 200
    * match response.hasClass == true
    * match response.activities == '#array'
    * match response.registeredActivityIds == '#array'

  Scenario: TC-32 Đăng ký hoạt động hợp lệ
    * def student = call read('helpers/create-user.feature') { adminToken: '#(fixture.adminToken)', email: '#("karate-s32-" + test.suffix + "@example.test")', fullName: 'Karate Student 32', classId: '#(fixture.classAId)' }
    * def login = call read('helpers/login.feature') { username: '#(student.username)', password: '#(test.password)' }
    * def reg = call read('helpers/register.feature') { token: '#(login.accessToken)', activityId: '#(fixture.openActivityId)' }
    * match reg.message == 'Đăng ký thành công!'
    * def current = call read('helpers/my-registration.feature') { token: '#(login.accessToken)', activityId: '#(fixture.openActivityId)' }
    * match current.status == 'REGISTERED'

  Scenario: TC-33 Chặn đăng ký trùng
    * def student = call read('helpers/create-user.feature') { adminToken: '#(fixture.adminToken)', email: '#("karate-s33-" + test.suffix + "@example.test")', fullName: 'Karate Student 33', classId: '#(fixture.classAId)' }
    * def login = call read('helpers/login.feature') { username: '#(student.username)', password: '#(test.password)' }
    * call read('helpers/register.feature') { token: '#(login.accessToken)', activityId: '#(fixture.openActivityId)' }
    Given path '/student/api/activities', fixture.openActivityId, 'register'
    * configure headers = { Authorization: '#("Bearer " + login.accessToken)' }
    When method post
    Then status 409
    * match response.message == 'Bạn đã đăng ký hoạt động này rồi'

  Scenario: TC-34 Chặn đăng ký khi slot đầy
    * def now = java.time.LocalDateTime.now()
    * def activity = call read('helpers/create-activity.feature') { adminToken: '#(fixture.adminToken)', name: '#("Karate TC34 " + test.suffix)', start: '#(now.plusDays(5).withNano(0).toString())', end: '#(now.plusDays(5).plusHours(2).withNano(0).toString())', deadline: '#(now.plusDays(4).withNano(0).toString())', status: 'OPEN', semesterId: '#(fixture.semesterId)' }
    * call read('helpers/create-slot.feature') { adminToken: '#(fixture.adminToken)', activityId: '#(activity.id)', classId: '#(fixture.classAId)', maxQuantity: 1 }
    * def holder = call read('helpers/create-user.feature') { adminToken: '#(fixture.adminToken)', email: '#("karate-s34-holder-" + test.suffix + "@example.test")', fullName: 'Karate Holder 34', classId: '#(fixture.classAId)' }
    * def holderLogin = call read('helpers/login.feature') { username: '#(holder.username)', password: '#(test.password)' }
    * call read('helpers/register.feature') { token: '#(holderLogin.accessToken)', activityId: '#(activity.id)' }
    * def late = call read('helpers/create-user.feature') { adminToken: '#(fixture.adminToken)', email: '#("karate-s34-late-" + test.suffix + "@example.test")', fullName: 'Karate Late 34', classId: '#(fixture.classAId)' }
    * def lateLogin = call read('helpers/login.feature') { username: '#(late.username)', password: '#(test.password)' }
    Given path '/student/api/activities', activity.id, 'register'
    * configure headers = { Authorization: '#("Bearer " + lateLogin.accessToken)' }
    When method post
    Then status 409
    * match response.message == 'Slot đã đầy, không thể đăng ký'

  Scenario: TC-35 Hủy đăng ký và chặn hủy lần hai
    * def student = call read('helpers/create-user.feature') { adminToken: '#(fixture.adminToken)', email: '#("karate-s35-" + test.suffix + "@example.test")', fullName: 'Karate Student 35', classId: '#(fixture.classAId)' }
    * def login = call read('helpers/login.feature') { username: '#(student.username)', password: '#(test.password)' }
    * call read('helpers/register.feature') { token: '#(login.accessToken)', activityId: '#(fixture.openActivityId)' }
    Given path '/student/api/activities', fixture.openActivityId, 'register'
    * configure headers = { Authorization: '#("Bearer " + login.accessToken)' }
    When method delete
    Then status 200
    * match response.message == 'Đã hủy đăng ký thành công'
    * def current = call read('helpers/my-registration.feature') { token: '#(login.accessToken)', activityId: '#(fixture.openActivityId)' }
    * match current.status == 'CANCELLED'
    Given path '/student/api/activities', fixture.openActivityId, 'register'
    When method delete
    Then status 409
    * match response.message == 'Không thể hủy đăng ký ở trạng thái hiện tại'

  Scenario: TC-36 Chặn check-in thiếu mã
    * def student = call read('helpers/create-user.feature') { adminToken: '#(fixture.adminToken)', email: '#("karate-s36-" + test.suffix + "@example.test")', fullName: 'Karate Student 36', classId: '#(fixture.classAId)' }
    * def login = call read('helpers/login.feature') { username: '#(student.username)', password: '#(test.password)' }
    * call read('helpers/register.feature') { token: '#(login.accessToken)', activityId: '#(fixture.liveActivityId)' }
    Given path '/student/api/checkin', fixture.liveActivityId
    * configure headers = { Authorization: '#("Bearer " + login.accessToken)' }
    When method post
    Then status 400
    * match response.message == 'Thiếu mã QR hoặc mã check-in'

  Scenario: TC-37 Chặn check-in với mã sai
    * def student = call read('helpers/create-user.feature') { adminToken: '#(fixture.adminToken)', email: '#("karate-s37-" + test.suffix + "@example.test")', fullName: 'Karate Student 37', classId: '#(fixture.classAId)' }
    * def login = call read('helpers/login.feature') { username: '#(student.username)', password: '#(test.password)' }
    * call read('helpers/register.feature') { token: '#(login.accessToken)', activityId: '#(fixture.liveActivityId)' }
    Given path '/student/api/checkin', fixture.liveActivityId
    * configure headers = { Authorization: '#("Bearer " + login.accessToken)' }
    And param token = 'SAI123'
    When method post
    Then status 400
    * match response.message == 'Mã QR hoặc mã check-in không hợp lệ hoặc đã hết hạn'

  Scenario: TC-38 Check-in bằng QR động và chặn check-in lặp
    * def student = call read('helpers/create-user.feature') { adminToken: '#(fixture.adminToken)', email: '#("karate-s38-" + test.suffix + "@example.test")', fullName: 'Karate Student 38', classId: '#(fixture.classAId)' }
    * def login = call read('helpers/login.feature') { username: '#(student.username)', password: '#(test.password)' }
    * call read('helpers/register.feature') { token: '#(login.accessToken)', activityId: '#(fixture.liveActivityId)' }
    * def qr = call read('helpers/dynamic-qr.feature') { managerToken: '#(fixture.managerAToken)', activityId: '#(fixture.liveActivityId)' }
    Given path '/student/api/checkin', fixture.liveActivityId
    * configure headers = { Authorization: '#("Bearer " + login.accessToken)' }
    And param classId = fixture.classAId
    And param token = qr.token
    And param lat = 10.762622
    And param lng = 106.660172
    And param accuracy = 5
    When method post
    Then status 200
    * match response.message == 'Check-in thành công! Cảm ơn bạn đã tham gia.'
    * def current = call read('helpers/my-registration.feature') { token: '#(login.accessToken)', activityId: '#(fixture.liveActivityId)' }
    * match current.status == 'ATTENDED'
    Given path '/student/api/checkin', fixture.liveActivityId
    And param classId = fixture.classAId
    And param token = qr.token
    And param lat = 10.762622
    And param lng = 106.660172
    And param accuracy = 5
    When method post
    Then status 400
    * match response.message == 'Đăng ký không ở trạng thái có thể check-in'

  Scenario: TC-39 Chặn check-in ngoài phạm vi GPS
    * def student = call read('helpers/create-user.feature') { adminToken: '#(fixture.adminToken)', email: '#("karate-s39-" + test.suffix + "@example.test")', fullName: 'Karate Student 39', classId: '#(fixture.classAId)' }
    * def login = call read('helpers/login.feature') { username: '#(student.username)', password: '#(test.password)' }
    * call read('helpers/register.feature') { token: '#(login.accessToken)', activityId: '#(fixture.liveActivityId)' }
    * def qr = call read('helpers/dynamic-qr.feature') { managerToken: '#(fixture.managerAToken)', activityId: '#(fixture.liveActivityId)' }
    Given path '/student/api/checkin', fixture.liveActivityId
    * configure headers = { Authorization: '#("Bearer " + login.accessToken)' }
    And param classId = fixture.classAId
    And param token = qr.token
    And param lat = 0
    And param lng = 0
    And param accuracy = 5
    When method post
    Then status 400
    * match response.message == 'Bạn đang ở ngoài phạm vi check-in'

