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
                                
        XCTAssertNoDiff(
            map(statusCode: 400, data: Data("test".utf8)),
            сardStatementError(.defaultErrorMessage)
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
            сardStatementErrorNot200("404: Не найден запрос к серверу"))
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
    
    //FIXME: fix test
    /*
    func test_map_statusCode200_Success() throws {
        
        let results = try XCTUnwrap(map(data: sampleJSON())).get()
        let expectedResults: ProductStatementWithExtendedInfo = .sample

        XCTAssertNoDiff(results.operationList, expectedResults.operationList)
    }
    */
    // MARK: - Helpers
        
    private func map(
        statusCode: Int = 200,
        data: Data
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
    
    private func sampleJSON() throws -> Data {
        
        try Data(contentsOf: XCTUnwrap(sampleURL))
    }
    
    private let sampleURL = Bundle.module.url(forResource: "StatementSample", withExtension: "json")!
}

private extension String {
    
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

        type: .inside, accountID: 10000872827, operationType: .debit, paymentDetailType: .c2b, amount: 10, documentAmount: 10, comment: "Перевод C2B СБП получателю ООО \"АГРОТОРГ\".", documentID: 20017126099, accountNumber: "30302810900060000006", currencyCodeNumeric: 810, merchantName: "34T4 Пятерочка", merchantNameRus: "34T4 Пятерочка", groupName: "Оплата по QR-коду", md5hash: "d46cb4ded97c143291ea3fab225b0e2f", svgImage: nil, fastPayment: .init(opkcid: "A3359170018807390000040011150101", foreignName: "ООО \"АГРОТОРГ\"", foreignPhoneNumber: "                                                  ", foreignBankBIC: "044525593", foreignBankID: "10000000818", foreignBankName: "АО \"АЛЬФА-БАНК\"", documentComment: "", operTypeFP: "CBPH", tradeName: "34T4 Пятерочка", guid: "640949825"), terminalCode: "", deviceCode: "", country: "", city: "", operationId: "a1cc1739-68cf-465e-b606-119f6dea3940", isCancellation: false, cardTranNumber: "4656260144403580", opCode: 1, date: Date(timeIntervalSince1970: 978307200), tranDate: nil, MCC: 0
    )
}

private extension ProductStatementWithExtendedInfo {
    
    static let sample: Self = .init(operationList: [.sample])
}
