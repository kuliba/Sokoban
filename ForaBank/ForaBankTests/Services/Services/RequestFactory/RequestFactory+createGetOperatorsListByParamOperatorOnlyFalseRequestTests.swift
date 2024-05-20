//
//  RequestFactory+createGetOperatorsListByParamOperatorOnlyFalseRequestTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 16.05.2024.
//

@testable import ForaBank
import XCTest

final class RequestFactory_createGetOperatorsListByParamOperatorOnlyFalseRequestTests: XCTestCase {
    
    func test_createRequest_shouldThrowOnEmptyOperatorID() throws {
        
        try XCTAssertThrowsError( createRequest(""))
    }
    
    func test_createRequest_shouldSetRequestURL() throws {
        
        let operatorID = UUID().uuidString
        let request = try createRequest(operatorID)
        
        XCTAssertNoDiff(
            request.url?.absoluteString,
            "https://pl.forabank.ru/dbo/api/v3/dict/getOperatorsListByParam?customerId=\(operatorID)&operatorOnly=false&type=housingAndCommunalService"
        )
    }
    
    func test_createRequest_shouldSetRequestMethodToGet() throws {
        
        let request = try createRequest()
        
        XCTAssertEqual(request.httpMethod, "GET")
    }
    
    func test_createRequest_shouldSetRequestBodyToNil() throws {
        
        let request = try createRequest()
        
        XCTAssertNil(request.httpBody)
    }
    
    // MARK: - Helpers
    
    private func createRequest(
        _ operatorID: String = UUID().uuidString
    ) throws -> URLRequest {
        
        try RequestFactory.createGetOperatorsListByParamOperatorOnlyFalseRequest(operatorID: operatorID)
    }
}
