//
//  RequestFactory+createGetBannersMyProductListRequestTests.swift
//  
//
//  Created by Valentin Ozerov on 23.10.2024.
//

import RemoteServices
import XCTest

final class RequestFactory_createGetBannersMyProductListRequestTests: XCTestCase {

    func test_createRequest_shouldSetURLWithoutSerial() throws {
        
        let url = anyURL()
        let request = try createRequest(url: url)

        XCTAssertNoDiff(request.url?.absoluteString, url.absoluteString)
        XCTAssertNil(request.url?.queryParameters)
    }

    func test_createRequest_shouldSetURLWithSerial() throws {

        let serial = anySerial()
        let url = anyURL()
        let request = try createRequest(serial: serial, url: url)

        let paramsFromURL = try XCTUnwrap(request.url?.queryParameters)
        let serialFromURL: String? = paramsFromURL["serial"]

        XCTAssertEqual(serialFromURL, serial)
    }

    func test_createRequest_shouldSetHTTPMethodToGET() throws {
        
        let url = anyURL()
        let request = try createRequest(url: url)
        
        XCTAssertNoDiff(request.httpMethod, "GET")
    }
    
    func test_createRequest_shouldSetCachePolicy() throws {
        
        let url = anyURL()
        let request = try createRequest(url: url)
        
        XCTAssertNoDiff(request.cachePolicy, .reloadIgnoringLocalAndRemoteCacheData)
    }
        
    // MARK: - Helpers

    private func createRequest(
        serial: String?,
        url: URL = anyURL()
    ) throws -> URLRequest {
        
        try RequestFactory.createGetBannersMyProductListRequest(
            serial: serial,
            url: url
        )
    }

    private func createRequest(url: URL = anyURL()) throws -> URLRequest {
        
        try RequestFactory.createGetBannersMyProductListRequest(url: url)
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
