Feature: Báo cáo (TC-50)

  Background:
    * url baseUrl

  Scenario: TC-50 Xuất Excel danh sách thành viên lớp
    * configure headers = { Authorization: '#("Bearer " + fixture.managerAToken)' }
    Given path '/manager/api/reports/members'
    When method get
    Then status 200
    * match responseHeaders['Content-Type'][0] contains 'spreadsheetml'
    * match responseHeaders['Content-Disposition'][0] contains 'attachment'
    * assert responseBytes.length > 0
