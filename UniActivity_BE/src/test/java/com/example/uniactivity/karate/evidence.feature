Feature: Student nộp minh chứng (TC-054 đến TC-055)

  Background:
    * url baseUrl
    * def image = Java.type('java.nio.file.Files').readAllBytes(Java.type('java.nio.file.Paths').get('C:/Users/DELL/Downloads/ChatGPT Image 00_31_33 28 thg 9, 2026.png'))
    * def fileSpec = { value: '#(image)', filename: 'evidence.png', contentType: 'image/png' }

  Scenario: TC-054 Nộp minh chứng
    * def prep = call read('helpers/prepare-reg.feature') { name: 'TC54' }
    * call read('helpers/manual-checkin.feature') { registrationId: '#(prep.registrationId)' }
    Given path '/student/api/activities', fixture.liveActivityId, 'evidence'
    * configure headers = { Authorization: '#("Bearer " + prep.token)' }
    And multipart file files = fileSpec
    And param scoreOptionId = fixture.scoreOptionId
    When method post
    Then status 200
    * print response

  Scenario: TC-055 Chặn quá 3 ảnh minh chứng
    * def prep = call read('helpers/prepare-reg.feature') { name: 'TC55' }
    * call read('helpers/manual-checkin.feature') { registrationId: '#(prep.registrationId)' }
    Given path '/student/api/activities', fixture.liveActivityId, 'evidence'
    * configure headers = { Authorization: '#("Bearer " + prep.token)' }
    And multipart file files = fileSpec
    And multipart file files = fileSpec
    And multipart file files = fileSpec
    And multipart file files = fileSpec
    And param scoreOptionId = fixture.scoreOptionId
    When method post
    Then status 400
    * print response
