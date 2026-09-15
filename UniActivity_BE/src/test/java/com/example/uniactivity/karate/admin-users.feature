Feature: Quản lý người dùng và RBAC

  Background:
    * url baseUrl
    * configure headers = { Authorization: '#("Bearer " + fixture.adminToken)' }

  Scenario: TC-013 Lấy danh sách user phân trang
    Given path '/admin/users/api'
    And param page = 0
    And param size = 20
    When method get
    Then status 200
    And match response contains { content: '#[]', totalElements: '#number' }

  Scenario: TC-014 Tạo Student tự sinh mã
    * def email = 'student-create-' + test.suffix + '@example.test'
    Given path '/admin/users/api'
    And request { email: '#(email)', fullName: 'Karate Created Student', password: '#(test.password)', role: 'STUDENT', classId: '#(fixture.classAId)' }
    When method post
    Then status 200
    And match response.id == '#number'
    And match response.username == '#regex ^[0-9]{8}$'
    And match response.email == email

  Scenario: TC-015 Xem Student vừa tạo
    * def student = call read('helpers/create-student.feature') { adminToken: '#(fixture.adminToken)', email: '#("student-detail-" + test.suffix + "@example.test")', fullName: 'Karate Detail Student', classId: '#(fixture.classAId)' }
    Given path '/admin/users/api', student.id
    When method get
    Then status 200
    And match response contains { id: '#(student.id)', email: '#(student.email)', role: 'STUDENT' }

  Scenario: TC-016 Khóa tài khoản ACTIVE
    * def student = call read('helpers/create-student.feature') { adminToken: '#(fixture.adminToken)', email: '#("student-lock-" + test.suffix + "@example.test")', fullName: 'Karate Lock Student', classId: '#(fixture.classAId)' }
    Given path '/admin/users/api', student.id, 'toggle-status'
    When method post
    Then status 200
    Given path '/admin/users/api', student.id
    When method get
    Then status 200
    And match response.status == 'LOCKED'

  Scenario: TC-017 Mở lại tài khoản LOCKED
    * def student = call read('helpers/create-student.feature') { adminToken: '#(fixture.adminToken)', email: '#("student-unlock-" + test.suffix + "@example.test")', fullName: 'Karate Unlock Student', classId: '#(fixture.classAId)' }
    Given path '/admin/users/api', student.id, 'toggle-status'
    When method post
    Then status 200
    Given path '/admin/users/api', student.id, 'toggle-status'
    When method post
    Then status 200
    Given path '/admin/users/api', student.id
    When method get
    Then status 200
    And match response.status == 'ACTIVE'

  Scenario: TC-018 Reset mật khẩu
    * def student = call read('helpers/create-student.feature') { adminToken: '#(fixture.adminToken)', email: '#("student-reset-" + test.suffix + "@example.test")', fullName: 'Karate Reset Student', classId: '#(fixture.classAId)' }
    Given path '/admin/users/api', student.id, 'reset-password'
    And request { newPassword: '#(test.resetPassword)' }
    When method post
    Then status 200
    Given path '/api/auth/login'
    And request { username: '#(student.username)', password: '#(test.resetPassword)' }
    When method post
    Then status 200
    And match response.accessToken == '#string'

  Scenario: TC-019 Chặn Student truy cập Admin
    * configure headers = { Authorization: '#("Bearer " + fixture.studentAToken)' }
    Given path '/admin/users/api'
    When method get
    Then status 403
