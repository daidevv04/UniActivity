Feature: Helper tạo hoạt động

  Scenario: Tạo hoạt động qua Admin API
    * def adminAuth = 'Bearer ' + __arg.adminToken
    * def latitude = __arg.latitude
    * def longitude = __arg.longitude
    * def checkinRadius = __arg.checkinRadius
    Given url baseUrl
    * configure headers = { Authorization: '#(adminAuth)' }
    And path '/admin/activities/api'
    And request { name: '#(__arg.name)', description: 'Karate API test', location: 'Campus', latitude: '#(latitude)', longitude: '#(longitude)', checkinRadius: '#(checkinRadius)', startTime: '#(__arg.start)', endTime: '#(__arg.end)', registrationDeadline: '#(__arg.deadline)', scope: '#(__arg.scope || "SCHOOL")', status: '#(__arg.status)', semesterId: '#(__arg.semesterId)' }
    When method post
    Then status 200
    * match response.id == '#number'
    * def id = response.id
