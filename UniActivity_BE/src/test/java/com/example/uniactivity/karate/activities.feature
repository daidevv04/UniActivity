Feature: Admin quản lý hoạt động (TC-035 đến TC-041)

  Background:
    * url baseUrl
    * configure headers = { Authorization: '#("Bearer " + fixture.adminToken)' }

  Scenario: TC-035 Danh sách activity Admin
    Given path '/admin/activities/api'
    And param page = 0
    And param size = 20
    When method get
    Then status 200
    * print response

  Scenario: TC-036 Tạo activity
    * def now = java.time.LocalDateTime.now()
    Given path '/admin/activities/api'
    And request { name: '#("Karate Activity " + config.test.suffix)', description: 'Karate activity', location: 'Campus', startTime: '#(now.plusDays(5).withNano(0).toString())', endTime: '#(now.plusDays(5).plusHours(2).withNano(0).toString())', registrationDeadline: '#(now.plusDays(4).withNano(0).toString())', scope: 'SCHOOL', status: 'OPEN', semesterId: '#(fixture.semesterId)' }
    When method post
    Then status 200
    * print response

  Scenario: TC-037 Xem activity
    * def now = java.time.LocalDateTime.now()
    * def activity = call read('helpers/create-activity.feature') { adminToken: '#(fixture.adminToken)', name: '#("Karate TC37 " + config.test.suffix)', status: 'OPEN', start: '#(now.plusDays(5).withNano(0).toString())', end: '#(now.plusDays(5).plusHours(2).withNano(0).toString())', deadline: '#(now.plusDays(4).withNano(0).toString())', semesterId: '#(fixture.semesterId)' }
    Given path '/admin/activities/api', activity.id
    When method get
    Then status 200
    * print response

  Scenario: TC-038 Cập nhật activity
    * def now = java.time.LocalDateTime.now()
    * def activity = call read('helpers/create-activity.feature') { adminToken: '#(fixture.adminToken)', name: '#("Karate TC38 " + config.test.suffix)', status: 'OPEN', start: '#(now.plusDays(5).withNano(0).toString())', end: '#(now.plusDays(5).plusHours(2).withNano(0).toString())', deadline: '#(now.plusDays(4).withNano(0).toString())', semesterId: '#(fixture.semesterId)' }
    Given path '/admin/activities/api', activity.id
    And request { name: '#("Karate Updated " + config.test.suffix)', description: 'Updated', location: 'Campus', startTime: '#(now.plusDays(5).withNano(0).toString())', endTime: '#(now.plusDays(5).plusHours(2).withNano(0).toString())', registrationDeadline: '#(now.plusDays(4).withNano(0).toString())', scope: 'SCHOOL', status: 'OPEN', semesterId: '#(fixture.semesterId)' }
    When method put
    Then status 200
    * print response
    Given path '/admin/activities/api', activity.id
    When method get
    Then status 200
    * print response

  Scenario: TC-039 Validation tên activity rỗng
    * def now = java.time.LocalDateTime.now()
    Given path '/admin/activities/api'
    And request { name: '', description: 'Invalid', location: 'Campus', startTime: '#(now.plusDays(5).withNano(0).toString())', endTime: '#(now.plusDays(5).plusHours(2).withNano(0).toString())', registrationDeadline: '#(now.plusDays(4).withNano(0).toString())', scope: 'SCHOOL', status: 'OPEN', semesterId: '#(fixture.semesterId)' }
    When method post
    Then status 400
    * print response

  Scenario: TC-040 Tạo slot
    Given path '/admin/activities/api', fixture.openActivityId, 'slots'
    And request { classId: '#(fixture.classBId)', maxQuantity: 50 }
    When method post
    Then status 200
    * print response

  Scenario: TC-041 Xem slot
    Given path '/admin/activities/api', fixture.openActivityId, 'slots'
    When method get
    Then status 200
    * print response
