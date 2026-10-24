Feature: Helper tạo lớp

  Scenario: Tạo lớp qua Admin API
    * def adminAuth = 'Bearer ' + __arg.adminToken
    Given url baseUrl
    * configure headers = { Authorization: '#(adminAuth)' }
    And path '/admin/classes/api'
    And request { code: '#(__arg.code)', name: '#(__arg.name)', facultyId: '#(__arg.facultyId)', academicYearId: '#(__arg.academicYearId)' }
    When method post
    Then status 200
    * match response.id == '#number'
    * match response.joinCode == '#string'
    * def id = response.id
    * def joinCode = response.joinCode
