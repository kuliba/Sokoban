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

        let docIDs = [String](repeating: anyMessage(), count: 3)
        let applicationID = Int.random(in: (0...Int.max))
        let url = anyURL()

        let request = try makeRequest(with: docIDs, applicationID, url)
        let queryItems = try getQueryItems(with: docIDs, applicationID)
        let mapFiles = try getMapFiles(with: docIDs)

        XCTAssertNoDiff(request.url?.pathComponents.first, url.absoluteString )
        XCTAssertNoDiff(queryItems.first { $0.name == "applicationId" }?.value, String(applicationID))
        XCTAssertNoDiff(queryItems.first { $0.name == "docIds" }?.value, mapFiles)
    }
    
    // MARK: Helpers
    
    private func makeRequest(
        with docIDs: [String],
        _ applicationID: Int,
        _ url: URL = anyURL()
    ) throws -> URLRequest {
        
        let payload = Payload(applicationID: applicationID, docIDs: docIDs)

        let request = try RequestFactory.createGetConsentsRequest(
            url: url,
            payload: payload
        )
        
        return request
    }
    
    private func getQueryItems(with docIDs: [String], _ applicationID: Int) throws -> [URLQueryItem] {

        let request = try makeRequest(with: docIDs, applicationID)
        
        let requestUrl = try XCTUnwrap(request.url)
        let urlComponents = try XCTUnwrap(URLComponents(url: requestUrl, resolvingAgainstBaseURL: false))
        let queryItems = try XCTUnwrap(urlComponents.queryItems)

        return queryItems
    }
    
    private func getMapFiles(with docIDs: [String]) throws -> String? {
        
        let data = try JSONSerialization.data(withJSONObject: docIDs as [String])
        let mapFiles = String(data: data, encoding: String.Encoding.utf8)
        
        return mapFiles
    }
}

extension RequestFactory_createGetConsentsRequestTests {
    
    typealias Payload = RequestFactory.GetConsentsPayload
}
