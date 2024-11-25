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
    
    func test_createRequest_shouldCreateValidGetParameters() throws {

        let docIDs = [String](repeating: anyMessage(), count: 3)
        let applicationID = Int.random(in: (0...Int.max))
        
        let queryItems = try getQueryItems(with: docIDs, applicationID)
        let mapFiles = try getMapFiles(with: docIDs)
        
        XCTAssertNoDiff(queryItems.first { $0.name == "applicationId" }?.value, String(applicationID))
        XCTAssertNoDiff(queryItems.first { $0.name == "docIds" }?.value, mapFiles)
    }
    
    func test_createRequest_shouldCreateValidURL() throws {
    
        let url = anyURL()
        let docIDs = [String](repeating: anyMessage(), count: 3)
        let applicationID = Int.random(in: (0...Int.max))
        
        let requestURLString = try getRequestURLString(with: docIDs, applicationID, url)
        let madeURLString = try makeURLString(with: docIDs, applicationID, url)
        
        XCTAssertNoDiff(requestURLString, madeURLString)
    }
    
    // MARK: Helpers
    
    private func makeURLString(
        with docIDs: [String],
        _ applicationID: Int,
        _ url: URL = anyURL()
    ) throws -> String {

        let mapFiles = try XCTUnwrap(getMapFiles(with: docIDs))
        return "\(url.absoluteString)?docIds=\(mapFiles)&applicationId=\(applicationID)"
    }
    
    private func getRequestURLString(
        with docIDs: [String],
        _ applicationID: Int,
        _ url: URL = anyURL()
    ) throws -> String {
        
        let request = try makeRequest(with: docIDs, applicationID, url)
        return try XCTUnwrap(request.url?.absoluteString.removingPercentEncoding)
    }
    
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
