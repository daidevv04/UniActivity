Feature: Helper đăng nhập Karate

  Scenario: Đăng nhập
    Given url baseUrl
    And path '/api/auth/login'
    And request { username: '#(username)', password: '#(password)' }
    When method post
    Then status 200
    * def accessToken = response.accessToken
    * def refreshToken = response.refreshToken
    * def user = response.user
