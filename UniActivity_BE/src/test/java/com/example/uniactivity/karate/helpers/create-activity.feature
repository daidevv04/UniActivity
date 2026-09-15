Feature: Tạo activity Karate

  Scenario: Tạo activity
    Given url baseUrl
    And path '/admin/activities/api'
    And header Authorization = 'Bearer ' + __arg.adminToken
    And request { name: '#(name)', description: 'Karate API test', location: 'Campus', startTime: '#(start)', endTime: '#(end)', registrationDeadline: '#(deadline)', scope: 'SCHOOL', status: '#(status)', semesterId: '#(semesterId)' }
    When method post
    Then status 200
    * def id = response.id
    * def name = response.name
