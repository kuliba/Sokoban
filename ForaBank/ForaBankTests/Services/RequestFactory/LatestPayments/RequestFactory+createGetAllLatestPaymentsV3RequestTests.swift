//
//  RequestFactory+createGetAllLatestPaymentsV3RequestTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 07.09.2024.
//

@testable import ForaBank
import RemoteServices
import XCTest

final class RequestFactory_createGetAllLatestPaymentsV3RequestTests: XCTestCase {
    
    func test_createRequest_shouldSetRequestURLWithEmptyParameters() throws {
        
        let request = try createRequest(parameters: [])
        
        XCTAssertNoDiff(
            request.url?.absoluteString,
            "https://pl.forabank.ru/dbo/api/v3/rest/v3/getAllLatestPayments"
        )
    }
    
    func test_createRequest_shouldSetRequestURLWithOneParameter() throws {
        
        let parameters = ["isPhonePayments"]
        let request = try createRequest(parameters: parameters)
        
        XCTAssertNoDiff(
            request.url?.absoluteString,
            "https://pl.forabank.ru/dbo/api/v3/rest/v3/getAllLatestPayments?isPhonePayments=true"
        )
    }
    
    func test_createRequest_shouldSetRequestURLWithTwoParameters() throws {
        
        let parameters = ["isPhonePayments", "isCountriesPayments"]
        let request = try createRequest(parameters: parameters)
        
        XCTAssertNoDiff(
            request.url?.absoluteString,
            "https://pl.forabank.ru/dbo/api/v3/rest/v3/getAllLatestPayments?isPhonePayments=true&isCountriesPayments=true"
        )
    }
    
    func test_createRequest_shouldSetHTTPMethodToGET() throws {
        
        let request = try createRequest(parameters: [])
        
        XCTAssertNoDiff(request.httpMethod, "GET")
    }
    
    func test_createRequest_shouldSetCachePolicy() throws {
        
        let request = try createRequest(parameters: [])

        XCTAssertNoDiff(request.cachePolicy, .reloadIgnoringLocalAndRemoteCacheData)
    }
    
    func test_createRequest_shouldNotSetHTTPBodyWithEmptyParameters() throws {
        
        let request = try createRequest(parameters: [])

        XCTAssertNil(request.httpBody)
    }
    
    func test_createRequest_shouldNotSetHTTPBodyWithOneParameter() throws {
        
        let parameters = [anyMessage()]
        let request = try createRequest(parameters: parameters)

        XCTAssertNil(request.httpBody)
    }
    
    func test_createRequest_shouldNotSetHTTPBodyWithTwoParameter() throws {
        
        let parameters = [anyMessage(), anyMessage()]
        let request = try createRequest(parameters: parameters)

        XCTAssertNil(request.httpBody)
    }
    
    // MARK: - Helpers
    
    private func createRequest(
        parameters: [String]
    ) throws -> URLRequest {
        
        try RequestFactory.createGetAllLatestPaymentsV3Request(parameters: parameters)
    }
}
