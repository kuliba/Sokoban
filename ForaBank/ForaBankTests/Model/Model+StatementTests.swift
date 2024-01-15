//
//  Model+StatementTests.swift
//  ForaBankTests
//
//  Created by Andryusina Nataly on 15.01.2024.
//

import XCTest
@testable import ForaBank

final class Model_StatementTests: XCTestCase {
    
    func test_parserGetCardStatementForPeriod_ok_emptyData_errorMessageEmpty_returnErrorEmptyDataWithEmptyMessage() {
        
        let sut = Model.parserGetCardStatementForPeriod(result: .success(.init(statusCode: .ok, errorMessage: "", data: .none)))
        
        XCTAssertNoDiff(sut, .failure(.emptyData(message: "")) )
    }
    
    func test_parserGetCardStatementForPeriod_ok_emptyData_errorMessageNotEmpty_returnErrorEmptyDataWithNotEmptyMessage() {
        
        let sut = Model.parserGetCardStatementForPeriod(result: .success(.init(statusCode: .ok, errorMessage: "error", data: .none)))
        
        XCTAssertNoDiff(sut, .failure(.emptyData(message: "error")) )
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
