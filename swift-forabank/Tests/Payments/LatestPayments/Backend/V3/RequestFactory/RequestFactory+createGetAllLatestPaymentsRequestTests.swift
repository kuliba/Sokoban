//
//  RequestFactory+createGetAllLatestPaymentsRequestTests.swift
//
//
//  Created by Igor Malyarov on 07.09.2024.
//

import LatestPaymentsBackendV3
import RemoteServices
import XCTest

final class RequestFactory_createGetAllLatestPaymentsRequestTests: XCTestCase {
    
    func test_createRequest_shouldSetURLWithEmptyParameters() throws {
        
        let url = anyURL()
        let request = try createRequest(parameters: [], url: url)
        
        XCTAssertNoDiff(request.url, url)
    }
    
    func test_createRequest_shouldSetURLWithOneParameter() throws {
        
        let parameters = ["isPhonePayments"]
        let url = try XCTUnwrap(URL(string: "any-url"))
        let request = try createRequest(parameters: parameters, url: url)
        
        XCTAssertNoDiff(request.url?.absoluteString, "any-url?isPhonePayments=true")
    }
    
    func test_createRequest_shouldSetURLWithTwoParameters() throws {
        
        let parameters = ["isPhonePayments", "isCountriesPayments"]
        let url = try XCTUnwrap(URL(string: "any-url"))
        let request = try createRequest(parameters: parameters, url: url)
        
        XCTAssertNoDiff(request.url?.absoluteString, "any-url?isPhonePayments=true&isCountriesPayments=true")
    }
    
    func test_createRequest_shouldSetHTTPMethodToGET() throws {
        
        let request = try createRequest(parameters: [])
        
        XCTAssertNoDiff(request.httpMethod, "GET")
    }
    
    func test_createRequest_shouldSetCachePolicy() throws {
        
        let request = try createRequest(parameters: [])
        
        XCTAssertNoDiff(request.cachePolicy, .reloadIgnoringLocalAndRemoteCacheData)
    }
    
    func test_createRequest_shouldSetNilHTTPBodyWithEmptyParameters() throws {
        
        let request = try createRequest(parameters: [])
        
        XCTAssertNil(request.httpBody)
    }
    
    func test_createRequest_shouldSetNilHTTPBodyWithOneParameter() throws {
        
        let parameters = [anyMessage()]
        let request = try createRequest(parameters: parameters)

        XCTAssertNil(request.httpBody)
    }
    
    func test_createRequest_shouldSetNilHTTPBodyWithTwoParameters() throws {
        
        let parameters = [anyMessage(), anyMessage()]
        let request = try createRequest(parameters: parameters)
        
        XCTAssertNil(request.httpBody)
    }
    
    // MARK: - Helpers
    
    private func createRequest(
        parameters: [String],
        url: URL = anyURL()
    ) throws -> URLRequest {
        
        try RequestFactory.createGetAllLatestPaymentsRequest(parameters: parameters, url: url)
    }
}
