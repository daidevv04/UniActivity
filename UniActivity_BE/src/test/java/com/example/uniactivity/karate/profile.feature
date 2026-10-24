Feature: Hồ sơ cá nhân (TC-07 đến TC-09)

  Background:
    * url baseUrl

  Scenario: TC-07 Xem hồ sơ cá nhân
    Given path '/api/profile'
    * configure headers = { Authorization: '#("Bearer " + fixture.studentAToken)' }
    When method get
    Then status 200
    * match response.id == fixture.studentA.id
    * match response.username == fixture.studentA.username
    * match response.email == fixture.studentA.email
    * match response.role == 'STUDENT'
    * match response.status == 'ACTIVE'
    * match response.fullName == '#string'

  Scenario: TC-08 Cập nhật họ tên và số điện thoại
    Given path '/api/profile'
    * configure headers = { Authorization: '#("Bearer " + fixture.studentAToken)' }
    And request { fullName: 'Karate Student Updated', phone: '0987654321' }
    When method put
    Then status 200
    * match response.message == 'Cập nhật thông tin thành công'
    Given path '/api/profile'
    When method get
    Then status 200
    * match response.fullName == 'Karate Student Updated'
    * match response.phone == '0987654321'

  Scenario: TC-09 Đổi mật khẩu và vô hiệu token cũ
    * def student = call read('helpers/create-user.feature') { adminToken: '#(fixture.adminToken)', email: '#("karate-tc09-" + test.suffix + "@example.test")', fullName: 'Karate TC09', classId: '#(fixture.classAId)' }
    * def login = call read('helpers/login.feature') { username: '#(student.username)', password: '#(test.password)' }
    Given path '/api/profile/password'
    * configure headers = { Authorization: '#("Bearer " + login.accessToken)' }
    And request { currentPassword: 'WrongPass123', newPassword: 'Karate999@', confirmPassword: 'Karate999@' }
    When method put
    Then status 400
    * match response.message == 'Mật khẩu hiện tại không đúng'
    Given path '/api/profile/password'
    And request { currentPassword: '#(test.password)', newPassword: 'Karate999@', confirmPassword: 'Karate999@' }
    When method put
    Then status 200
    * match response.message == 'Đổi mật khẩu thành công'
    Given path '/api/auth/me'
    When method get
    Then status 401
