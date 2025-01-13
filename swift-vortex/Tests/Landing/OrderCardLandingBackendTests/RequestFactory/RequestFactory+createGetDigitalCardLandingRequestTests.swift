//
//  RequestFactory+createGetDigitalCardLandingRequestTests.swift
//  
//
//  Created by Дмитрий Савушкин on 03.12.2024.
//

import XCTest
import OrderCardLandingBackend
import UIPrimitives

final class RequestFactory_createGetDigitalCardLandingRequestTests: XCTestCase {

    func test_createRequest_shouldSetHTTPMethodToPOST() throws {
        
        let request = try RequestFactory.createGetDigitalCardLandingRequest(url: anyURL())
        
        XCTAssertNoDiff(request.httpMethod, "GET")
    }
    
    func test_createRequest_shouldSetCachePolicy() throws {
        
        let request = try RequestFactory.createGetDigitalCardLandingRequest(url: anyURL())

        XCTAssertNoDiff(request.cachePolicy, .reloadIgnoringLocalAndRemoteCacheData)
    }
}
