Feature: Tạo Student Karate

  Scenario: Tạo Student
    * def adminAuth = 'Bearer ' + __arg.adminToken
    Given url baseUrl
    * configure headers = { Authorization: '#(adminAuth)' }
    And path '/admin/users/api'
    And request { email: '#(email)', fullName: '#(fullName)', password: '#(test.password)', role: 'STUDENT', classId: '#(classId)' }
    When method post
    Then status 200
    * print response
    * def id = response.id
    * def username = response.username
    * def email = response.email
