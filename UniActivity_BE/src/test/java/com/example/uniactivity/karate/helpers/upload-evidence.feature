Feature: Nộp 1 ảnh minh chứng Karate

  Scenario: Nộp minh chứng
    * def image = Java.type('java.nio.file.Files').readAllBytes(Java.type('java.nio.file.Paths').get('C:/Users/DELL/Downloads/ChatGPT Image 00_31_33 28 thg 9, 2026.png'))
    * def fileSpec = { value: '#(image)', filename: 'evidence.png', contentType: 'image/png' }
    * def studentAuth = 'Bearer ' + __arg.token
    Given url baseUrl
    * configure headers = { Authorization: '#(studentAuth)' }
    And path '/student/api/activities', fixture.liveActivityId, 'evidence'
    And param scoreOptionId = fixture.scoreOptionId
    And multipart file files = fileSpec
    When method post
    Then status 200