Feature: Tạo Student Karate

  Scenario: Tạo Student
    Given url baseUrl
    And path '/admin/users/api'
    And header Authorization = 'Bearer ' + __arg.adminToken
    And request { email: '#(email)', fullName: '#(fullName)', password: '#(test.password)', role: 'STUDENT', classId: '#(classId)' }
    When method post
    Then status 200
    * def id = response.id
    * def username = response.username
    * def email = response.email
