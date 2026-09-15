Feature: Xác thực và phiên làm việc

  Background:
    * url baseUrl

  Scenario: TC-001 Đăng nhập hợp lệ
    Given path '/api/auth/login'
    And request { username: '#(fixture.studentA.username)', password: '#(config.test.password)' }
    When method post
    Then status 200
    And match response contains { tokenType: 'Bearer', accessToken: '#string', refreshToken: '#string', expiresIn: '#number' }
    And match response.user contains { username: '#(fixture.studentA.username)', role: 'STUDENT', status: 'ACTIVE' }

  Scenario: TC-002 Sai mật khẩu
    Given path '/api/auth/login'
    And request { username: '#(fixture.studentA.username)', password: 'sai_mat_khau' }
    When method post
    Then status 401
    And match response.error == '#string'
    And match response.accessToken == '#notpresent'

  Scenario: TC-003 Username rỗng
    Given path '/api/auth/login'
    And request { username: '', password: '123' }
    When method post
    Then status 400
    And match response.error == '#string'

  Scenario: TC-004 Refresh token giả
    Given path '/api/auth/refresh'
    And request { refreshToken: 'fake.token' }
    When method post
    Then status 401
    And match response.error == '#string'
    And match response.accessToken == '#notpresent'

  Scenario: TC-005 Không có JWT
    Given path '/api/auth/me'
    When method get
    Then status 401

  Scenario: TC-006 Xem phiên bằng JWT hợp lệ
    Given path '/api/auth/me'
    And header Authorization = 'Bearer ' + fixture.studentAToken
    When method get
    Then status 200
    And match response contains { id: '#(fixture.studentA.id)', username: '#(fixture.studentA.username)', role: 'STUDENT' }

  Scenario: TC-007 Refresh token hợp lệ
    Given path '/api/auth/refresh'
    And request { refreshToken: '#(fixture.studentARefreshToken)' }
    When method post
    Then status 200
    And match response contains { tokenType: 'Bearer', accessToken: '#string' }

  Scenario: TC-008 Thu hồi JWT sau logout
    * def login = call read('helpers/login.feature') { username: '#(fixture.studentB.username)', password: '#(config.test.password)' }
    Given path '/api/auth/logout-jwt'
    And header Authorization = 'Bearer ' + login.accessToken
    When method post
    Then status 200
    And match response.message == '#string'
    Given path '/api/auth/me'
    And header Authorization = 'Bearer ' + login.accessToken
    When method get
    Then status 401
