Feature: Thành viên lớp (TC-47 đến TC-48)

  Background:
    * url baseUrl

  Scenario: TC-47 Sinh viên xin vào lớp và quản lý duyệt
    * def student = call read('helpers/create-user.feature') { adminToken: '#(fixture.adminToken)', email: '#("karate-j47-" + test.suffix + "@example.test")', fullName: 'Karate Join 47', classId: null }
    * def login = call read('helpers/login.feature') { username: '#(student.username)', password: '#(test.password)' }
    Given path '/student/api/join-class'
    * configure headers = { Authorization: '#("Bearer " + login.accessToken)' }
    And request { joinCode: '#(fixture.joinCode)' }
    When method post
    Then status 200
    * match response.className == '#string'
    Given path '/manager/api/join-requests'
    * configure headers = { Authorization: '#("Bearer " + fixture.managerAToken)' }
    When method get
    Then status 200
    * def pending = karate.filter(response.requests, function(x){ return x.userId == student.id })[0]
    * assert pending != null
    Given path '/manager/api/join-requests', pending.id, 'approve'
    When method post
    Then status 200
    * match response.message == 'Đã duyệt yêu cầu'
    Given path '/student/api/my-class'
    * configure headers = { Authorization: '#("Bearer " + login.accessToken)' }
    When method get
    Then status 200
    * match response.hasClass == true
    * match response.studentClass.id == fixture.classAId

  Scenario: TC-48 Xóa thành viên khỏi lớp
    * def student = call read('helpers/create-user.feature') { adminToken: '#(fixture.adminToken)', email: '#("karate-j48-" + test.suffix + "@example.test")', fullName: 'Karate Member 48', classId: '#(fixture.classAId)' }
    * def login = call read('helpers/login.feature') { username: '#(student.username)', password: '#(test.password)' }
    Given path '/manager/api/members', student.id
    * configure headers = { Authorization: '#("Bearer " + fixture.managerAToken)' }
    When method delete
    Then status 200
    * match response.message == 'Đã xóa khỏi lớp'
    Given path '/student/api/my-class'
    * configure headers = { Authorization: '#("Bearer " + login.accessToken)' }
    When method get
    Then status 200
    * match response.hasClass == false
