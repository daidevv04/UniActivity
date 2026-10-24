Feature: Minh chứng và điểm rèn luyện (TC-40 đến TC-46)

  Background:
    * url baseUrl

  Scenario: TC-40 Nộp 1 ảnh minh chứng hợp lệ
    * def student = call read('helpers/create-user.feature') { adminToken: '#(fixture.adminToken)', email: '#("karate-e40-" + test.suffix + "@example.test")', fullName: 'Karate Evidence 40', classId: '#(fixture.classAId)' }
    * def login = call read('helpers/login.feature') { username: '#(student.username)', password: '#(test.password)' }
    * call read('helpers/register.feature') { token: '#(login.accessToken)', activityId: '#(fixture.liveActivityId)' }
    * def current = call read('helpers/my-registration.feature') { token: '#(login.accessToken)', activityId: '#(fixture.liveActivityId)' }
    * call read('helpers/manual-checkin.feature') { managerToken: '#(fixture.managerAToken)', registrationId: '#(current.registrationId)' }
    * def image = call read('helpers/image.feature')
    * def fileSpec = image.fileSpec
    Given path '/student/api/activities', fixture.liveActivityId, 'evidence'
    * configure headers = { Authorization: '#("Bearer " + login.accessToken)' }
    And param scoreOptionId = fixture.scoreOptionId
    And multipart file files = fileSpec
    When method post
    Then status 200
    * match response.message contains 'Đã nộp 1 ảnh minh chứng'
    * def after = call read('helpers/my-registration.feature') { token: '#(login.accessToken)', activityId: '#(fixture.liveActivityId)' }
    * match after.registration.evidenceUrl == '#string'
    * match after.registration.isApproved == null
    * match after.registration.scoreOption.id == fixture.scoreOptionId

  Scenario: TC-41 Chặn nộp quá 3 ảnh
    * def student = call read('helpers/create-user.feature') { adminToken: '#(fixture.adminToken)', email: '#("karate-e41-" + test.suffix + "@example.test")', fullName: 'Karate Evidence 41', classId: '#(fixture.classAId)' }
    * def login = call read('helpers/login.feature') { username: '#(student.username)', password: '#(test.password)' }
    * call read('helpers/register.feature') { token: '#(login.accessToken)', activityId: '#(fixture.liveActivityId)' }
    * def current = call read('helpers/my-registration.feature') { token: '#(login.accessToken)', activityId: '#(fixture.liveActivityId)' }
    * call read('helpers/manual-checkin.feature') { managerToken: '#(fixture.managerAToken)', registrationId: '#(current.registrationId)' }
    * def image = call read('helpers/image.feature')
    Given path '/student/api/activities', fixture.liveActivityId, 'evidence'
    * configure headers = { Authorization: '#("Bearer " + login.accessToken)' }
    And param scoreOptionId = fixture.scoreOptionId
    And multipart file files = image.fileSpec
    And multipart file files = image.fileSpec
    And multipart file files = image.fileSpec
    And multipart file files = image.fileSpec
    When method post
    Then status 400
    * match response.message == 'Tối đa 3 ảnh'
    * def after = call read('helpers/my-registration.feature') { token: '#(login.accessToken)', activityId: '#(fixture.liveActivityId)' }
    * match after.registration.evidenceUrl == null

  Scenario: TC-42 Duyệt minh chứng, cộng điểm đúng một lần
    * def student = call read('helpers/create-user.feature') { adminToken: '#(fixture.adminToken)', email: '#("karate-e42-" + test.suffix + "@example.test")', fullName: 'Karate Evidence 42', classId: '#(fixture.classAId)' }
    * def login = call read('helpers/login.feature') { username: '#(student.username)', password: '#(test.password)' }
    * call read('helpers/register.feature') { token: '#(login.accessToken)', activityId: '#(fixture.liveActivityId)' }
    * def current = call read('helpers/my-registration.feature') { token: '#(login.accessToken)', activityId: '#(fixture.liveActivityId)' }
    * call read('helpers/manual-checkin.feature') { managerToken: '#(fixture.managerAToken)', registrationId: '#(current.registrationId)' }
    * def image = call read('helpers/image.feature')
    * def fileSpec = image.fileSpec
    Given path '/student/api/activities', fixture.liveActivityId, 'evidence'
    * configure headers = { Authorization: '#("Bearer " + login.accessToken)' }
    And param scoreOptionId = fixture.scoreOptionId
    And multipart file files = fileSpec
    When method post
    Then status 200
    Given path '/manager/api/registrations', current.registrationId, 'approve'
    * configure headers = { Authorization: '#("Bearer " + fixture.managerAToken)' }
    When method post
    Then status 200
    * match response.message contains 'Đã duyệt và cộng'
    Given path '/manager/api/activities', fixture.liveActivityId, 'registrations'
    And param page = 0
    And param size = 100
    When method get
    Then status 200
    * def row = karate.filter(response.content, function(x){ return x.id == current.registrationId })[0]
    * match row.isApproved == true
    Given path '/student/api/my-scores'
    * configure headers = { Authorization: '#("Bearer " + login.accessToken)' }
    When method get
    Then status 200
    * match response.totalScore == 5
    Given path '/manager/api/registrations', current.registrationId, 'approve'
    * configure headers = { Authorization: '#("Bearer " + fixture.managerAToken)' }
    When method post
    Then status 409
    * match response.message == 'Minh chứng này đã được xử lý'

  Scenario: TC-43 Chặn ảnh vượt 5MB bằng lỗi 4xx
    * def student = call read('helpers/create-user.feature') { adminToken: '#(fixture.adminToken)', email: '#("karate-e43-" + test.suffix + "@example.test")', fullName: 'Karate Evidence 43', classId: '#(fixture.classAId)' }
    * def login = call read('helpers/login.feature') { username: '#(student.username)', password: '#(test.password)' }
    * call read('helpers/register.feature') { token: '#(login.accessToken)', activityId: '#(fixture.liveActivityId)' }
    * def current = call read('helpers/my-registration.feature') { token: '#(login.accessToken)', activityId: '#(fixture.liveActivityId)' }
    * call read('helpers/manual-checkin.feature') { managerToken: '#(fixture.managerAToken)', registrationId: '#(current.registrationId)' }
    * def big = call read('helpers/big-image.feature')
    * def fileSpec = big.fileSpec
    Given path '/student/api/activities', fixture.liveActivityId, 'evidence'
    * configure headers = { Authorization: '#("Bearer " + login.accessToken)' }
    And param scoreOptionId = fixture.scoreOptionId
    And multipart file files = fileSpec
    When method post
    * assert responseStatus >= 400 && responseStatus < 500

  Scenario: TC-44 Gửi yêu cầu điểm hợp lệ
    * def student = call read('helpers/create-user.feature') { adminToken: '#(fixture.adminToken)', email: '#("karate-p44-" + test.suffix + "@example.test")', fullName: 'Karate Point 44', classId: '#(fixture.classAId)' }
    * def login = call read('helpers/login.feature') { username: '#(student.username)', password: '#(test.password)' }
    Given path '/student/api/point-requests'
    * configure headers = { Authorization: '#("Bearer " + login.accessToken)' }
    And request { criteriaCode: '1.3', claimedScore: 5, description: 'Karate point request 44', evidenceImages: ['/uploads/evidence/karate.png'] }
    When method post
    Then status 200
    * match response.id == '#number'
    * match response.message contains 'Đã gửi yêu cầu điểm mục 1.3'
    Given path '/manager/api/point-requests'
    * configure headers = { Authorization: '#("Bearer " + fixture.managerAToken)' }
    When method get
    Then status 200
    * def row = karate.filter(response, function(x){ return x.studentId == student.id })[0]
    * assert row != null
    * match row.status == 'PENDING'

  Scenario: TC-45 Chặn yêu cầu điểm thiếu minh chứng
    * def student = call read('helpers/create-user.feature') { adminToken: '#(fixture.adminToken)', email: '#("karate-p45-" + test.suffix + "@example.test")', fullName: 'Karate Point 45', classId: '#(fixture.classAId)' }
    * def login = call read('helpers/login.feature') { username: '#(student.username)', password: '#(test.password)' }
    Given path '/student/api/point-requests'
    * configure headers = { Authorization: '#("Bearer " + login.accessToken)' }
    And request { criteriaCode: '1.3', claimedScore: 5, description: 'Thiếu minh chứng' }
    When method post
    Then status 400
    * match response.message == 'Mục này yêu cầu minh chứng (ảnh)'

  Scenario: TC-46 Manager duyệt yêu cầu điểm
    * def student = call read('helpers/create-user.feature') { adminToken: '#(fixture.adminToken)', email: '#("karate-p46-" + test.suffix + "@example.test")', fullName: 'Karate Point 46', classId: '#(fixture.classAId)' }
    * def login = call read('helpers/login.feature') { username: '#(student.username)', password: '#(test.password)' }
    Given path '/student/api/point-requests'
    * configure headers = { Authorization: '#("Bearer " + login.accessToken)' }
    And request { criteriaCode: '1.3', claimedScore: 5, description: 'Karate point request 46', evidenceImages: ['/uploads/evidence/karate.png'] }
    When method post
    Then status 200
    * def requestId = response.id
    Given path '/manager/api/point-requests', requestId, 'approve'
    * configure headers = { Authorization: '#("Bearer " + fixture.managerAToken)' }
    When method post
    Then status 200
    * match response.message == 'Đã duyệt yêu cầu điểm'
    Given path '/student/api/my-scores'
    * configure headers = { Authorization: '#("Bearer " + login.accessToken)' }
    When method get
    Then status 200
    * match response.totalScore == 5

