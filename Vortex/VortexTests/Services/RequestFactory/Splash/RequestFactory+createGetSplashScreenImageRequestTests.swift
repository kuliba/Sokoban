//
//  RequestFactory+createGetSplashScreenImageRequestTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 07.03.2025.
//

@testable import Vortex
import RemoteServices
import XCTest

final class RequestFactory_createGetSplashScreenImageRequestTests: XCTestCase {
    
    func test_createRequest_shouldSetRequestURL() throws {
        
        try XCTAssertNoDiff(
            createRequest().url?.removingQueryItems?.absoluteString,
            "https://pl.\(Config.domen)/dbo/api/v3/dict/getSplashScreenImage"
        )
    }
        
    func test_createRequest_shouldSetRequestURLWithSplashParameter() throws {
        
        let splash = anyMessage()
        
        try assert(createRequest(splash: splash), hasKeys: ["splash"])
        try assert(createRequest(splash: splash), has: splash, forKey: "splash")
    }
    
    func test_createRequest_shouldSetHTTPMethodToGET() throws {
        
        try XCTAssertNoDiff(createRequest().httpMethod, "GET")
    }
    
    func test_createRequest_shouldSetCachePolicy() throws {
        
        try XCTAssertNoDiff(createRequest().cachePolicy, .reloadIgnoringLocalAndRemoteCacheData)
    }
    
    func test_createRequest_shouldNotSetHTTPBody() throws {
        
        try XCTAssertNil(createRequest().httpBody)
    }
    
    // MARK: - Helpers
    
    private func createRequest(
        splash: String = anyMessage()
    ) throws -> URLRequest {
        
        try Vortex.RequestFactory.createGetSplashScreenImageRequest(splash: splash)
    }
}
