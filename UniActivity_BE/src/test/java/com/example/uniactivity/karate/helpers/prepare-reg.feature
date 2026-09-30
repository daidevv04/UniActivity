Feature: Tạo sinh viên + đăng ký hoạt động Karate

  Scenario: Chuẩn bị đăng ký
    * def name = __arg.name || 'student'
    * def student = call read('classpath:com/example/uniactivity/karate/helpers/create-student.feature') { adminToken: '#(fixture.adminToken)', email: '#("karate-" + name + "-" + config.test.suffix + "@example.test")', fullName: '#("Karate " + name)', classId: '#(fixture.classAId)' }
    * def login = call read('classpath:com/example/uniactivity/karate/helpers/login.feature') { username: '#(student.username)', password: '#(test.password)' }

    * def studentAuth = 'Bearer ' + login.accessToken
    Given url baseUrl
    * configure headers = { Authorization: '#(studentAuth)' }
    And path '/student/api/activities', fixture.liveActivityId, 'register'
    When method post
    Then status 200
    * print response

    Given url baseUrl
    And path '/student/api/my-registrations'
    When method get
    Then status 200
    * print response
    * def registration = karate.filter(response.registrations, function(x){ return x.activity.id == fixture.liveActivityId })[0]

    * def token = login.accessToken
    * def registrationId = registration.id