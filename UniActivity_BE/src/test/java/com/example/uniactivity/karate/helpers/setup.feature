Feature: Khởi tạo dữ liệu Karate trên server 8080

  Scenario: Tạo toàn bộ fixture và token
    * def adminLogin = call read('classpath:com/example/uniactivity/karate/helpers/login.feature') admin
    * def adminToken = adminLogin.accessToken
    * def adminAuth = 'Bearer ' + adminToken
    * def suffix = test.suffix

    Given url baseUrl
    * configure headers = { Authorization: '#(adminAuth)' }
    And path '/admin/academic-years/api'
    And request { code: '#("KARATE-" + suffix)', startYear: 2026, endYear: 2027, status: 'ACTIVE' }
    When method post
    Then status 200
    * print response
    * def academicYearId = response.id

    Given path '/admin/faculties/api'
    And request { code: '#("KARATE-" + suffix)', name: '#("Karate Faculty " + suffix)', status: 'ACTIVE' }
    When method post
    Then status 200
    * print response
    * def facultyId = response.id

    Given path '/admin/classes/api'
    And request { code: '#("KARATE-" + suffix)', name: '#("Karate Class " + suffix)', facultyId: '#(facultyId)', academicYearId: '#(academicYearId)' }
    When method post
    Then status 200
    * print response
    * def classAId = response.id

    Given path '/admin/semesters/api'
    And request { name: '#("Karate Semester " + suffix)', startDate: '2026-01-01', endDate: '2026-12-31', isCurrent: true }
    When method post
    Then status 200
    * print response
    * def semesterId = response.id

    * def studentA = call read('classpath:com/example/uniactivity/karate/helpers/create-student.feature') { adminToken: '#(adminToken)', email: '#(test.studentAEmail)', fullName: 'Karate Student A', classId: '#(classAId)' }
    * def studentB = call read('classpath:com/example/uniactivity/karate/helpers/create-student.feature') { adminToken: '#(adminToken)', email: '#(test.studentBEmail)', fullName: 'Karate Student B', classId: '#(classAId)' }
    * def studentALogin = call read('classpath:com/example/uniactivity/karate/helpers/login.feature') { username: '#(studentA.username)', password: '#(test.password)' }

    * def now = java.time.LocalDateTime.now()
    * def openActivity = call read('classpath:com/example/uniactivity/karate/helpers/create-activity.feature') { adminToken: '#(adminToken)', name: '#("Karate Open " + suffix)', status: 'OPEN', start: '#(now.plusDays(2).withNano(0).toString())', end: '#(now.plusDays(2).plusHours(2).withNano(0).toString())', deadline: '#(now.plusDays(1).withNano(0).toString())', semesterId: '#(semesterId)' }

    Given path '/admin/activities/api', openActivity.id, 'slots'
    And request { classId: '#(classAId)', maxQuantity: 100 }
    When method post
    Then status 200
    * print response

    * def now2 = java.time.LocalDateTime.now()
    Given path '/admin/classes/api'
    And request { code: '#("KARATEB-" + suffix)', name: '#("Karate Class B " + suffix)', facultyId: '#(facultyId)', academicYearId: '#(academicYearId)' }
    When method post
    Then status 200
    * print response
    * def classBId = response.id

    Given path '/admin/users/api'
    And request { email: '#("karate-manager-a-" + suffix + "@example.test")', fullName: 'Karate Manager A', password: '#(test.password)', role: 'MANAGER', classId: '#(classAId)' }
    When method post
    Then status 200
    * print response
    * def managerAUsername = response.username

    * def managerALogin = call read('classpath:com/example/uniactivity/karate/helpers/login.feature') { username: '#(managerAUsername)', password: '#(test.password)' }
    * def managerAToken = managerALogin.accessToken

    Given path '/admin/activities/api'
    And request { name: '#("Karate Live " + suffix)', description: 'Karate live check-in', location: 'Campus', latitude: 10.762622, longitude: 106.660172, checkinRadius: 100, startTime: '#(now2.minusHours(1).withNano(0).toString())', endTime: '#(now2.plusHours(2).withNano(0).toString())', registrationDeadline: '#(now2.plusHours(1).withNano(0).toString())', scope: 'SCHOOL', status: 'OPEN', semesterId: '#(semesterId)' }
    When method post
    Then status 200
    * print response
    * def liveActivityId = response.id

    Given path '/admin/activities/api', liveActivityId, 'slots'
    And request { classId: '#(classAId)', maxQuantity: 100 }
    When method post
    Then status 200
    * print response

    Given path '/admin/activities/api', liveActivityId, 'score-options'
    And request { name: 'Tham gia', scoreCategory: '3.1', scoreValue: 5 }
    When method post
    Then status 200
    * print response
    * def scoreOptionId = response.id

    * def fixture = { adminToken: '#(adminToken)', academicYearId: '#(academicYearId)', facultyId: '#(facultyId)', classAId: '#(classAId)', classBId: '#(classBId)', semesterId: '#(semesterId)', studentA: '#(studentA)', studentB: '#(studentB)', studentAToken: '#(studentALogin.accessToken)', studentARefreshToken: '#(studentALogin.refreshToken)', openActivityId: '#(openActivity.id)', managerAToken: '#(managerAToken)', liveActivityId: '#(liveActivityId)', scoreOptionId: '#(scoreOptionId)' }

