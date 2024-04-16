//
//  RequestFactory+createGetC2BSubRequestTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 04.02.2024.
//

@testable import ForaBank
import XCTest

final class RequestFactory_createGetC2BSubRequestTests: XCTestCase {
    
    func test_createGetC2BSubRequest_shouldSetRequestURL() {
        
        let request = createGetC2BSubRequest()
        
        XCTAssertNoDiff(
            request.url?.absoluteString,
            "https://pl.forabank.ru/dbo/api/v3/rest/binding/v1/getC2BSub"
        )
    }
    
    func test_createGetC2BSubRequest_shouldSetRequestMethodToGet() {
        
        let request = createGetC2BSubRequest()
        
        XCTAssertEqual(request.httpMethod, "POST")
    }
    
    func test_createGetC2BSubRequest_shouldSetRequestBodyToNil() {
        
        let request = createGetC2BSubRequest()
        
        XCTAssertNil(request.httpBody)
    }
    
    // MARK: - Helpers
    
    private func createGetC2BSubRequest(
    ) -> URLRequest {
        
        RequestFactory.createGetC2BSubRequest()
    }
}
