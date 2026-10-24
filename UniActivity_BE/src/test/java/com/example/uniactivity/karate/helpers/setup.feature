Feature: Khởi tạo fixture dùng chung

  Scenario: Tạo dữ liệu nền và token
    * def adminLogin = call read('classpath:com/example/uniactivity/karate/helpers/login.feature') { username: '#(admin.username)', password: '#(admin.password)' }
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

    And path '/admin/faculties/api'
    And request { code: '#("KARATE-" + suffix)', name: '#("Karate Faculty " + suffix)', status: 'ACTIVE' }
    When method post
    Then status 200
    * def facultyId = response.id

    And path '/admin/semesters/api'
    And request { name: '#("Karate Semester " + suffix)', startDate: '2026-01-01', endDate: '2026-12-31', isCurrent: true }
    When method post
    Then status 200
    * def semesterId = response.id

    * def classA = call read('classpath:com/example/uniactivity/karate/helpers/create-class.feature') { adminToken: '#(adminToken)', code: '#("KARATE-A-" + suffix)', name: '#("Karate Class A " + suffix)', facultyId: '#(facultyId)', academicYearId: '#(academicYearId)' }
    * def classB = call read('classpath:com/example/uniactivity/karate/helpers/create-class.feature') { adminToken: '#(adminToken)', code: '#("KARATE-B-" + suffix)', name: '#("Karate Class B " + suffix)', facultyId: '#(facultyId)', academicYearId: '#(academicYearId)' }

    * def managerA = call read('classpath:com/example/uniactivity/karate/helpers/create-user.feature') { adminToken: '#(adminToken)', email: '#("karate-manager-" + suffix + "@example.test")', fullName: 'Karate Manager A', role: 'MANAGER', classId: '#(classA.id)' }
    * def managerALogin = call read('classpath:com/example/uniactivity/karate/helpers/login.feature') { username: '#(managerA.username)', password: '#(test.password)' }

    * def studentA = call read('classpath:com/example/uniactivity/karate/helpers/create-user.feature') { adminToken: '#(adminToken)', email: '#("karate-a-" + suffix + "@example.test")', fullName: 'Karate Student A', classId: '#(classA.id)' }
    * def studentB = call read('classpath:com/example/uniactivity/karate/helpers/create-user.feature') { adminToken: '#(adminToken)', email: '#("karate-b-" + suffix + "@example.test")', fullName: 'Karate Student B', classId: '#(classA.id)' }
    * def studentALogin = call read('classpath:com/example/uniactivity/karate/helpers/login.feature') { username: '#(studentA.username)', password: '#(test.password)' }

    * def now = java.time.LocalDateTime.now()
    * def openActivity = call read('classpath:com/example/uniactivity/karate/helpers/create-activity.feature') { adminToken: '#(adminToken)', name: '#("Karate Open " + suffix)', start: '#(now.plusDays(5).withNano(0).toString())', end: '#(now.plusDays(5).plusHours(2).withNano(0).toString())', deadline: '#(now.plusDays(4).withNano(0).toString())', status: 'OPEN', semesterId: '#(semesterId)' }
    * call read('classpath:com/example/uniactivity/karate/helpers/create-slot.feature') { adminToken: '#(adminToken)', activityId: '#(openActivity.id)', classId: '#(classA.id)', maxQuantity: 100 }

    * def liveActivity = call read('classpath:com/example/uniactivity/karate/helpers/create-activity.feature') { adminToken: '#(adminToken)', name: '#("Karate Live " + suffix)', start: '#(now.minusHours(1).withNano(0).toString())', end: '#(now.plusHours(2).withNano(0).toString())', deadline: '#(now.plusHours(1).withNano(0).toString())', status: 'OPEN', semesterId: '#(semesterId)', latitude: 10.762622, longitude: 106.660172, checkinRadius: 100 }
    * call read('classpath:com/example/uniactivity/karate/helpers/create-slot.feature') { adminToken: '#(adminToken)', activityId: '#(liveActivity.id)', classId: '#(classA.id)', maxQuantity: 100 }

    Given url baseUrl
    * configure headers = { Authorization: '#(adminAuth)' }
    And path '/admin/activities/api', liveActivity.id, 'score-options'
    And request { name: 'Tham gia', scoreCategory: '3.1', scoreValue: 5 }
    When method post
    Then status 200
    * def scoreOptionId = response.id

    * def fixture = ({ adminToken: adminToken, suffix: suffix, academicYearId: academicYearId, facultyId: facultyId, classAId: classA.id, classBId: classB.id, classAJoinCode: classA.joinCode, joinCode: classA.joinCode, semesterId: semesterId, studentA: studentA, studentB: studentB, studentAToken: studentALogin.accessToken, studentARefreshToken: studentALogin.refreshToken, managerAToken: managerALogin.accessToken, openActivityId: openActivity.id, liveActivityId: liveActivity.id, scoreOptionId: scoreOptionId })
