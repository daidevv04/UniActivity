Feature: Helper tạo tài khoản

  Scenario: Tạo tài khoản qua Admin API
    * def role = __arg.role || 'STUDENT'
    * def password = __arg.password || test.password
    * def classId = __arg.classId
    * def adminAuth = 'Bearer ' + __arg.adminToken
    Given url baseUrl
    * configure headers = { Authorization: '#(adminAuth)' }
    And path '/admin/users/api'
    And request { email: '#(email)', fullName: '#(fullName)', password: '#(password)', role: '#(role)', classId: '#(classId)' }
    When method post
    Then status 200
    * match response.id == '#number'
    * match response.username == '#string'
    * def id = response.id
    * def username = response.username
