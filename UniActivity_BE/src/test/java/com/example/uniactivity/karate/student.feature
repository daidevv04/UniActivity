Feature: Student đăng ký và check-in (TC-045 đến TC-053)

  Background:
    * url baseUrl

  Scenario: TC-045 Danh sách activity Student
    * def student = call read('helpers/create-student.feature') { adminToken: '#(fixture.adminToken)', email: '#("karate-tc045-" + config.test.suffix + "@example.test")', fullName: 'Karate TC45', classId: '#(fixture.classAId)' }
    * def login = call read('helpers/login.feature') { username: '#(student.username)', password: '#(config.test.password)' }
    Given path '/student/api/activities'
    * configure headers = { Authorization: '#("Bearer " + login.accessToken)' }
    When method get
    Then status 200
    * print response

  Scenario: TC-046 Đăng ký activity
    * def prep = call read('helpers/prepare-reg.feature') { name: 'TC46' }
    Given path '/student/api/my-registrations'
    * configure headers = { Authorization: '#("Bearer " + prep.token)' }
    When method get
    Then status 200
    * print response

  Scenario: TC-047 Chặn đăng ký trùng
    * def prep = call read('helpers/prepare-reg.feature') { name: 'TC47' }
    Given path '/student/api/activities', fixture.liveActivityId, 'register'
    * configure headers = { Authorization: '#("Bearer " + prep.token)' }
    When method post
    Then status 409
    * print response

  Scenario: TC-048 Hủy đăng ký
    * def prep = call read('helpers/prepare-reg.feature') { name: 'TC48' }
    Given path '/student/api/activities', fixture.liveActivityId, 'register'
    * configure headers = { Authorization: '#("Bearer " + prep.token)' }
    When method delete
    Then status 200
    * print response

  Scenario: TC-049 Xem đăng ký cá nhân
    * def prep = call read('helpers/prepare-reg.feature') { name: 'TC49' }
    Given path '/student/api/my-registrations'
    * configure headers = { Authorization: '#("Bearer " + prep.token)' }
    When method get
    Then status 200
    * print response

  Scenario: TC-050 Chặn check-in thiếu token
    * def prep = call read('helpers/prepare-reg.feature') { name: 'TC50' }
    Given path '/student/api/checkin', fixture.liveActivityId
    * configure headers = { Authorization: '#("Bearer " + prep.token)' }
    When method post
    Then status 400
    * print response

  Scenario: TC-051 Chặn check-in token sai
    * def prep = call read('helpers/prepare-reg.feature') { name: 'TC51' }
    Given path '/student/api/checkin', fixture.liveActivityId
    * configure headers = { Authorization: '#("Bearer " + prep.token)' }
    And param token = 'SAI123'
    When method post
    Then status 400
    * print response

  Scenario: TC-052 Check-in QR động
    * def prep = call read('helpers/prepare-reg.feature') { name: 'TC52' }
    * def qr = call read('helpers/dynamic-qr.feature')
    Given path '/student/api/checkin', fixture.liveActivityId
    * configure headers = { Authorization: '#("Bearer " + prep.token)' }
    And param classId = fixture.classAId
    And param token = qr.token
    And param lat = 10.762622
    And param lng = 106.660172
    And param accuracy = 5
    When method post
    Then status 200
    * print response

  Scenario: TC-053 Chặn check-in ngoài GPS
    * def prep = call read('helpers/prepare-reg.feature') { name: 'TC53' }
    * def qr = call read('helpers/dynamic-qr.feature')
    Given path '/student/api/checkin', fixture.liveActivityId
    * configure headers = { Authorization: '#("Bearer " + prep.token)' }
    And param classId = fixture.classAId
    And param token = qr.token
    And param lat = 0
    And param lng = 0
    And param accuracy = 5
    When method post
    Then status 400
    * print response
