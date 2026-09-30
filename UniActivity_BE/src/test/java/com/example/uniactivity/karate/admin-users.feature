Feature: Admin quản lý người dùng (TC-027 đến TC-034)

  Background:
    * url baseUrl
    * configure headers = { Authorization: '#("Bearer " + fixture.adminToken)' }

  Scenario: TC-027 Danh sách user phân trang
    Given path '/admin/users/api'
    And param page = 0
    And param size = 20
    When method get
    Then status 200
    * print response

  Scenario: TC-028 Tạo Student
    Given path '/admin/users/api'
    And request { email: '#("student-" + config.test.suffix + "@example.test")', fullName: 'Karate Student', password: '#(config.test.password)', role: 'STUDENT', classId: '#(fixture.classAId)' }
    When method post
    Then status 200
    * print response

  Scenario: TC-029 Xem user vừa tạo
    * def created = call read('helpers/create-student.feature') { adminToken: '#(fixture.adminToken)', email: '#("karate-tc029-" + config.test.suffix + "@example.test")', fullName: 'Karate TC29', classId: '#(fixture.classAId)' }
    Given path '/admin/users/api', created.id
    When method get
    Then status 200
    * print response

  Scenario: TC-030 Cập nhật user
    * def created = call read('helpers/create-student.feature') { adminToken: '#(fixture.adminToken)', email: '#("karate-tc030-" + config.test.suffix + "@example.test")', fullName: 'Karate TC30', classId: '#(fixture.classAId)' }
    Given path '/admin/users/api', created.id
    And request { email: '#("student-upd-" + config.test.suffix + "@example.test")', fullName: 'Karate Student Updated', phone: '0987654321', role: 'STUDENT', classId: '#(fixture.classAId)' }
    When method put
    Then status 200
    * print response
    Given path '/admin/users/api', created.id
    When method get
    Then status 200
    * print response

  Scenario: TC-031 Khóa user ACTIVE
    * def created = call read('helpers/create-student.feature') { adminToken: '#(fixture.adminToken)', email: '#("karate-tc031-" + config.test.suffix + "@example.test")', fullName: 'Karate TC31', classId: '#(fixture.classAId)' }
    Given path '/admin/users/api', created.id, 'toggle-status'
    When method post
    Then status 200
    * print response
    Given path '/admin/users/api', created.id
    When method get
    Then status 200
    * print response

  Scenario: TC-032 Mở user LOCKED
    * def created = call read('helpers/create-student.feature') { adminToken: '#(fixture.adminToken)', email: '#("karate-tc032-" + config.test.suffix + "@example.test")', fullName: 'Karate TC32', classId: '#(fixture.classAId)' }
    Given path '/admin/users/api', created.id, 'toggle-status'
    When method post
    Then status 200
    * print response
    Given path '/admin/users/api', created.id, 'toggle-status'
    When method post
    Then status 200
    * print response
    Given path '/admin/users/api', created.id
    When method get
    Then status 200
    * print response

  Scenario: TC-033 Admin reset mật khẩu
    * def created = call read('helpers/create-student.feature') { adminToken: '#(fixture.adminToken)', email: '#("karate-tc033-" + config.test.suffix + "@example.test")', fullName: 'Karate TC33', classId: '#(fixture.classAId)' }
    Given path '/admin/users/api', created.id, 'reset-password'
    And request { newPassword: '#(config.test.resetPassword)' }
    When method post
    Then status 200
    * print response
    * def login = call read('helpers/login.feature') { username: '#(created.username)', password: '#(config.test.resetPassword)' }

  Scenario: TC-034 Student không vào Admin API
    * def student = call read('helpers/create-student.feature') { adminToken: '#(fixture.adminToken)', email: '#("karate-tc034-" + config.test.suffix + "@example.test")', fullName: 'Karate TC34', classId: '#(fixture.classAId)' }
    * def login = call read('helpers/login.feature') { username: '#(student.username)', password: '#(config.test.password)' }
    Given path '/admin/users/api'
    * configure headers = { Authorization: '#("Bearer " + login.accessToken)' }
    When method get
    Then status 403
    * print response
