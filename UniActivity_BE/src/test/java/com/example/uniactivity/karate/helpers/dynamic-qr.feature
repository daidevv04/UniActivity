Feature: Helper lấy mã QR động

  Scenario: Lấy token QR động từ Manager
    * def managerAuth = 'Bearer ' + __arg.managerToken
    Given url baseUrl
    * configure headers = { Authorization: '#(managerAuth)' }
    And path '/manager/api/qrcode/dynamic', __arg.activityId
    When method get
    Then status 200
    * match response.token == '#string'
    * match response.checkinCode == '#string'
    * def token = response.token
    * def checkinCode = response.checkinCode
