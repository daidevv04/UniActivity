Feature: Manager điểm danh (TC-042 đến TC-044)

  Background:
    * url baseUrl
    * configure headers = { Authorization: '#("Bearer " + fixture.managerAToken)' }

  Scenario: TC-042 Manager điểm danh tay
    * def prep = call read('helpers/prepare-reg.feature') { name: 'TC42' }
    Given path '/manager/api/registrations', prep.registrationId, 'checkin'
    When method post
    Then status 200
    * print response
    Given path '/student/api/my-registrations'
    * configure headers = { Authorization: '#("Bearer " + prep.token)' }
    When method get
    Then status 200
    * print response

  Scenario: TC-043 Manager xem registrations
    * def prep = call read('helpers/prepare-reg.feature') { name: 'TC43' }
    Given path '/manager/api/activities', fixture.liveActivityId, 'registrations'
    And param page = 0
    And param size = 20
    When method get
    Then status 200
    * print response

  Scenario: TC-044 Manager duyệt minh chứng đúng một lần
    * def prep = call read('helpers/prepare-reg.feature') { name: 'TC44' }
    * call read('helpers/manual-checkin.feature') { registrationId: '#(prep.registrationId)' }
    * call read('helpers/upload-evidence.feature') { token: '#(prep.token)' }
    Given path '/manager/api/registrations', prep.registrationId, 'approve'
    * configure headers = { Authorization: '#("Bearer " + fixture.managerAToken)' }
    When method post
    Then status 200
    * print response
    Given path '/manager/api/registrations', prep.registrationId, 'approve'
    When method post
    Then status 409
    * print response
