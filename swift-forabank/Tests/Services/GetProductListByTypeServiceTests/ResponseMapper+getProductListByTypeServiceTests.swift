//
//  ResponseMapper+getProductListByTypeServiceTests.swift
//
//
//  Created by Disman Dmitry on 13.03.2024.
//

import XCTest
@testable import GetProductListByTypeService

typealias Result = ResponseMapper.GetProductListByTypeResult

final class ResponseMapper_getProductListByTypeServiceTests: XCTestCase {
    
    func test_map_returnInvalidErrorOnDataEmptyAndStatusCode200() {
        
        XCTAssertNoDiff(
            map(statusCode: 200, data: Data(String.emptyData.utf8)),
            getProductListByTypeInvalidError(dataString: String.emptyData)
        )
    }
    
    func test_map_returnInvalidErrorOnErrorDataAndStatusCode200() {
        
        XCTAssertNoDiff(
            map(statusCode: 200, data: Data(String.errorData.utf8)),
            getProductListByTypeInvalidError(dataString: String.errorData)
        )
    }
    
    func test_map_returnServer404WithMessageOnDataWithError404() {
        
        XCTAssertNoDiff(
            map(statusCode: 200, data: Data(String.error404.utf8)),
            getProductListByTypeServerError(
                statusCode: 404,
                errorMessage: "404: Не найден запрос к серверу"
            )
        )
    }
    
    func test_map_returnAccountProductListDataForAccountProductMock() throws {
        
        let result = try XCTUnwrap(map(data: JSON(for: .account))).get()
        let expectedResult: ProductListData = .account
                
        XCTAssertNoDiff(result, expectedResult)
    }
    
    func test_map_returnCardProductListDataForCardProductMock() throws {
        
        let result = try XCTUnwrap(map(data: JSON(for: .card))).get()
        let expectedResult: ProductListData = .card
                
        XCTAssertNoDiff(result, expectedResult)
    }

    func test_map_returnDepositProductListDataForDepositProductMock() throws {
        
        let result = try XCTUnwrap(map(data: JSON(for: .deposit))).get()
        let expectedResult: ProductListData = .deposit
                
        XCTAssertNoDiff(result, expectedResult)
    }
    
    func test_map_returnLoanProductListDataForLoanProductMock() throws {
        
        let result = try XCTUnwrap(map(data: JSON(for: .loan))).get()
        let expectedResult: ProductListData = .loan
                
        XCTAssertNoDiff(result, expectedResult)
    }
    
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
    
    private func JSON(for productType: ProductListData.ProductType) throws -> Data {
        
        switch productType {
        case .account:
            return try Data(contentsOf: XCTUnwrap(accountStub))

        case .card:
            return try Data(contentsOf: XCTUnwrap(cardStub))

        case .deposit:
            return try Data(contentsOf: XCTUnwrap(depositStub))

        case .loan:
            return try Data(contentsOf: XCTUnwrap(loanStub))

        }
    }
    
    private let accountStub = Bundle.module.url(forResource: "AccountStub", withExtension: "json")!
    private let cardStub = Bundle.module.url(forResource: "CardStub", withExtension: "json")!
    private let depositStub = Bundle.module.url(forResource: "DepositStub", withExtension: "json")!
    private let loanStub = Bundle.module.url(forResource: "LoanStub", withExtension: "json")!
}

private extension ResponseMapper_getProductListByTypeServiceTests {
    
    func getProductListByTypeInvalidError(dataString: String?) -> Result {
        
        guard let dataString else {
            
            return .failure(.invalid(statusCode: 200, data: Data()))
        }
        
        return .failure(.invalid(statusCode: 200, data: Data(dataString.utf8)))
    }
    
    func getProductListByTypeServerError(
        statusCode: Int,
        errorMessage: String
    ) -> Result {
        
        return .failure(.server(statusCode: statusCode, errorMessage: errorMessage))
    }
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
    static let defaultErrorMessage: Self = "Возникла техническая ошибка"
}
