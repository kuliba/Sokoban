//
//  RequestFactory+createGetSplashScreenTimePeriodsRequestTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 07.03.2025.
//

@testable import Vortex
import RemoteServices
import XCTest

final class RequestFactory_createGetSplashScreenTimePeriodsRequestTests: XCTestCase {
    
    func test_createRequest_shouldSetRequestURL_onNilSerial() throws {
        
        try XCTAssertNoDiff(
            createRequest(serial: nil).url?.removingQueryItems?.absoluteString,
            "https://pl.\(Config.domen)/dbo/api/v3/dict/v1/getSplashScreenTimePeriods"
        )
    }
    
    func test_createRequest_shouldSetRequestURL_onEmptySerial() throws {
        
        try XCTAssertNoDiff(
            createRequest(serial: "").url?.removingQueryItems?.absoluteString,
            "https://pl.\(Config.domen)/dbo/api/v3/dict/v1/getSplashScreenTimePeriods"
        )
    }
    
    func test_createRequest_shouldSetRequestURL_onNonEmptySerial() throws {
        
        try XCTAssertNoDiff(
            createRequest(serial: anyMessage()).url?.removingQueryItems?.absoluteString,
            "https://pl.\(Config.domen)/dbo/api/v3/dict/v1/getSplashScreenTimePeriods"
        )
    }
    
    func test_createRequest_shouldSetRequestURLWithoutSerial_onNilSerial() throws {
        
        try assert(createRequest(serial: nil), hasKeys: [])
    }
    
    func test_createRequest_shouldSetRequestURLWithoutSerial_onEmptySerial() throws {
        
        try assert(createRequest(serial: ""), hasKeys: [])
    }
    
    func test_createRequest_shouldSetRequestURLWithoutSerial_onNonEmptySerial() throws {
        
        try assert(createRequest(serial: anyMessage()), hasKeys: ["serial"])
    }
    
    func test_createRequest_shouldSetRequestURLWithSerialAndPeriod() throws {
        
        let serial = anyMessage()
        
        try assert(createRequest(serial: serial), has: serial, forKey: "serial")
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
        serial: String? = nil
    ) throws -> URLRequest {
        
        try Vortex.RequestFactory.createGetSplashScreenTimePeriodsRequest(serial: serial)
    }
}
