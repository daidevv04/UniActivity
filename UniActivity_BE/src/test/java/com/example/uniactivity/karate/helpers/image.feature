Feature: Helper ảnh minh chứng

  Scenario: Đọc ảnh minh chứng thật trong fixtures
    * def bytes = read('classpath:fixtures/evidence.png')
    * def fileSpec = { value: '#(bytes)', filename: 'evidence.png', contentType: 'image/png' }


