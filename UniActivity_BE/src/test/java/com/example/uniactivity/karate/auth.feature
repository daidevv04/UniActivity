Feature: Xác thực và phiên (TC-001 đến TC-008)

  Background:
    * url baseUrl

  Scenario: TC-001 Đăng nhập hợp lệ
    Given path '/api/auth/login'
    And request { username: '#(fixture.studentA.username)', password: '#(config.test.password)' }
    When method post
    Then status 200
    * print response

  Scenario: TC-002 Từ chối sai mật khẩu
    Given path '/api/auth/login'
    And request { username: '#(fixture.studentA.username)', password: 'WrongPass123' }
    When method post
    Then status 401
    * print response

  Scenario: TC-003 Username rỗng
    Given path '/api/auth/login'
    And request { username: '', password: 'Karate123@' }
    When method post
    Then status 400
    * print response

  Scenario: TC-004 Refresh token sai
    Given path '/api/auth/refresh'
    And request { refreshToken: 'invalid-token-123' }
    When method post
    Then status 401
    * print response

  Scenario: TC-005 Thiếu JWT
    Given path '/api/auth/me'
    When method get
    Then status 401
    * print response

  Scenario: TC-006 Lấy phiên hợp lệ
    Given path '/api/auth/me'
    * configure headers = { Authorization: '#("Bearer " + fixture.studentAToken)' }
    When method get
    Then status 200
    * print response

  Scenario: TC-007 Refresh token hợp lệ
    Given path '/api/auth/refresh'
    And request { refreshToken: '#(fixture.studentARefreshToken)' }
    When method post
    Then status 200
    * print response

  Scenario: TC-008 Logout thu hồi JWT
    * def login = call read('helpers/login.feature') { username: '#(fixture.studentB.username)', password: '#(config.test.password)' }
    Given path '/api/auth/logout-jwt'
    * configure headers = { Authorization: '#("Bearer " + login.accessToken)' }
    When method post
    Then status 200
    * print response
    Given path '/api/auth/me'
    When method get
    Then status 401
    * print response

  Scenario: TC-014 OAuth code rỗng và giả
    Given path '/api/auth/oauth2/exchange'
    And request { code: '' }
    When method post
    Then status 400
    * print response
    Given path '/api/auth/oauth2/exchange'
    And request { code: 'fake-oauth-code' }
    When method post
    Then status 401
    * print response
