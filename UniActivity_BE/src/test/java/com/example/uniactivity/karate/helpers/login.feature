Feature: Helper đăng nhập

  Scenario: Đăng nhập và trả token
    Given url baseUrl
    And path '/api/auth/login'
    And request { username: '#(username)', password: '#(password)' }
    When method post
    Then status 200
    * match response.accessToken == '#string'
    * match response.refreshToken == '#string'
    * match response.tokenType == 'Bearer'
    * def accessToken = response.accessToken
    * def refreshToken = response.refreshToken
    * def user = response.user
