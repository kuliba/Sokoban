//
//  ResponseMapper+mapGetProductDynamicParamsListTests.swift
//
//
//  Created by Andryusina Nataly on 18.01.2024.
//

import XCTest
import CardStatementAPI

final class ResponseMapper_mapGetProductDynamicParamsListTests: XCTestCase {
    
    func test_map_statusCodeNot200_FailureNotOk() {
                                
        XCTAssertNoDiff(
            map(statusCode: 400, data: Data("test".utf8)),
            dynamicParamsError(.defaultErrorMessage)
        )
    }
    
    func test_map_statusCode200_dataNotValid_FailureMapError() {
        
        XCTAssertNoDiff(
            map(statusCode: 200, data: Data("test".utf8)),
            dynamicParamsDefaultError()
        )
    }
    
    func test_map_statusCode200_errorNotNil_dataEmpty_FailureMapError() {
                
        XCTAssertNoDiff(
            map(statusCode: 200, data: Data(String.error404.utf8)),
            dynamicParamsErrorNot200("404: Не найден запрос к серверу"))
    }
    
    func test_map_statusCode200_dataEmpty_FailureMapError() {
                
        XCTAssertNoDiff(
            map(statusCode: 200, data: Data(String.emptyData.utf8)),
            dynamicParamsDefaultError())
    }
    
    func test_map_statusCode200_anyDataCodeWithOutMessage_FailureMapErrorDefaultMessage() {
        
        XCTAssertNoDiff(
            map(statusCode: 200, data: Data(String.errorWithOutMessage.utf8)),
            dynamicParamsDefaultError())
    }
    
    func test_map_statusCode200_Success() throws {
        
        let results = try XCTUnwrap(map(data: sampleJSON())).get()
        var expectedResults: [DynamicParamsList] = [.sample]
        
        assert([results], equals: &expectedResults)
    }

    // MARK: - Helpers
        
    private func map(
        statusCode: Int = 200,
        data: Data
    ) -> ResponseMapper.GetProductDynamicParamsListResult {
        
        let result = ResponseMapper.mapGetProductDynamicParamsList(
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
    
    private let sampleURL = Bundle.module.url(forResource: "GetProductDynamicParamsList", withExtension: "json")!
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

private extension DynamicParamsList {
    
    static let sample: Self = .init(list: [
        .init(id: 11, type: .card, dynamicParams: .init(variableParams: .card(.sample))),
        .init(id: 12, type: .account, dynamicParams: .init(variableParams: .account(.sample))),
        .init(id: 13, type: .deposit, dynamicParams: .init(variableParams: .depositOrLoan(.sample)))
    ])
}

private extension AccountDynamicParams {
    
    static let sample: Self = .init(status: "Действует", balance: 5, balanceRub: 6, customName: "account")
}

private extension CardDynamicParams {
    
    static let sample: Self = .init(balance: 1, balanceRub: 1, customName: "card", availableExceedLimit: 2, status: "Действует", debtAmount: 3, totalDebtAmount: 4, statusPc: "0", statusCard: .active)
}

private extension DepositOrLoanDynamicParams {
    
    static let sample: Self = .init(balance: 7, balanceRub: 8, customName: "deposit")
}
