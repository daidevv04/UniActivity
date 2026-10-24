Feature: Danh mục, lớp và mã tham gia (TC-10 đến TC-18)

  Background:
    * url baseUrl
    * configure headers = { Authorization: '#("Bearer " + fixture.adminToken)' }

  Scenario: TC-10 Tạo năm học hợp lệ
    * def code = 'KARATE-Y10-' + test.suffix
    Given path '/admin/academic-years/api'
    And request { code: '#(code)', startYear: 2026, endYear: 2027, status: 'ACTIVE' }
    When method post
    Then status 200
    * match response.id == '#number'
    * match response.code == code
    * match response.startYear == 2026
    * match response.endYear == 2027
    * match response.status == 'ACTIVE'
    * def yearId = response.id

  Scenario: TC-11 Danh sách, chi tiết và năm học không tồn tại
    * def code = 'KARATE-Y11-' + test.suffix
    Given path '/admin/academic-years/api'
    And request { code: '#(code)', startYear: 2026, endYear: 2027, status: 'ACTIVE' }
    When method post
    Then status 200
    * def yearId = response.id
    Given path '/admin/academic-years/api'
    When method get
    Then status 200
    * match response == '#array'
    * assert karate.filter(response, function(x){ return x.id == yearId }).length > 0
    Given path '/admin/academic-years/api', yearId
    When method get
    Then status 200
    * match response.id == yearId
    * match response.code == code
    Given path '/admin/academic-years/api/999999999'
    When method get
    Then status 404
    * match response.status == 404
    * match response.message == '#string'

  Scenario: TC-12 Cập nhật năm học
    * def code = 'KARATE-Y12-' + test.suffix
    Given path '/admin/academic-years/api'
    And request { code: '#(code)', startYear: 2026, endYear: 2027, status: 'ACTIVE' }
    When method post
    Then status 200
    * def yearId = response.id
    Given path '/admin/academic-years/api', yearId
    And request { code: '#(code + "-UPD")', startYear: 2026, endYear: 2028, status: 'ACTIVE' }
    When method put
    Then status 200
    Given path '/admin/academic-years/api', yearId
    When method get
    Then status 200
    * match response.endYear == 2028
    * match response.code == code + '-UPD'

  Scenario: TC-13 Chặn trùng mã năm học
    * def code = 'KARATE-Y13-' + test.suffix
    Given path '/admin/academic-years/api'
    And request { code: '#(code)', startYear: 2026, endYear: 2027, status: 'ACTIVE' }
    When method post
    Then status 200
    Given path '/admin/academic-years/api'
    And request { code: '#(code)', startYear: 2026, endYear: 2027, status: 'ACTIVE' }
    When method post
    Then status 409
    * match response.message == '#string'

  Scenario: TC-14 Tạo khoa, tạo học kỳ và đặt học kỳ hiện tại
    Given path '/admin/faculties/api'
    And request { code: '#("KARATE-F14-" + test.suffix)', name: 'Khoa Karate TC14', status: 'ACTIVE' }
    When method post
    Then status 200
    * match response.id == '#number'
    Given path '/admin/semesters/api'
    And request { name: '#("Karate Semester TC14 " + test.suffix)', startDate: '2027-01-01', endDate: '2027-05-31', isCurrent: false }
    When method post
    Then status 200
    * def semesterId = response.id
    * match response.name == 'Karate Semester TC14 ' + test.suffix
    Given path '/admin/semesters/api', semesterId, 'set-current'
    When method post
    Then status 200
    Given path '/admin/semesters/api'
    When method get
    Then status 200
    * def currents = karate.filter(response, function(x){ return x.isCurrent == true })
    * assert karate.sizeOf(currents) == 1
    * match currents[0].id == semesterId

  Scenario: TC-15 Tạo lớp sinh mã tham gia
    * def created = call read('helpers/create-class.feature') { adminToken: '#(fixture.adminToken)', code: '#("KARATE-C15-" + test.suffix)', name: 'Lớp Karate TC15', facultyId: '#(fixture.facultyId)', academicYearId: '#(fixture.academicYearId)' }
    * match created.joinCode == '#string'
    * assert created.joinCode.length() == 6

  Scenario: TC-16 Danh sách lớp
    * def code = 'KARATE-C16-' + test.suffix
    * call read('helpers/create-class.feature') { adminToken: '#(fixture.adminToken)', code: '#(code)', name: 'Lớp Karate TC16', facultyId: '#(fixture.facultyId)', academicYearId: '#(fixture.academicYearId)' }
    Given path '/admin/classes/api'
    When method get
    Then status 200
    * match response == '#array'
    * def target = karate.filter(response, function(x){ return x.code == code })[0]
    * assert target != null
    * match target.joinCode == '#string'

  Scenario: TC-17 Sinh lại mã tham gia lớp
    * def created = call read('helpers/create-class.feature') { adminToken: '#(fixture.adminToken)', code: '#("KARATE-C17-" + test.suffix)', name: 'Lớp Karate TC17', facultyId: '#(fixture.facultyId)', academicYearId: '#(fixture.academicYearId)' }
    Given path '/admin/classes/api', created.id, 'regenerate-code'
    When method post
    Then status 200
    * match response.joinCode == '#string'
    * assert response.joinCode != created.joinCode

  Scenario: TC-18 Chặn trùng mã lớp
    * def code = 'KARATE-C18-' + test.suffix
    * call read('helpers/create-class.feature') { adminToken: '#(fixture.adminToken)', code: '#(code)', name: 'Lớp Karate TC18', facultyId: '#(fixture.facultyId)', academicYearId: '#(fixture.academicYearId)' }
    Given path '/admin/classes/api'
    And request { code: '#(code)', name: 'Lớp trùng', facultyId: '#(fixture.facultyId)', academicYearId: '#(fixture.academicYearId)' }
    When method post
    Then status 409
    * match response.message == '#string'
