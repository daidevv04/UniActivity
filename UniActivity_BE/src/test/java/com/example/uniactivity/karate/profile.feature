Feature: Hồ sơ cá nhân (TC-018, TC-022, TC-026)

  Background:
    * url baseUrl

  Scenario: TC-018 Xem hồ sơ cá nhân
    Given path '/api/profile'
    * configure headers = { Authorization: '#("Bearer " + fixture.studentAToken)' }
    When method get
    Then status 200
    * print response

  Scenario: TC-022 Đổi mật khẩu
    Given path '/api/profile/password'
    * configure headers = { Authorization: '#("Bearer " + fixture.studentAToken)' }
    And request { currentPassword: '#(config.test.password)', newPassword: 'Karate999@', confirmPassword: 'Karate999@' }
    When method put
    Then status 200
    * print response
    * def login = call read('helpers/login.feature') { username: '#(fixture.studentA.username)', password: 'Karate999@' }

  Scenario: TC-026 Từ chối sai mật khẩu hiện tại
    * def student = call read('helpers/create-student.feature') { adminToken: '#(fixture.adminToken)', email: '#("karate-tc026-" + config.test.suffix + "@example.test")', fullName: 'Karate TC26', classId: '#(fixture.classAId)' }
    * def login = call read('helpers/login.feature') { username: '#(student.username)', password: '#(config.test.password)' }
    Given path '/api/profile/password'
    * configure headers = { Authorization: '#("Bearer " + login.accessToken)' }
    And request { currentPassword: 'WrongPass123', newPassword: 'Karate999@', confirmPassword: 'Karate999@' }
    When method put
    Then status 400
    * print response