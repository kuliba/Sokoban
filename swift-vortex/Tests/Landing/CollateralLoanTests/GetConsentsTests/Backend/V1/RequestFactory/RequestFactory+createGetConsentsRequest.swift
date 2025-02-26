//
//  RequestFactory+createGetConsentsRequestTests.swift
//
//
//  Created by Valentin Ozerov on 18.11.2024.
//

import RemoteServices
import XCTest
import CollateralLoanLandingGetConsentsBackend

final class RequestFactory_createGetConsentsRequestTests: XCTestCase {
    
    func test_createRequest_shouldSetHTTPMethodToGET() throws {
        
        let request = RequestFactory.createEmptyRequest(.get, with: anyURL())
        
        XCTAssertNoDiff(request.httpMethod, "GET")
    }
    
    func test_createRequest_shouldSetCachePolicy() throws {
        
        let request = RequestFactory.createEmptyRequest(.get, with: anyURL())
        
        XCTAssertNoDiff(request.cachePolicy, .reloadIgnoringLocalAndRemoteCacheData)
    }

    func test_createRequest_shouldCreateValidURL() throws {

        let request = try makeRequest(.random(in: 0..<Int.max))

        _ = try XCTUnwrap(request.url)
    }

    func test_createRequest_shouldCreateValidParameters() throws {

        let applicationID = Int.random(in: (0...Int.max))

        let queryItems = try getQueryItems(applicationID)

        XCTAssertNoDiff(queryItems.first { $0.name == "applicationId" }?.value, String(applicationID))
    }
    
    // MARK: Helpers
    
    private func makeRequest(
        _ applicationID: Int,
        _ verificationCode: String = anyMessage(),
        _ url: URL = anyURL()
    ) throws -> URLRequest {
        
        let payload = Payload(
            cryptoVersion: "1.0", // Constant
            applicationId: UInt(applicationID),
            verificationCode: verificationCode
        )

        let request = try RequestFactory.createGetConsentsRequest(
            url: url,
            payload: payload
        )
        
        return request
    }
    
    private func getQueryItems(_ applicationID: Int) throws -> [URLQueryItem] {

        let request = try makeRequest(applicationID)
        
        let requestUrl = try XCTUnwrap(request.url)
        let urlComponents = try XCTUnwrap(URLComponents(url: requestUrl, resolvingAgainstBaseURL: false))
        let queryItems = try XCTUnwrap(urlComponents.queryItems)

        return queryItems
    }
}

extension RequestFactory_createGetConsentsRequestTests {
    
    typealias Payload = RequestFactory.GetConsentsPayload
}
