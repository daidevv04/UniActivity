Feature: Tạo activity Karate

  Scenario: Tạo activity
    * def adminAuth = 'Bearer ' + __arg.adminToken
    Given url baseUrl
    * configure headers = { Authorization: '#(adminAuth)' }
    And path '/admin/activities/api'
    And request { name: '#(name)', description: 'Karate API test', location: 'Campus', startTime: '#(start)', endTime: '#(end)', registrationDeadline: '#(deadline)', scope: 'SCHOOL', status: '#(status)', semesterId: '#(semesterId)' }
    When method post
    Then status 200
    * print response
    * def id = response.id
    * def name = response.name
