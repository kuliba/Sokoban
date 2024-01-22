//
//  ResponseMapper+mapGetCardStatementResponseTests.swift
//
//
//  Created by Andryusina Nataly on 18.01.2024.
//

import XCTest
import CardStatementAPI

final class ResponseMapper_mapGetCardStatementResponseTests: XCTestCase {
    
    func test_map_statusCodeNot200_FailureNotOk() {
                
        let errorMessage = errorMessageByCode(400)
                
        XCTAssertNoDiff(
            map(statusCode: 400),
            сardStatementError(errorMessage)
        )
    }
    
    func test_map_statusCode200_dataNotValid_FailureMapError() {
        
        XCTAssertNoDiff(
            map(statusCode: 200, data: Data("test".utf8)),
            сardStatementDefaultError()
        )
    }
    
    func test_map_statusCode200_errorNotNil_dataEmpty_FailureMapError() {
                
        XCTAssertNoDiff(
            map(statusCode: 200, data: Data(String.error404.utf8)),
            сardStatementError("404: Не найден запрос к серверу"))
    }
    
    func test_map_statusCode200_dataEmpty_FailureMapError() {
                
        XCTAssertNoDiff(
            map(statusCode: 200, data: Data(String.emptyData.utf8)),
            сardStatementDefaultError())
    }
    
    func test_map_statusCode200_anyDataCodeWithOutMessage_FailureMapErrorDefaultMessage() {
        
        XCTAssertNoDiff(
            map(statusCode: 200, data: Data(String.errorWithOutMessage.utf8)),
            сardStatementDefaultError())
    }
    
    func test_map_statusCode200_Success() throws {
        
        let results = try XCTUnwrap(map(data: Data(String.sampleCardStatement.utf8))).get()
        var expectedResults: [ProductStatementData] = [.sample]
        
        assert(results, equals: &expectedResults)
    }

    // MARK: - Helpers
        
    private func map(
        statusCode: Int = 200,
        data: Data = Data(String.sampleCardStatement.utf8)
    ) -> Result {
        
        let result = ResponseMapper.mapGetCardStatementResponse(
            data,
            anyHTTPURLResponse(statusCode: statusCode)
        )
        return result
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
            "accountID": 1,
            "operationType": "DEBIT",
            "paymentDetailType": "C2B_PAYMENT",
            "amount": 10,
            "documentAmount": 10,
            "comment": "comment",
            "documentID": 2,
            "accountNumber": "accountNumber",
            "currencyCodeNumeric": 810,
            "merchantName": "merchantName",
            "merchantNameRus": "merchantNameRus",
            "groupName": "groupName",
            "md5hash": "md5hash",
            "svgImage": null,
            "fastPayment": null,
            "terminalCode": "terminalCode",
            "deviceCode": "deviceCode",
            "country": "country",
            "city": "city",
            "operationId": "operationId",
            "isCancellation": false,
            "cardTranNumber": "cardTranNumber",
            "opCode": 1,
            "date": "2001-01-01T00:00:00.000Z",
            "tranDate": null,
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

        type: .inside, accountID: 1, operationType: .debit, paymentDetailType: .c2b, amount: 10, documentAmount: 10, comment: "comment", documentID: 2, accountNumber: "accountNumber", currencyCodeNumeric: 810, merchantName: "merchantName", merchantNameRus: "merchantNameRus", groupName: "groupName", md5hash: "md5hash", svgImage: nil, fastPayment: nil, terminalCode: "terminalCode", deviceCode: "deviceCode", country: "country", city: "city", operationId: "operationId", isCancellation: false, cardTranNumber: "cardTranNumber", opCode: 1, date: Date(timeIntervalSince1970: 978307200), tranDate: nil, MCC: 0
    )
}

