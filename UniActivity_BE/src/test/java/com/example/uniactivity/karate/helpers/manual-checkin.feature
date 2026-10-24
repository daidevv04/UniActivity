Feature: Helper điểm danh thủ công

  Scenario: Manager điểm danh
    * def managerAuth = 'Bearer ' + __arg.managerToken
    Given url baseUrl
    * configure headers = { Authorization: '#(managerAuth)' }
    And path '/manager/api/registrations', __arg.registrationId, 'checkin'
    When method post
    Then status 200
    * match response.message contains 'Đã điểm danh thành công'
