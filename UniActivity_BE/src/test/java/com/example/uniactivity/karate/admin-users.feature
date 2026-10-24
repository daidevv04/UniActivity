Feature: Người dùng và phân quyền (TC-19 đến TC-24)

  Background:
    * url baseUrl
    * configure headers = { Authorization: '#("Bearer " + fixture.adminToken)' }

  Scenario: TC-19 Tạo sinh viên tự sinh mã
    * def email = 'karate-u19-' + test.suffix + '@example.test'
    Given path '/admin/users/api'
    And request { email: '#(email)', fullName: 'Karate User 19', password: '#(test.password)', role: 'STUDENT', classId: '#(fixture.classAId)' }
    When method post
    Then status 200
    * match response.id == '#number'
    * match response.username == '#regex ^[0-9]{8}$'
    * match response.role == 'STUDENT'
    * match response.status == 'ACTIVE'
    * match response.email == email

  Scenario: TC-20 Danh sách người dùng phân trang
    Given path '/admin/users/api'
    And param page = 0
    And param size = 20
    When method get
    Then status 200
    * match response.content == '#array'
    * match response.totalElements == '#number'
    * match response.size == 20

  Scenario: TC-21 Cập nhật người dùng
    * def created = call read('helpers/create-user.feature') { adminToken: '#(fixture.adminToken)', email: '#("karate-u21-" + test.suffix + "@example.test")', fullName: 'Karate User 21', classId: '#(fixture.classAId)' }
    Given path '/admin/users/api', created.id
    And request { email: '#("karate-u21-updated-" + test.suffix + "@example.test")', fullName: 'Karate User 21 Updated', phone: '0987654321', role: 'STUDENT', classId: '#(fixture.classAId)' }
    When method put
    Then status 200
    Given path '/admin/users/api', created.id
    When method get
    Then status 200
    * match response.fullName == 'Karate User 21 Updated'
    * match response.phone == '0987654321'

  Scenario: TC-22 Khóa tài khoản
    * def created = call read('helpers/create-user.feature') { adminToken: '#(fixture.adminToken)', email: '#("karate-u22-" + test.suffix + "@example.test")', fullName: 'Karate User 22', classId: '#(fixture.classAId)' }
    Given path '/admin/users/api', created.id, 'toggle-status'
    When method post
    Then status 200
    Given path '/admin/users/api', created.id
    When method get
    Then status 200
    * match response.status == 'LOCKED'
    Given path '/api/auth/login'
    * configure headers = {}
    And request { username: '#(created.username)', password: '#(test.password)' }
    When method post
    Then status 401
    * match response.error == '#string'

  Scenario: TC-23 Admin reset mật khẩu và vô hiệu phiên cũ
    * def created = call read('helpers/create-user.feature') { adminToken: '#(fixture.adminToken)', email: '#("karate-u23-" + test.suffix + "@example.test")', fullName: 'Karate User 23', classId: '#(fixture.classAId)' }
    * def oldLogin = call read('helpers/login.feature') { username: '#(created.username)', password: '#(test.password)' }
    Given path '/admin/users/api', created.id, 'reset-password'
    * configure headers = { Authorization: '#("Bearer " + fixture.adminToken)' }
    And request { newPassword: 'Karate456@' }
    When method post
    Then status 200
    * def newLogin = call read('helpers/login.feature') { username: '#(created.username)', password: 'Karate456@' }
    * assert newLogin.accessToken != null
    Given path '/api/auth/me'
    * configure headers = { Authorization: '#("Bearer " + oldLogin.accessToken)' }
    When method get
    Then status 401

  Scenario: TC-24 Chặn sinh viên gọi API quản trị
    Given path '/admin/users/api'
    * configure headers = { Authorization: '#("Bearer " + fixture.studentAToken)' }
    When method get
    Then status 403
