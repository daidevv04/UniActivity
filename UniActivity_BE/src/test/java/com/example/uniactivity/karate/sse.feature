Feature: Thông báo và SSE (TC-49)

  Background:
    * url baseUrl

  Scenario: TC-49 Cấp ticket SSE, kiểm tra dịch vụ và đếm thông báo chưa đọc
    * configure headers = { Authorization: '#("Bearer " + fixture.studentAToken)' }
    Given path '/sse/ticket'
    When method post
    Then status 200
    * match response.ticket == '#string'
    * match response.expiresIn == 60
    Given path '/sse/status'
    When method get
    Then status 200
    * match response contains 'SSE Service Active'
    Given path '/student/api/notifications/unread-count'
    * configure headers = { Authorization: '#("Bearer " + fixture.studentAToken)' }
    When method get
    Then status 200
    * match response.count == '#number'
    Given path '/student/api/notifications'
    And param page = 0
    And param size = 20
    When method get
    Then status 200
    * match response.notifications == '#array'
    * match response.totalElements == '#number'
    * match response.hasMore == '#boolean'
