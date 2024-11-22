//
//  ResponseMapper+mapGetOpenAccountFormRequestTests.swift
//
//
//  Created by Andryusina Nataly on 22.11.2024.
//

import SavingsServices
import RemoteServices
import XCTest

final class ResponseMapper_mapGetOpenAccountFormRequestTests: XCTestCase {
    
    func test_map_shouldDeliverValidOnValidProducts() {
        
        XCTAssertNoDiff(
            map(.valid),
            .success(.init(list: [.valid], serial: "36")))
    }
    
    func test_map_shouldDeliverEmptyProductsOnFeeNilData() {
        
        XCTAssertNoDiff(
            map(.feeNil),
            .success(.init(list: [], serial: "36")))
    }
    
    func test_map_shouldDeliverEmptyProductsOnCurrencyNilData() {
        
        XCTAssertNoDiff(
            map(.currencyNil),
            .success(.init(list: [], serial: "36")))
    }
    
    func test_map_shouldDeliverInvalidFailureOnEmptyData() {
        
        XCTAssertNoDiff(
            map(.empty),
            .failure(.invalid(statusCode: 200, data: .empty))
        )
    }
    
    func test_map_shouldDeliverInvalidFailureOnInvalidData() {
        
        XCTAssertNoDiff(
            map(.invalidData),
            .failure(.invalid(statusCode: 200, data: .invalidData))
        )
    }
    
    func test_map_shouldDeliverInvalidFailureOnEmptyJSON() {
        
        XCTAssertNoDiff(
            map(.emptyJSON),
            .failure(.invalid(statusCode: 200, data: .emptyJSON))
        )
    }
    
    func test_map_shouldDeliverInvalidFailureOnEmptyDataResponse() {
        
        XCTAssertNoDiff(
            map(.emptyDataResponse),
            .failure(.invalid(statusCode: 200, data: .emptyDataResponse))
        )
    }
    
    func test_map_shouldDeliverInvalidFailureOnNullServerResponse() {
        
        XCTAssertNoDiff(
            map(.nullServerResponse),
            .failure(.invalid(statusCode: 200, data: .nullServerResponse))
        )
    }
    
    func test_map_shouldDeliverServerErrorOnServerError() {
        
        XCTAssertNoDiff(
            map(.serverError),
            .failure(.server(
                statusCode: 102,
                errorMessage: "Возникла техническая ошибка"
            ))
        )
    }
    
    func test_map_shouldDeliverInvalidFailureOnNonOkHTTPResponse() {
        
        for statusCode in [199, 201, 399, 400, 401, 404] {
            
            let nonOkResponse = anyHTTPURLResponse(statusCode: statusCode)
            
            XCTAssertNoDiff(
                map(.valid, nonOkResponse),
                .failure(.invalid(statusCode: statusCode, data: .valid))
            )
        }
    }
    
    func test_map_shouldDeliverValidOnEmptyProducts() {
        
        XCTAssertNoDiff(
            map(.emptyProductsResponse),
            .success(.init(list: [], serial: "1"))
        )
    }
    
    func test_map_shouldDeliverInvalidFailureWithNoSerial() {
        
        XCTAssertNoDiff(
            map(.nullSerialResponse),
            .failure(.invalid(statusCode: 200, data: .nullSerialResponse))
        )
    }
    
    func test_map_shouldDeliverInvalidFailureWithNoProducts() {
        
        XCTAssertNoDiff(
            map(.nullProductsResponse),
            .failure(.invalid(statusCode: 200, data: .nullProductsResponse))
        )
    }
    
    // MARK: - Helpers
    
    private typealias Response = ResponseMapper.GetOpenAccountFormResponse
    private typealias MappingResult = ResponseMapper.MappingResult<Response>
    
    private func map(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse = anyHTTPURLResponse()
    ) -> MappingResult {
        
        ResponseMapper.mapGetOpenAccountFormResponse(data, httpURLResponse)
    }
}

private extension Data {
    
    static let empty: Data = .init()
    static let emptyDataResponse: Data = String.emptyDataResponse.json
    static let emptyJSON: Data = String.emptyJSON.json
    static let emptyProductsResponse: Data = String.emptyProductsResponse.json
    static let invalidData: Data = String.invalidData.json
    static let nullProductsResponse: Data = String.nullProductsResponse.json
    static let nullSerialResponse: Data = String.nullSerialResponse.json
    static let nullServerResponse: Data = String.nullServerResponse.json
    static let serverError: Data = String.serverError.json
    static let valid: Data = String.valid.json
    static let feeNil: Data = String.feeNil.json
    static let currencyNil: Data = String.currencyNil.json
}

private extension String {
    
    var json: Data { .init(self.utf8) }
    
    static let invalidData = """
{
    "statusCode": 102,
    "errorMessage": null,
    "data": { "products": "junk" }
}
"""
    
    static let emptyJSON = "{}"
    
    static let emptyDataResponse = """
{
    "statusCode": 102,
    "errorMessage": null,
    "data": {}
}
"""
    
    static let nullServerResponse = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": null
}
"""
    
    static let serverError = """
{
    "statusCode": 102,
    "errorMessage": "Возникла техническая ошибка",
    "data": null
}
"""
    
    static let emptyProductsResponse = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": {
        "serial": "1",
        "products": []
    }
}
"""
    
    static let nullSerialResponse = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": {
        "serial": null,
        "products": []
    }
}
"""
    
    static let nullProductsResponse = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": {
        "serial": "1bebd140bc2660211fbba306105479ae",
        "products": null
    }
}
"""
    
    static let valid = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "serial": "36",
    "products": [
      {
        "hint": "Вы можете сразу пополнить счет",
        "id": 10000000532,
        "title": "Накопительный счет",
        "description": "Накопительный в рублях",
        "design": "b6f",
        "currency": {
          "code": 840,
          "symbol": "$"
        },
        "fee": {
          "openAndMaintenance": 50,
          "subscription": {
            "period": "month",
            "value": 100
          }
        },
        "income": "6,05%",
        "conditionsLink": "conditionsLink",
        "tariffLink": "http://"
      }
    ]
  }
}
"""
    
    static let feeNil = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "serial": "36",
    "products": [
      {
        "hint": "hint1",
        "id": 1,
        "title": "title1",
        "description": "description1",
        "design": "b6f",
        "currency": {
          "code": 840,
          "symbol": "$"
        },
        "fee": null,
        "income": "income",
        "conditionsLink": "conditionsLink",
        "tariffLink": "http://"
      }
    ]
  }
}
"""
    
    static let currencyNil = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "serial": "36",
    "products": [
      {
        "hint": "hint1",
        "id": 1,
        "title": "title1",
        "description": "description1",
        "design": "b6f",
        "currency": null,
        "fee": null,
        "income": "income",
        "conditionsLink": "conditionsLink",
        "tariffLink": "http://"
      }
    ]
  }
}
"""
}

private extension ResponseMapper.GetOpenAccountFormData {
    
    static let valid: Self = .init(
        conditionsLink: "conditionsLink",
        currency: .valid,
        description: "Накопительный в рублях",
        design: "b6f",
        fee: .valid,
        hint: "Вы можете сразу пополнить счет",
        productId: 10000000532,
        income: "6,05%",
        tariffLink: "http://",
        title: "Накопительный счет")
}

private extension ResponseMapper.GetOpenAccountFormData.Fee {
    
    static let valid: Self = .init(
        openAndMaintenance: 50,
        subscription: .init(period: "month", value: 100))
}

private extension ResponseMapper.GetOpenAccountFormData.Currency {
    
    static let valid: Self = .init(code: 840, symbol: "$")
}
