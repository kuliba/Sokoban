//
//  RequestFactory+createGetCollateralLoanLandingShowRequestTests.swift
//  swift-forabank
//
//  Created by Valentin Ozerov on 08.10.2024.
//

import RemoteServices
import XCTest
import CollateralLoanLanding

final class RequestFactory_createGetCollateralLoanLandingShowRequestTests: XCTestCase {
    func test_createRequest_shouldSetURLWithOneParameterWithoutSerial() throws {
        
        let parameters = ["type": "COLLATERAL_SHOWCASE"]
        let url = anyURL()
        let request = try createRequest(parameters: parameters, url: url)
        
        XCTAssertNoDiff(request.url?.absoluteString, url.absoluteString + "?type=COLLATERAL_SHOWCASE")
    }

    func test_createRequest_shouldSetURLWithOneParameterWithSerial() throws {

        let type = "COLLATERAL_SHOWCASE"
        let serial = anySerial()
        let parameters = ["type": type, "serial": serial]
        let url = anyURL()
        let request = try createRequest(parameters: parameters, url: url)

        let paramsFromURL = try XCTUnwrap(request.url?.queryParameters)
        let serialFromURL: String? = paramsFromURL["serial"]
        let typeFromURL: String? = paramsFromURL["type"]

        XCTAssertEqual(serialFromURL, serial)
        XCTAssertEqual(typeFromURL, type)
    }

    func test_createRequest_shouldSetHTTPMethodToGET() throws {
        
        let request = try createRequest(parameters: [:])
        
        XCTAssertNoDiff(request.httpMethod, "GET")
    }
    
    func test_createRequest_shouldSetCachePolicy() throws {
        
        let request = try createRequest(parameters: [:])
        
        XCTAssertNoDiff(request.cachePolicy, .reloadIgnoringLocalAndRemoteCacheData)
    }
    
    func test_createRequest_shouldSetNilHTTPBodyWithEmptyParameters() throws {
        
        let request = try createRequest(parameters: [:])
        
        XCTAssertNil(request.httpBody)
    }
    
    func test_createRequest_shouldSetNilHTTPBodyWithOneParameters() throws {
        
        let parameters = [anyMessage(): anyMessage()]
        let request = try createRequest(parameters: parameters)
        
        XCTAssertNil(request.httpBody)
    }
    
    // MARK: - Helpers
    
    private func createRequest(
        parameters: [String: String],
        url: URL = anyURL()
    ) throws -> URLRequest {
        
        try RequestFactory.createGetCollateralLoanLandingRequest(
            parameters: parameters,
            url: url
        )
    }
}

private extension URL {
    var queryParameters: [String: String]? {
        guard
            let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
            let queryItems = components.queryItems else { return nil }
        return queryItems.reduce(into: [String: String]()) { (result, item) in
            result[item.name] = item.value
        }
    }
}
