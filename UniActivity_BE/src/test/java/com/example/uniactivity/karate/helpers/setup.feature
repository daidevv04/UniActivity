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
    * def academicYearId = response.id

    Given path '/admin/faculties/api'
    And request { code: '#("KARATE-" + suffix)', name: '#("Karate Faculty " + suffix)', status: 'ACTIVE' }
    When method post
    Then status 200
    * def facultyId = response.id

    Given path '/admin/classes/api'
    And request { code: '#("KARATE-" + suffix)', name: '#("Karate Class " + suffix)', facultyId: '#(facultyId)', academicYearId: '#(academicYearId)' }
    When method post
    Then status 200
    * def classAId = response.id

    Given path '/admin/semesters/api'
    And request { name: '#("Karate Semester " + suffix)', startDate: '2026-01-01', endDate: '2026-12-31', isCurrent: true }
    When method post
    Then status 200
    * def semesterId = response.id

    * def studentA = call read('classpath:com/example/uniactivity/karate/helpers/create-student.feature') { adminToken: '#(adminToken)', email: '#(test.studentAEmail)', fullName: 'Karate Student A', classId: '#(classAId)' }
    * def studentB = call read('classpath:com/example/uniactivity/karate/helpers/create-student.feature') { adminToken: '#(adminToken)', email: '#(test.studentBEmail)', fullName: 'Karate Student B', classId: '#(classAId)' }
    * def registrationStudent1 = call read('classpath:com/example/uniactivity/karate/helpers/create-student.feature') { adminToken: '#(adminToken)', email: '#("karate-registration-1-" + suffix + "@example.test")', fullName: 'Karate Registration Student 1', classId: '#(classAId)' }
    * def registrationStudent2 = call read('classpath:com/example/uniactivity/karate/helpers/create-student.feature') { adminToken: '#(adminToken)', email: '#("karate-registration-2-" + suffix + "@example.test")', fullName: 'Karate Registration Student 2', classId: '#(classAId)' }
    * def registrationStudent3 = call read('classpath:com/example/uniactivity/karate/helpers/create-student.feature') { adminToken: '#(adminToken)', email: '#("karate-registration-3-" + suffix + "@example.test")', fullName: 'Karate Registration Student 3', classId: '#(classAId)' }
    * def studentALogin = call read('classpath:com/example/uniactivity/karate/helpers/login.feature') { username: '#(studentA.username)', password: '#(test.password)' }
    * def studentBLogin = call read('classpath:com/example/uniactivity/karate/helpers/login.feature') { username: '#(studentB.username)', password: '#(test.password)' }
    * def registrationStudent1Login = call read('classpath:com/example/uniactivity/karate/helpers/login.feature') { username: '#(registrationStudent1.username)', password: '#(test.password)' }
    * def registrationStudent2Login = call read('classpath:com/example/uniactivity/karate/helpers/login.feature') { username: '#(registrationStudent2.username)', password: '#(test.password)' }
    * def registrationStudent3Login = call read('classpath:com/example/uniactivity/karate/helpers/login.feature') { username: '#(registrationStudent3.username)', password: '#(test.password)' }

    * def now = java.time.LocalDateTime.now()
    * def openActivity = call read('classpath:com/example/uniactivity/karate/helpers/create-activity.feature') { adminToken: '#(adminToken)', name: '#("Karate Open " + suffix)', status: 'OPEN', start: '#(now.plusDays(2).withNano(0).toString())', end: '#(now.plusDays(2).plusHours(2).withNano(0).toString())', deadline: '#(now.plusDays(1).withNano(0).toString())', semesterId: '#(semesterId)' }

    Given path '/admin/activities/api', openActivity.id, 'slots'
    And request { classId: '#(classAId)', maxQuantity: 100 }
    When method post
    Then status 200

    * def fixture = { adminToken: '#(adminToken)', academicYearId: '#(academicYearId)', facultyId: '#(facultyId)', classAId: '#(classAId)', semesterId: '#(semesterId)', studentA: '#(studentA)', studentB: '#(studentB)', studentAToken: '#(studentALogin.accessToken)', studentARefreshToken: '#(studentALogin.refreshToken)', studentBToken: '#(studentBLogin.accessToken)', registrationStudent1: '#(registrationStudent1)', registrationStudent1Token: '#(registrationStudent1Login.accessToken)', registrationStudent2: '#(registrationStudent2)', registrationStudent2Token: '#(registrationStudent2Login.accessToken)', registrationStudent3: '#(registrationStudent3)', registrationStudent3Token: '#(registrationStudent3Login.accessToken)', openActivityId: '#(openActivity.id)' }
