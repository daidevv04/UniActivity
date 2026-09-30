Feature: Benchmark tạo và đăng ký hoạt động

  Background:
    * url baseUrl

  Scenario: Admin login, Student login, tạo activity, tạo slot, đăng ký
    * def now = java.time.LocalDateTime.now()

    Given path '/api/auth/login'
    And request { username: '#(admin.username)', password: '#(admin.password)' }
    When method post
    Then status 200
    And match response.accessToken == '#string'
    * def adminToken = response.accessToken

    Given path '/api/auth/login'
    And request { username: '#(fixture.studentA.username)', password: '#(config.test.password)' }
    When method post
    Then status 200
    And match response.accessToken == '#string'
    * def studentToken = response.accessToken

    Given path '/admin/activities/api'
    And header Authorization = 'Bearer ' + adminToken
    And request { name: '#("Benchmark " + config.test.suffix)', description: 'Karate va Newman benchmark', location: 'Campus', startTime: '#(now.plusDays(5).withNano(0).toString())', endTime: '#(now.plusDays(5).plusHours(2).withNano(0).toString())', registrationDeadline: '#(now.plusDays(4).withNano(0).toString())', scope: 'SCHOOL', status: 'OPEN', semesterId: '#(fixture.semesterId)' }
    When method post
    Then status 200
    And match response contains { id: '#number', name: '#string' }
    * def activityId = response.id

    Given path '/admin/activities/api', activityId, 'slots'
    And header Authorization = 'Bearer ' + adminToken
    And request { classId: '#(fixture.classAId)', maxQuantity: 50 }
    When method post
    Then status 200
    And match response.id == '#number'

    Given path '/student/api/activities', activityId, 'register'
    And header Authorization = 'Bearer ' + studentToken
    When method post
    Then status 200
    And match response.message == '#string'