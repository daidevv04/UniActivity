Feature: Quản lý hoạt động

  Background:
    * url baseUrl
    * configure headers = { Authorization: '#("Bearer " + fixture.adminToken)' }
    * def now = java.time.LocalDateTime.now()
    * def start = now.plusDays(2).withNano(0).toString()
    * def end = now.plusDays(2).plusHours(2).withNano(0).toString()
    * def deadline = now.plusDays(1).withNano(0).toString()

  Scenario: TC-020 Lấy danh sách activity
    Given path '/admin/activities/api'
    And param page = 0
    And param size = 20
    When method get
    Then status 200
    And match response contains { content: '#[]', totalElements: '#number' }

  Scenario: TC-021 Tạo activity
    * def name = 'Karate Activity ' + config.test.suffix
    Given path '/admin/activities/api'
    And request { name: '#(name)', description: 'API test', location: 'Campus', startTime: '#(start)', endTime: '#(end)', registrationDeadline: '#(deadline)', scope: 'SCHOOL', status: 'OPEN', semesterId: '#(fixture.semesterId)' }
    When method post
    Then status 200
    And match response contains { id: '#number', name: '#(name)' }

  Scenario: TC-022 Xem activity vừa tạo
    * def activity = call read('helpers/create-activity.feature') { adminToken: '#(fixture.adminToken)', name: 'Karate Detail #(config.test.suffix)', status: 'OPEN', start: '#(start)', end: '#(end)', deadline: '#(deadline)', semesterId: '#(fixture.semesterId)' }
    Given path '/admin/activities/api', activity.id
    When method get
    Then status 200
    And match response contains { id: '#(activity.id)', name: '#(activity.name)' }

  Scenario: TC-023 Xóa activity chưa có registration
    * def activity = call read('helpers/create-activity.feature') { adminToken: '#(fixture.adminToken)', name: 'Karate Delete #(config.test.suffix)', status: 'DRAFT', start: '#(start)', end: '#(end)', deadline: '#(deadline)', semesterId: '#(fixture.semesterId)' }
    Given path '/admin/activities/api', activity.id
    When method delete
    Then status 200
    Given path '/admin/activities/api', activity.id
    When method get
    Then status 404
    And match response.status == 404

  Scenario: TC-024 Chặn activity thiếu tên
    Given path '/admin/activities/api'
    And request { name: '', description: 'API test', location: 'Campus', startTime: '#(start)', endTime: '#(end)', registrationDeadline: '#(deadline)', scope: 'SCHOOL', status: 'OPEN', semesterId: '#(fixture.semesterId)' }
    When method post
    Then status 400
    And match response.status == 400
    And match response.errors.name == '#string'
