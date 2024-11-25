//
//  RequestFactory_createGetSavingLandingRequestTests.swift
//  
//
//  Created by Andryusina Nataly on 21.11.2024.
//

import SavingsServices
import RemoteServices
import XCTest

final class RequestFactory_createGetSavingLandingRequestTests: XCTestCase {
    
    func test_createRequest_shouldSetURL() throws {
        
        let url = anyURL()
        let key = anyMessage()
        let value = anyMessage()
        let request = try createRequest(parameters: [key: value], url: url)
        
        XCTAssertNoDiff(request.url?.absoluteString, "\(url.absoluteString)?\(key)=\(value)")
    }

    func test_createRequest_shouldSetHTTPMethodToGET() throws {
        
        let request = try createRequest()
        
        XCTAssertNoDiff(request.httpMethod, "GET")
    }
    
    func test_createRequest_shouldSetCachePolicy() throws {
        
        let request = try createRequest()
        
        XCTAssertNoDiff(request.cachePolicy, .reloadIgnoringLocalAndRemoteCacheData)
    }
    
    func test_createRequest_shouldSetNilHTTPBody() throws {
        
        try XCTAssertNil(createRequest().httpBody)
    }
    
    // MARK: - Helpers
    
    private func createRequest(
        parameters: [String: String] = [anyMessage(): anyMessage()],
        url: URL = anyURL()
    ) throws -> URLRequest {
        
        try RequestFactory.createGetSavingLandingRequest(parameters: parameters, url: url)
    }
}
