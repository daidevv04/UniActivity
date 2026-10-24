Feature: Xác thực và phiên (TC-01 đến TC-06)

  Background:
    * url baseUrl

  Scenario: TC-01 Đăng nhập hợp lệ
    Given path '/api/auth/login'
    And request { username: '#(fixture.studentA.username)', password: '#(test.password)' }
    When method post
    Then status 200
    * match response.accessToken == '#string'
    * match response.refreshToken == '#string'
    * match response.tokenType == 'Bearer'
    * match response.expiresIn == '#number'
    * match response.user.role == 'STUDENT'
    * match response.user.status == 'ACTIVE'
    * match response.user.username == fixture.studentA.username

  Scenario: TC-02 Từ chối sai mật khẩu
    Given path '/api/auth/login'
    And request { username: '#(fixture.studentA.username)', password: 'WrongPass123' }
    When method post
    Then status 401
    * match response.error == '#string'
    * match response !contains { accessToken: '#notnull' }

  Scenario: TC-03 Username rỗng
    Given path '/api/auth/login'
    And request { username: '', password: '#(test.password)' }
    When method post
    Then status 400
    * match response.error == 'Vui lòng nhập email hoặc mã tài khoản và mật khẩu.'

  Scenario: TC-04 Refresh token hợp lệ
    Given path '/api/auth/refresh'
    And request { refreshToken: '#(fixture.studentARefreshToken)' }
    When method post
    Then status 200
    * match response.accessToken == '#string'
    * match response.tokenType == 'Bearer'
    * match response.expiresIn == '#number'

  Scenario: TC-05 Từ chối access token dùng như refresh token
    Given path '/api/auth/refresh'
    And request { refreshToken: '#(fixture.studentAToken)' }
    When method post
    Then status 401
    * match response.error == 'Token không phải refresh token.'

  Scenario: TC-06 Logout thu hồi access và refresh token
    * def login = call read('helpers/login.feature') { username: '#(fixture.studentB.username)', password: '#(test.password)' }
    Given path '/api/auth/logout-jwt'
    * configure headers = { Authorization: '#("Bearer " + login.accessToken)' }
    When method post
    Then status 200
    * match response.message == '#string'
    Given path '/api/auth/me'
    When method get
    Then status 401
    Given path '/api/auth/refresh'
    And request { refreshToken: '#(login.refreshToken)' }
    When method post
    Then status 401
