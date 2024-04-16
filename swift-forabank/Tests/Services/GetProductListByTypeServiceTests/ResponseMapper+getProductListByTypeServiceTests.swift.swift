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
    
    func test_map_returnAccountOnAccountData() throws {
        
        let result = try XCTUnwrap(map(data: JSON(for: .account))).get()
                
        XCTAssertNoDiff(result, .account)
    }
    
    func test_map_returnCardOnCardData() throws {
        
        let result = try XCTUnwrap(map(data: JSON(for: .card))).get()
                
        XCTAssertNoDiff(result, .card)
    }

    func test_map_returnDepositOnDepositData() throws {
        
        let result = try XCTUnwrap(map(data: JSON(for: .deposit))).get()
                
        XCTAssertNoDiff(result, .deposit)
    }
    
    func test_map_returnLoanOnLoanData() throws {
        
        let result = try XCTUnwrap(map(data: JSON(for: .loan))).get()
                
        XCTAssertNoDiff(result, .loan)
    }
    
    // MARK: - Helpers
    
    private func map(
        statusCode: Int = 200,
        data: Data
    ) -> Result {
        
        ResponseMapper.mapGetProductListByTypeResponse(
            data,
            anyHTTPURLResponse(statusCode: statusCode)
        )
    }
    
    private func JSON(for productType: ProductResponse.ProductType) throws -> Data {
        
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
    
    private let accountStub = Bundle.module.url(forResource: "GetProductListByType_Account_Response", withExtension: "json")!
    private let cardStub = Bundle.module.url(forResource: "GetProductListByType_Card_Response", withExtension: "json")!
    private let depositStub = Bundle.module.url(forResource: "GetProductListByType_Deposit_Response", withExtension: "json")!
    private let loanStub = Bundle.module.url(forResource: "GetProductListByType_Loan_Response", withExtension: "json")!
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
}
