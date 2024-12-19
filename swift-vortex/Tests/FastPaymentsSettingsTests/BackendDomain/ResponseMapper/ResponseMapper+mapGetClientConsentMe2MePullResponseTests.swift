//
//  ResponseMapper+mapGetClientConsentMe2MePullResponseTests.swift
//
//
//  Created by Igor Malyarov on 28.12.2023.
//

import FastPaymentsSettings
import RemoteServices
import XCTest

final class ResponseMapper_mapGetClientConsentMe2MePullResponseTests: XCTestCase {
    
    func test_map_shouldDeliverInvalidErrorOnInvalidData() throws {
        
        let invalidData = anyData()
        
        let result = map(invalidData)
        
        assert(result, equals: .failure(.invalid(
            statusCode: 200,
            data: invalidData
        )))
    }
    
    func test_map_shouldDeliverServerErrorOnDataWithServerErrorWithOkHTTPURLResponseStatusCode() throws {
        
        let okResponse = anyHTTPURLResponse(statusCode: 200)
        let result = map(jsonWithServerError(), okResponse)
        
        assert(result, equals: .failure(.server(
            statusCode: 102,
            errorMessage: "Возникла техническая ошибка"
        )))
    }
    
    func test_map_shouldDeliverServerErrorOnDataWithServerErrorWithNonOkHTTPURLResponseStatusCode() throws {
        
        let nonOkResponse = anyHTTPURLResponse(statusCode: 400)
        let result = map(jsonWithServerError(), nonOkResponse)
        
        assert(result, equals: .failure(.server(
            statusCode: 102,
            errorMessage: "Возникла техническая ошибка"
        )))
    }

    func test_map_shouldDeliverInvalidOnNonOkHTTPURLResponseStatusCode() throws {
        
        let statusCode = 400
        let data = anyData()
        let nonOkResponse = anyHTTPURLResponse(statusCode: statusCode)
        let result = map(data, nonOkResponse)
        
        assert(result, equals: .failure(.invalid(
            statusCode: statusCode,
            data: data
        )))
    }
    
    func test_map_shouldDeliverInvalidOnNonOkHTTPURLResponseStatusCodeWithBadData() throws {
        
        let badData = Data(jsonStringWithBadData.utf8)
        let statusCode = 400
        let nonOkResponse = anyHTTPURLResponse(statusCode: statusCode)
        let result = map(badData, nonOkResponse)
        
        assert(result, equals: .failure(.invalid(
            statusCode: statusCode,
            data: badData
        )))
    }
    
    func test_map_shouldDeliverEmptyResponseOnOkHTTPURLResponseStatusCodeWithValidData_b1() throws {
        
        let validData = Data(jsonStringWithEmptyConsentList_b1.utf8)
        let result = map(validData)
        
        assert(result, equals: .success([]))
    }
    
    func test_map_shouldDeliverResponseOnOkHTTPURLResponseStatusCodeWithValidData_b2() throws {
        
        let validData = Data(jsonString_b2.utf8)
        let result = map(validData)
        
        assert(result, equals: .success(.b2))
    }
    
    // MARK: - Helpers
    
    private func map(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse = anyHTTPURLResponse()
    ) -> ResponseMapper.MappingResult<[ConsentMe2MePull]> {
        
        ResponseMapper.mapGetClientConsentMe2MePullResponse(data, httpURLResponse)
    }
}

private extension Array where Element == ConsentMe2MePull {
    
    static let b2: Self = [
        .b2_01,
        .b2_02,
        .b2_03,
        .b2_04,
        .b2_05,
        .b2_06,
        .b2_07,
    ]
}

private extension ConsentMe2MePull {
    
    static let b2_01: Self = .init(
        consentID: 774,
        bankID: "100000000095",
        beginDate: "15.05.2023 14:46:15",
        endDate: "01.01.3000 00:00:00",
        active: true,
        oneTimeConsent: false
    )
    
    static let b2_02: Self = .init(
        consentID: 775,
        bankID: "100000000108",
        beginDate: "15.05.2023 14:46:15",
        endDate: "01.01.3000 00:00:00",
        active: true,
        oneTimeConsent: false
    )
    
    static let b2_03: Self = .init(
        consentID: 778,
        bankID: "100000000127",
        beginDate: "15.05.2023 14:46:32",
        endDate: "01.01.3000 00:00:00",
        active: true,
        oneTimeConsent: false
    )
    
    static let b2_04: Self = .init(
        consentID: 779,
        bankID: "100000000031",
        beginDate: "15.05.2023 14:46:32",
        endDate: "01.01.3000 00:00:00",
        active: true,
        oneTimeConsent: false
    )
    
    static let b2_05: Self = .init(
        consentID: 765,
        bankID: "100000000008",
        beginDate: "15.05.2023 14:45:22",
        endDate: "01.01.3000 00:00:00",
        active: true,
        oneTimeConsent: false
    )
    
    static let b2_06: Self = .init(
        consentID: 769,
        bankID: "100000000004",
        beginDate: "15.05.2023 14:45:41",
        endDate: "01.01.3000 00:00:00",
        active: true,
        oneTimeConsent: false
    )
    
    static let b2_07: Self = .init(
        consentID: 771,
        bankID: "100000000007",
        beginDate: "15.05.2023 14:45:41",
        endDate: "01.01.3000 00:00:00",
        active: true,
        oneTimeConsent: false
    )
}

private let jsonStringWithEmptyConsentList_b1 = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": {
        "consentList": []
    }
}
"""

private let jsonString_b2 = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "consentList": [
      {
        "consentId": 774,
        "bankId": "100000000095",
        "beginDate": "15.05.2023 14:46:15",
        "endDate": "01.01.3000 00:00:00",
        "active": true,
        "oneTimeConsent": false
      },
      {
        "consentId": 775,
        "bankId": "100000000108",
        "beginDate": "15.05.2023 14:46:15",
        "endDate": "01.01.3000 00:00:00",
        "active": true,
        "oneTimeConsent": false
      },
      {
        "consentId": 778,
        "bankId": "100000000127",
        "beginDate": "15.05.2023 14:46:32",
        "endDate": "01.01.3000 00:00:00",
        "active": true,
        "oneTimeConsent": false
      },
      {
        "consentId": 779,
        "bankId": "100000000031",
        "beginDate": "15.05.2023 14:46:32",
        "endDate": "01.01.3000 00:00:00",
        "active": true,
        "oneTimeConsent": false
      },
      {
        "consentId": 765,
        "bankId": "100000000008",
        "beginDate": "15.05.2023 14:45:22",
        "endDate": "01.01.3000 00:00:00",
        "active": true,
        "oneTimeConsent": false
      },
      {
        "consentId": 769,
        "bankId": "100000000004",
        "beginDate": "15.05.2023 14:45:41",
        "endDate": "01.01.3000 00:00:00",
        "active": true,
        "oneTimeConsent": false
      },
      {
        "consentId": 771,
        "bankId": "100000000007",
        "beginDate": "15.05.2023 14:45:41",
        "endDate": "01.01.3000 00:00:00",
        "active": true,
        "oneTimeConsent": false
      }
    ]
  }
}
"""
