//
//  GetCardOrderFormServiceTests.swift
//
//
//  Created by Дмитрий Савушкин on 11.12.2024.
//

import GetCardOrderFormService
import XCTest
import RemoteServices

final class RequestFactory_createGetCardOrderFormRequestTests: XCTestCase {
    
    // TODO: FIXME
//    func test_createRequest_shouldSetURL() throws {
//        
//        let url = anyURL()
//        let value = UUID().uuidString
//        let request = try createRequest(payload: value, url: url)
//        
//        XCTAssertNoDiff(request.url?.absoluteString, "\(url.absoluteString)?\("name")=\(value)")
//    }

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
        payload: String = "",
        url: URL = anyURL()
    ) throws -> URLRequest {
        
        try RequestFactory.createGetCardOrderFormRequest(url: url, payload: .init(name: payload))
    }
}

