//
//  RequestFactory+createPrepareSetBankDefaultRequestTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 03.02.2024.
//

@testable import ForaBank
import XCTest

final class RequestFactory_createPrepareSetBankDefaultRequestTests: XCTestCase {
    
    func test_createPrepareSetBankDefaultRequest_shouldSetRequestURL() {
        
        let request = createPrepareSetBankDefaultRequest()
        
        XCTAssertNoDiff(
            request.url?.absoluteString,
            "https://pl.forabank.ru/dbo/api/v3/rest/prepareSetBankDefault"
        )
    }
    
    func test_createPrepareSetBankDefaultRequest_shouldSetRequestMethodToGet() {
        
        let request = createPrepareSetBankDefaultRequest()
        
        XCTAssertEqual(request.httpMethod, "POST")
    }
    
    func test_createPrepareSetBankDefaultRequest_shouldSetRequestBodyToNil() {
        
        let request = createPrepareSetBankDefaultRequest()
        
        XCTAssertNil(request.httpBody)
    }
    
    // MARK: - Helpers
    
    private func createPrepareSetBankDefaultRequest(
    ) -> URLRequest {
        
        RequestFactory.createPrepareSetBankDefaultRequest()
    }
}
