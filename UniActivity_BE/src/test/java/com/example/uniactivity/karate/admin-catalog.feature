Feature: Quản lý năm học

  Background:
    * url baseUrl
    * configure headers = { Authorization: '#("Bearer " + fixture.adminToken)' }

  Scenario: TC-009 Lấy danh sách năm học
    Given path '/admin/academic-years/api'
    When method get
    Then status 200
    And match response == '#[]'
    And match each response contains { id: '#number', code: '#string' }

  Scenario: TC-010 Tạo năm học
    * def code = 'KARATE-' + config.test.suffix + '-CREATE'
    Given path '/admin/academic-years/api'
    And request { code: '#(code)', startYear: 2026, endYear: 2027, status: 'ACTIVE' }
    When method post
    Then status 200
    And match response contains { id: '#number', code: '#(code)' }

  Scenario: TC-011 Xem năm học vừa tạo
    * def code = 'KARATE-' + config.test.suffix + '-DETAIL'
    Given path '/admin/academic-years/api'
    And request { code: '#(code)', startYear: 2026, endYear: 2027, status: 'ACTIVE' }
    When method post
    Then status 200
    * def yearId = response.id
    Given path '/admin/academic-years/api', yearId
    When method get
    Then status 200
    And match response contains { id: '#(yearId)', code: '#(code)' }

  Scenario: TC-012 Năm học không tồn tại
    Given path '/admin/academic-years/api/999999999'
    When method get
    Then status 404
    And match response.status == 404
    And match response.message == '#string'
