//
//  RequestFactory+createFastPaymentContractFindListRequestTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 02.02.2024.
//

@testable import ForaBank
import XCTest

final class RequestFactory_createFastPaymentContractFindListRequestTests: XCTestCase {
    
    func test_createFastPaymentContractFindListRequest_shouldSetRequestURL() {
        
        let request = createFastPaymentContractFindListRequest()
        
        XCTAssertNoDiff(
            request.url?.absoluteString,
            "https://pl.forabank.ru/dbo/api/v3/rest/fastPaymentContractFindList"
        )
    }
    
    func test_createFastPaymentContractFindListRequest_shouldSetRequestMethodToGet() {
        
        let request = createFastPaymentContractFindListRequest()
        
        XCTAssertEqual(request.httpMethod, "GET")
    }
    
    func test_createFastPaymentContractFindListRequest_shouldSetRequestBodyToNil() {
        
        let request = createFastPaymentContractFindListRequest()
        
        XCTAssertNil(request.httpBody)
    }
    
    // MARK: - Helpers
    
    private func createFastPaymentContractFindListRequest(
    ) -> URLRequest {
        
        RequestFactory.createFastPaymentContractFindListRequest()
    }
}
