Feature: Nghiệp vụ Student

  Background:
    * url baseUrl
    * configure headers = { Authorization: '#("Bearer " + fixture.studentAToken)' }

  Scenario: TC-025 Lấy activity hiển thị
    Given path '/student/api/activities'
    When method get
    Then status 200
    And match response.hasClass == true
    And match response.activities == '#[]'
    And match response.registeredActivityIds == '#[]'

  Scenario: TC-026 Student xem điểm bản thân
    Given path '/student/api/users', fixture.studentA.id, 'scores'
    When method get
    Then status 200
    And match response contains { totalScore: '#number', classification: '#string', categoryTotals: '#object', user: '#object' }
    And match response.user.id == fixture.studentA.id

  Scenario: TC-027 Chặn Student xem điểm người khác
    Given path '/student/api/users', fixture.studentB.id, 'scores'
    When method get
    Then status 403
    And match response.status == 403
    And match response.message == '#string'

  Scenario: TC-028 Đăng ký activity
    * configure headers = { Authorization: '#("Bearer " + fixture.registrationStudent1Token)' }
    Given path '/student/api/activities', fixture.openActivityId, 'register'
    When method post
    Then status 200
    Given path '/student/api/my-registrations'
    And header Authorization = 'Bearer ' + fixture.registrationStudent1Token
    When method get
    Then status 200
    * def registration = karate.filter(response.registrations, function(x){ return x.activity.id == fixture.openActivityId })[0]
    And match registration.status == 'REGISTERED'

  Scenario: TC-029 Hủy activity đã đăng ký
    * configure headers = { Authorization: '#("Bearer " + fixture.registrationStudent2Token)' }
    Given path '/student/api/activities', fixture.openActivityId, 'register'
    When method post
    Then status 200
    Given path '/student/api/activities', fixture.openActivityId, 'register'
    When method delete
    Then status 200
    Given path '/student/api/my-registrations'
    And header Authorization = 'Bearer ' + fixture.registrationStudent2Token
    When method get
    Then status 200
    * def registration = karate.filter(response.registrations, function(x){ return x.activity.id == fixture.openActivityId })[0]
    And match registration.status == 'CANCELLED'

  Scenario: TC-030 Chặn đăng ký trùng activity
    * configure headers = { Authorization: '#("Bearer " + fixture.registrationStudent3Token)' }
    Given path '/student/api/activities', fixture.openActivityId, 'register'
    When method post
    Then status 200
    Given path '/student/api/activities', fixture.openActivityId, 'register'
    When method post
    Then status 409
    And match response.message == '#string'
