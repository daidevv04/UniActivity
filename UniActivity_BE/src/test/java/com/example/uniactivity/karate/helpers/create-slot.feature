Feature: Helper tạo slot

  Scenario: Tạo slot cho lớp
    * def adminAuth = 'Bearer ' + __arg.adminToken
    Given url baseUrl
    * configure headers = { Authorization: '#(adminAuth)' }
    And path '/admin/activities/api', __arg.activityId, 'slots'
    And request { classId: '#(__arg.classId)', maxQuantity: '#(__arg.maxQuantity)' }
    When method post
    Then status 200
    * match response.id == '#number'
    * def id = response.id
    * def currentQuantity = response.currentQuantity
