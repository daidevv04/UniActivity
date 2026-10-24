Feature: Helper đăng ký hoạt động

  Scenario: Đăng ký và lấy mã đăng ký
    * def studentAuth = 'Bearer ' + __arg.token
    Given url baseUrl
    * configure headers = { Authorization: '#(studentAuth)' }
    And path '/student/api/activities', __arg.activityId, 'register'
    When method post
    Then status 200
    * match response.registrationId == '#number'
    * def registrationId = response.registrationId
    * def message = response.message
