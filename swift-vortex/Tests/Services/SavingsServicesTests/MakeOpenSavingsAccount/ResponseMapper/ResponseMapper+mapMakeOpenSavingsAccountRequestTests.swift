//
//  ResponseMapper+mapMakeOpenSavingsAccountRequestTests.swift
//
//
//  Created by Andryusina Nataly on 25.11.2024.
//

import SavingsServices
import RemoteServices
import XCTest

final class ResponseMapper_mapMakeOpenSavingsAccountRequestTests: XCTestCase {
    
    func test_map_shouldDeliverValidOnValidProducts() {
        
        XCTAssertNoDiff(
            map(.valid),
            .success(.valid))
    }
    
    func test_map_shouldDeliverInvalidFailureOnEmptyData() {
        
        XCTAssertNoDiff(
            map(.empty),
            .failure(.invalid(statusCode: 200, data: .empty))
        )
    }
    
    func test_map_shouldDeliverDefaultOnInvalidData() {
        
        XCTAssertNoDiff(
            map(.invalidData),
            .success(.empty)
        )
    }
    
    func test_map_shouldDeliverInvalidFailureOnEmptyJSON() {
        
        XCTAssertNoDiff(
            map(.emptyJSON),
            .failure(.invalid(statusCode: 200, data: .emptyJSON))
        )
    }
    
    func test_map_shouldDeliverEmptyOnEmptyDataResponse() {
        
        XCTAssertNoDiff(
            map(.emptyDataResponse),
            .success(.empty)
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
            .success(.empty)
        )
    }
    
    func test_map_shouldDeliverEmptyWithNoSerial() {
        
        XCTAssertNoDiff(
            map(.nullSerialResponse),
            .success(.empty)
        )
    }
    
    func test_map_shouldDeliverEmptyWithNoProducts() {
        
        XCTAssertNoDiff(
            map(.nullProductsResponse),
            .success(.empty)
        )
    }
    
    // MARK: - Helpers
    
    private typealias Response = MakeOpenSavingsAccountResponse
    private typealias MappingResult = ResponseMapper.MappingResult<Response>
    
    private func map(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse = anyHTTPURLResponse()
    ) -> MappingResult {
        
        ResponseMapper.mapMakeOpenSavingsAccountResponse(data, httpURLResponse)
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
    "needMake": true,
    "needOTP": true,
    "amount": 10.0,
    "creditAmount": 11.0,
    "accountNumber": "11111",
    "fee": 17,
    "currencyAmount": "11",
    "currencyPayer": "14",
    "currencyPayee": "13",
    "currencyRate": 15,
    "debitAmount": 16,
    "payeeName": "18",
    "paymentOperationDetailId": 10,
    "documentStatus": "COMPLETE"
  }
}
"""
}

private extension MakeOpenSavingsAccountResponse {
    
    static let valid: Self = .init(
        documentInfo: .valid,
        paymentInfo: .valid,
        paymentOperationDetailID: 10)
    
    static let empty: Self = .init(documentInfo: .init(documentStatus: nil, needMake: false, needOTP: false, scenario: nil), paymentInfo: .init(amount: nil, accountNumber: nil, creditAmount: nil, currencyAmount: nil, currencyPayee: nil, currencyPayer: nil, currencyRate: nil, debitAmount: nil, fee: nil, payeeName: nil), paymentOperationDetailID: nil)
}

private extension MakeOpenSavingsAccountResponse.DocumentInfo {
    
    static let valid: Self = .init(
        documentStatus: .complete,
        needMake: true,
        needOTP: true,
        scenario: nil)
}

private extension MakeOpenSavingsAccountResponse.PaymentInfo {
    
    static let valid: Self = .init(
        amount: 10, 
        accountNumber: "11111",
        creditAmount: 11,
        currencyAmount: "11",
        currencyPayee: "13",
        currencyPayer: "14",
        currencyRate: 15,
        debitAmount: 16,
        fee: 17,
        payeeName: "18")
}
