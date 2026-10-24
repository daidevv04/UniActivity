Feature: Helper lấy đăng ký của sinh viên

  Scenario: Lấy registration theo activity
    * def studentAuth = 'Bearer ' + __arg.token
    Given url baseUrl
    * configure headers = { Authorization: '#(studentAuth)' }
    And path '/student/api/my-registrations'
    When method get
    Then status 200
    * def registration = karate.filter(response.registrations, function(x){ return x.activity.id == __arg.activityId })[0]
    * assert registration != null
    * def registrationId = registration.id
    * def status = registration.status
