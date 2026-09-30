Feature: Manager điểm danh tay Karate

  Scenario: Điểm danh tay
    * def managerAuth = 'Bearer ' + fixture.managerAToken
    Given url baseUrl
    * configure headers = { Authorization: '#(managerAuth)' }
    And path '/manager/api/registrations', __arg.registrationId, 'checkin'
    When method post
    Then status 200