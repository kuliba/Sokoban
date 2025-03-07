//
//  RequestFactory+createGetSplashScreenSettingsRequestTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 07.03.2025.
//

@testable import Vortex
import RemoteServices
import XCTest

final class RequestFactory_createGetSplashScreenSettingsRequestTests: XCTestCase {
    
    func test_createRequest_shouldSetRequestURL_onNilSerial() throws {
        
        try XCTAssertNoDiff(
            createRequest(serial: nil).url?.removingQueryItems?.absoluteString,
            "https://pl.\(Config.domen)/dbo/api/v3/dict/v1/getSplashScreenSettings"
        )
    }
    
    func test_createRequest_shouldSetRequestURL_onEmptySerial() throws {
        
        try XCTAssertNoDiff(
            createRequest(serial: "").url?.removingQueryItems?.absoluteString,
            "https://pl.\(Config.domen)/dbo/api/v3/dict/v1/getSplashScreenSettings"
        )
    }
    
    func test_createRequest_shouldSetRequestURL_onNonEmptySerial() throws {
        
        try XCTAssertNoDiff(
            createRequest(serial: anyMessage()).url?.removingQueryItems?.absoluteString,
            "https://pl.\(Config.domen)/dbo/api/v3/dict/v1/getSplashScreenSettings"
        )
    }
    
    func test_createRequest_shouldSetRequestURLWithoutSerial_onNilSerial() throws {
        
        try assert(createRequest(serial: nil), hasKeys: ["enum"])
    }
    
    func test_createRequest_shouldSetRequestURLWithoutSerial_onEmptySerial() throws {
        
        try assert(createRequest(serial: ""), hasKeys: ["enum"])
    }
    
    func test_createRequest_shouldSetRequestURLWithoutSerial_onNonEmptySerial() throws {
        
        try assert(createRequest(serial: anyMessage()), hasKeys: ["serial", "enum"])
    }
    
    func test_createRequest_shouldSetRequestURLWithSerialAndPeriod() throws {
        
        let serial = anyMessage()
        let period = anyMessage()
        
        try assert(createRequest(serial: serial, period: period), has: serial, forKey: "serial")
        try assert(createRequest(serial: serial, period: period), has: period, forKey: "enum")
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
        serial: String? = nil,
        period: String = anyMessage()
    ) throws -> URLRequest {
        
        try Vortex.RequestFactory.createGetSplashScreenSettingsRequest(serial: serial, period: period)
    }
}
