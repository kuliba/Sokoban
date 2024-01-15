//
//  Model+StatementTests.swift
//  ForaBankTests
//
//  Created by Andryusina Nataly on 15.01.2024.
//

import XCTest
@testable import ForaBank

final class Model_StatementTests: XCTestCase {
    
    // MARK: ParserGetCardStatementForPeriod Tests

   func test_parserGetCardStatementForPeriod_ok_emptyData_errorMessageEmpty_returnErrorEmptyDataWithEmptyMessage() {
        
        let result = parser(
            result: .success(.init(
                statusCode: .ok,
                errorMessage: "", 
                data: .none)))
        
        XCTAssertNoDiff(result, .errorEmptyDataWithOutMessage)
    }
    
    func test_parserGetCardStatementForPeriod_ok_emptyData_errorMessageNotEmpty_returnErrorEmptyDataWithMessage() {
        
        let result = parser(
            result: .success(.init(
                statusCode: .ok,
                errorMessage: "error",
                data: .none)))
        
        XCTAssertNoDiff(result, .errorEmptyDataWithMessage)
    }
    
    func test_parserGetCardStatementForPeriod_ok_withData_returnData() {
        

        let result = parser(
            result: .success(.init(
                statusCode: .ok,
                errorMessage: "",
                data: .productStatementData)))
        
        XCTAssertNoDiff(result, .success(.productStatementData))
    }
    
    func test_parserGetCardStatementForPeriod_notOk_returnError() {
        
        let result = parser(
            result: .success(.init(
                statusCode: .serverError,
                errorMessage: "error",
                data: .none)))
        
        XCTAssertNoDiff(result, .failure(.statusError(status: .serverError, message: "error")))
    }

    func test_parserGetCardStatementForPeriod_failure_returnError() {
        
        let result = parser(
            result: .failure(.notAuthorized))
        
        XCTAssertNoDiff(result, .failure(.serverCommandError(error: "Not Authorized")))
    }
    
    // MARK: - Helpers
    
    private func parser(
        result: Model.ResultGetCardStatementForPeriod
    ) -> Model.ResultParserGetCardStatementForPeriod {
                
        return Model.parserGetCardStatementForPeriod(result: result)
    }
}

extension ModelProductsError: Equatable {
    
    public static func == (lhs: ModelProductsError, rhs: ModelProductsError) -> Bool {
        switch (lhs, rhs) {

        case (let .emptyData(message: message1), let .emptyData(message: message2)):
            return message1 == message2
            
        case (let .statusError(status: status1, message: message1), let .statusError(status: status2, message: message2)):
            return status1 == status2 && message1 == message2
            
        case (let .serverCommandError(error: error1), let .serverCommandError(error: error2)):
            return error1 == error2
            
        case (.unableCacheUnknownProductType, .unableCacheUnknownProductType):
            return true
          
        case (let .cacheStoreErrors(errors1), let .cacheStoreErrors(errors2)):
            return errors1.count == errors2.count
            
        case (let .cacheClearErrors(errors1), let .cacheClearErrors(errors2)):
            return errors1.count == errors2.count
            
        default:
            return false
        }
    }
}

private extension Model.ResultParserGetCardStatementForPeriod {
    
    static let errorEmptyDataWithOutMessage: Self = .failure(.emptyData(message: ""))
    static let errorEmptyDataWithMessage: Self = .failure(.emptyData(message: "error"))
}

private extension Array where Element == ProductStatementData {
    
    static let productStatementData: Self = [
        .init(id: "1", 
              date: Date(timeIntervalSinceReferenceDate: -123456789.0),
              amount: 10,
              operationType: .credit,
              tranDate: nil)
    ]
}
