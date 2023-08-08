//
//  RequestFactoryAPIConfigTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 03.08.2023.
//

@testable import ForaBank
import XCTest

final class RequestFactoryAPIConfigTests: XCTestCase {
    
    func test_processingServerURL() {
        
        XCTAssertEqual(
            RequestFactory.APIConfig.processingServerURL,
            "https://dmz-api-gate-test.forabank.ru"
        )
    }
}
