Feature: Lấy token QR động Karate

  Scenario: Lấy QR động
    * def managerAuth = 'Bearer ' + fixture.managerAToken
    Given url baseUrl
    * configure headers = { Authorization: '#(managerAuth)' }
    And path '/manager/api/qrcode/dynamic', fixture.liveActivityId
    When method get
    Then status 200
    * print response
    * def token = response.token