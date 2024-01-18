//
//  ProductStatementMapperTests.swift
//  ForaBankTests
//
//  Created by Andryusina Nataly on 18.01.2024.
//

import XCTest
@testable import ForaBank

final class ProductStatementMapperTests: XCTestCase {

    func test_map_statusCode200_dataNotNil() throws {
        
        let data = try XCTUnwrap(map(statusCode: 200))
        
        XCTAssertNotNil(data)
    }
    
    func test_map_statusCodeNot200_FailureNotOk() throws {
        
        let data = try XCTUnwrap(map(statusCode: 400))
        
        let errorMessage = errorMessageByCode(400)
        
        XCTAssertNoDiff(data, .failure(.mapError(errorMessage)))
    }
    
    func test_map_statusCode200_dataNotValid_FailureMapError() throws {
        
        let data = try XCTUnwrap(map(statusCode: 200, data: Data("test".utf8)))
        
        XCTAssertNoDiff(data, .failure(.mapError(.defaultError)))
    }
    
    func test_map_statusCode200_errorNotNil_dataEmpty_FailureMapError() throws {
        
        let data = try XCTUnwrap(map(statusCode: 200, data: Data(String.error404.utf8)))
        
        XCTAssertNoDiff(data, .failure(.mapError("404: Не найден запрос к серверу")))
    }
    
    func test_map_statusCode200_dataEmpty_FailureMapError() throws {
        
        let data = try XCTUnwrap(map(statusCode: 200, data: Data(String.emptyData.utf8)))
        
        XCTAssertNoDiff(data, .failure(.mapError(.defaultError)))
    }
    
    func test_map_statusCode200_anyDataCodeWithOutMessage_FailureMapErrorDefaultMessage() throws {
        
        let data = try XCTUnwrap(map(statusCode: 200, data: Data(String.errorWithOutMessage.utf8)))
        
        XCTAssertNoDiff(data, .failure(.mapError(.defaultError)))
    }
    
    func test_map_statusCode200_Success() throws {
        
        let results = try XCTUnwrap(map(data: Data(String.sampleCardStatement.utf8))).get()
        var expectedResults: [ProductStatementData] = [.sample]
        
        assert(results, equals: &expectedResults)
    }

    // MARK: - Helpers
    
    private typealias Result = Services.GetCardStatementResult
    
    private func map(
        statusCode: Int = 200,
        data: Data = Data(String.sample.utf8)
    ) -> Result {
        
        let decodableLanding = ProductStatementMapper.map(
            data,
            anyHTTPURLResponse(with: statusCode)
        )
        return decodableLanding
    }
        
    private func errorMessageByCode(
        _ code: Int
    ) -> String {
        
        HTTPURLResponse.localizedString(forStatusCode: code)
    }
}

private extension String {
    
    static let sampleCardStatement: Self = """
{
  "statusCode": 0,
  "errorMessage": "string",
  "data": [
    {
        "type": "INSIDE",
        "accountID": 100,
        "date": "2001-01-01T00:00:00.000Z",
        "tranDate": "2001-01-01T00:00:00.000Z",
        "operationType": "DEBIT",
        "paymentDetailType": "SFP",
        "amount": 20,
        "documentAmount": 20,
        "comment": "",
        "documentID": 102,
        "accountNumber": "302",
        "currencyCodeNumeric": 810,
        "merchantName": "",
        "merchantNameRus": "merchantNameRus",
        "groupName": "groupName",
        "md5hash": "md5hash",
        "terminalCode": "",
        "deviceCode": "",
        "country": "",
        "city": "",
        "operationId": "105",
        "isCancellation": false,
        "cardTranNumber": "465",
        "opCode": 1,
        "MCC": 0
    }
  ]
}
"""
    static let emptyData: Self = """
    {
      "statusCode": 0,
      "errorMessage": null,
      "data": null
    }
"""
    static let errorData: Self = """
    {
      "statusCode": 0,
      "errorMessage": null,
      "data": {
        "key": "value"
        }
    }
"""
    static let error404: Self = """
    {
      "statusCode":404,
      "errorMessage":"404: Не найден запрос к серверу",
      "data":null
    }
"""
    static let errorWithOutMessage: Self = """
    {
      "statusCode": 999,
      "errorMessage": nul,
      "data": null
    }
"""
}

private extension ProductStatementData {
    
    static let sample: Self = .init(
        mcc: 0,
        accountId: 100,
        accountNumber: "302",
        amount: 20,
        cardTranNumber: "465",
        city: "",
        comment: "",
        country: "",
        currencyCodeNumeric: 810,
        date: Date(timeIntervalSince1970: 978307200),
        deviceCode: "",
        documentAmount: 20,
        documentId: 102,
        fastPayment: nil,
        groupName: "groupName",
        isCancellation: false,
        md5hash: "md5hash",
        merchantName: "",
        merchantNameRus: "merchantNameRus",
        opCode: 1,
        operationId: "105",
        operationType: .debit,
        paymentDetailType: .sfp,
        svgImage: nil,
        terminalCode: "",
        tranDate: Date(timeIntervalSince1970: 978307200),
        type: .inside
    )
}
