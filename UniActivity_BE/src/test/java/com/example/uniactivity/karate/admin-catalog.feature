Feature: Admin danh mục (TC-009 đến TC-017, TC-019 đến TC-025)

  Background:
    * url baseUrl
    * configure headers = { Authorization: '#("Bearer " + fixture.adminToken)' }

  Scenario: TC-009 Danh sách năm học
    Given path '/admin/academic-years/api'
    When method get
    Then status 200
    * print response

  Scenario: TC-010 Tạo năm học
    Given path '/admin/academic-years/api'
    And request { code: '#("KARATE-TC010-" + config.test.suffix)', startYear: 2026, endYear: 2027, status: 'ACTIVE' }
    When method post
    Then status 200
    * print response

  Scenario: TC-011 Xem năm học
    Given path '/admin/academic-years/api'
    And request { code: '#("KARATE-TC011-" + config.test.suffix)', startYear: 2026, endYear: 2027, status: 'ACTIVE' }
    When method post
    Then status 200
    * print response
    * def yearId = response.id
    Given path '/admin/academic-years/api', yearId
    When method get
    Then status 200
    * print response

  Scenario: TC-012 Cập nhật năm học
    Given path '/admin/academic-years/api'
    And request { code: '#("KARATE-TC012-" + config.test.suffix)', startYear: 2026, endYear: 2027, status: 'ACTIVE' }
    When method post
    Then status 200
    * print response
    * def yearId = response.id
    Given path '/admin/academic-years/api', yearId
    And request { code: '#("KARATE-UPD-" + config.test.suffix)', startYear: 2026, endYear: 2028, status: 'ACTIVE' }
    When method put
    Then status 200
    * print response
    Given path '/admin/academic-years/api', yearId
    When method get
    Then status 200
    * print response

  Scenario: TC-013 Năm học không tồn tại
    Given path '/admin/academic-years/api/999999999'
    When method get
    Then status 404
    * print response

  Scenario: TC-015 Danh sách học kỳ
    Given path '/admin/semesters/api'
    When method get
    Then status 200
    * print response

  Scenario: TC-016 Tạo học kỳ
    Given path '/admin/semesters/api'
    And request { name: '#("Học kỳ Karate " + config.test.suffix)', startDate: '2027-01-01', endDate: '2027-05-31', isCurrent: false }
    When method post
    Then status 200
    * print response

  Scenario: TC-017 Đặt học kỳ hiện tại
    Given path '/admin/semesters/api'
    And request { name: '#("Học kỳ current " + config.test.suffix)', startDate: '2027-06-01', endDate: '2027-12-31', isCurrent: false }
    When method post
    Then status 200
    * print response
    * def semesterId = response.id
    Given path '/admin/semesters/api', semesterId, 'set-current'
    When method post
    Then status 200
    * print response
    Given path '/admin/semesters/api'
    When method get
    Then status 200
    * print response
    * def current = karate.filter(response, function(x){ return x.id == semesterId })[0]

  Scenario: TC-019 Danh sách khoa
    Given path '/admin/faculties/api'
    When method get
    Then status 200
    * print response

  Scenario: TC-020 Tạo khoa
    Given path '/admin/faculties/api'
    And request { code: '#("KARATE-TC020-" + config.test.suffix)', name: '#("Khoa Karate " + config.test.suffix)', status: 'ACTIVE' }
    When method post
    Then status 200
    * print response

  Scenario: TC-021 Cập nhật khoa
    Given path '/admin/faculties/api'
    And request { code: '#("KARATE-TC021-" + config.test.suffix)', name: 'Khoa cũ', status: 'ACTIVE' }
    When method post
    Then status 200
    * print response
    * def facultyId = response.id
    Given path '/admin/faculties/api', facultyId
    And request { code: '#("KARATE-UPD-" + config.test.suffix)', name: 'Khoa Karate Updated', status: 'ACTIVE' }
    When method put
    Then status 200
    * print response
    Given path '/admin/faculties/api', facultyId
    When method get
    Then status 200
    * print response

  Scenario: TC-023 Danh sách lớp
    Given path '/admin/classes/api'
    When method get
    Then status 200
    * print response

  Scenario: TC-024 Tạo lớp
    Given path '/admin/classes/api'
    And request { code: '#("KARATE-TC024-" + config.test.suffix)', name: '#("Lớp Karate " + config.test.suffix)', facultyId: '#(fixture.facultyId)', academicYearId: '#(fixture.academicYearId)' }
    When method post
    Then status 200
    * print response

  Scenario: TC-025 Sinh lại mã join lớp
    Given path '/admin/classes/api'
    And request { code: '#("KARATE-TC025-" + config.test.suffix)', name: 'Lớp Karate TC25', facultyId: '#(fixture.facultyId)', academicYearId: '#(fixture.academicYearId)' }
    When method post
    Then status 200
    * print response
    * def classId = response.id
    * def previousCode = response.joinCode
    Given path '/admin/classes/api', classId, 'regenerate-code'
    When method post
    Then status 200
    * print response

