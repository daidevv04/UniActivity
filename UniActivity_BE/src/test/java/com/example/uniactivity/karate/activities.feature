Feature: Hoạt động và slot (TC-25 đến TC-30)

  Background:
    * url baseUrl
    * configure headers = { Authorization: '#("Bearer " + fixture.adminToken)' }

  Scenario: TC-25 Tạo hoạt động hợp lệ
    * def now = java.time.LocalDateTime.now()
    Given path '/admin/activities/api'
    And request { name: '#("Karate TC25 " + test.suffix)', description: 'Karate activity', location: 'Campus', startTime: '#(now.plusDays(5).withNano(0).toString())', endTime: '#(now.plusDays(5).plusHours(2).withNano(0).toString())', registrationDeadline: '#(now.plusDays(4).withNano(0).toString())', scope: 'SCHOOL', status: 'OPEN', semesterId: '#(fixture.semesterId)' }
    When method post
    Then status 200
    * match response.id == '#number'
    * match response.name == 'Karate TC25 ' + test.suffix
    * match response.status == 'OPEN'

  Scenario: TC-26 Danh sách hoạt động phân trang
    Given path '/admin/activities/api'
    And param page = 0
    And param size = 20
    When method get
    Then status 200
    * match response.content == '#array'
    * match response.totalElements == '#number'
    * match response.size == 20

  Scenario: TC-27 Validation tên hoạt động rỗng
    * def now = java.time.LocalDateTime.now()
    Given path '/admin/activities/api'
    And request { name: '', description: 'Invalid', location: 'Campus', startTime: '#(now.plusDays(5).withNano(0).toString())', endTime: '#(now.plusDays(5).plusHours(2).withNano(0).toString())', registrationDeadline: '#(now.plusDays(4).withNano(0).toString())', scope: 'SCHOOL', status: 'OPEN', semesterId: '#(fixture.semesterId)' }
    When method post
    Then status 400
    * match response.errors.name == 'Tên hoạt động không được để trống'

  Scenario: TC-28 Chặn thời gian kết thúc trước thời gian bắt đầu
    * def now = java.time.LocalDateTime.now()
    Given path '/admin/activities/api'
    And request { name: '#("Karate TC28 " + test.suffix)', description: 'Invalid time', location: 'Campus', startTime: '#(now.plusDays(2).withNano(0).toString())', endTime: '#(now.plusDays(1).withNano(0).toString())', registrationDeadline: '#(now.plusDays(1).withNano(0).toString())', scope: 'SCHOOL', status: 'OPEN', semesterId: '#(fixture.semesterId)' }
    When method post
    Then status 400
    * match response.message == '#string'

  Scenario: TC-29 Validation số lượng slot
    Given path '/admin/activities/api', fixture.openActivityId, 'slots'
    And request { classId: '#(fixture.classAId)', maxQuantity: 0 }
    When method post
    Then status 400
    * match response.errors.maxQuantity == 'Số lượng tối đa phải >= 1'

  Scenario: TC-30 Chặn slot trùng lớp trong cùng hoạt động
    * def now = java.time.LocalDateTime.now()
    * def activity = call read('helpers/create-activity.feature') { adminToken: '#(fixture.adminToken)', name: '#("Karate TC30 " + test.suffix)', start: '#(now.plusDays(5).withNano(0).toString())', end: '#(now.plusDays(5).plusHours(2).withNano(0).toString())', deadline: '#(now.plusDays(4).withNano(0).toString())', status: 'OPEN', semesterId: '#(fixture.semesterId)' }
    * call read('helpers/create-slot.feature') { adminToken: '#(fixture.adminToken)', activityId: '#(activity.id)', classId: '#(fixture.classAId)', maxQuantity: 50 }
    Given path '/admin/activities/api', activity.id, 'slots'
    And request { classId: '#(fixture.classAId)', maxQuantity: 60 }
    When method post
    Then status 409
    * match response.message == '#string'
