Feature: Helper ảnh minh chứng vượt dung lượng

  Scenario: Phóng ảnh thật lên 6MB
    * def source = read('classpath:fixtures/evidence.png')
    * def bytes = java.util.Arrays.copyOf(source, 6291456)
    * def fileSpec = { value: '#(bytes)', filename: 'evidence-large.png', contentType: 'image/png' }

