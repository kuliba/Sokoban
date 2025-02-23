//
//  RequestFactory+createGetOperationDetailRequestTests.swift
//
//
//  Created by Igor Malyarov on 16.02.2025.
//

import GetOperationDetailService
import RemoteServices
import XCTest

final class RequestFactory_createGetOperationDetailRequestTests: XCTestCase {
    
    func test_createRequest_shouldSetURL() throws {
        
        let url = anyURL()
        let request = try createRequest(url)
        
        XCTAssertNoDiff(request.url, url)
    }
    
    func test_createRequest_shouldSetHTTPMethodToPOST() throws {
        
        let request = try createRequest()
        
        XCTAssertNoDiff(request.httpMethod, "POST")
    }
    
    func test_createRequest_shouldSetCachePolicy() throws {
        
        let request = try createRequest()
        
        XCTAssertNoDiff(request.cachePolicy, .reloadIgnoringLocalAndRemoteCacheData)
    }
    
    func test_createRequest_shouldSetHTTPBody() throws {
        
        let detailID = makeDetailID()
        let request = try createRequest(detailID: detailID)
        
        let body = try request.decodedBody(as: Body.self)
        XCTAssertNoDiff(body.documentId, detailID)
    }
    
    func test_createRequest_shouldSetHTTPBodyJSON() throws {
        
        let detailID = makeDetailID()
        let request = try createRequest(detailID: detailID)
        
        try assertBody(of: request, hasJSON: """
        { "documentId": "\(detailID)" }
        """
        )
    }
    
    // MARK: - Helpers
    
    private typealias DetailID = String
    
    private func createRequest(
        _ url: URL = anyURL(),
        detailID: DetailID = anyMessage()
    ) throws -> URLRequest {
        
        try RequestFactory.createGetOperationDetailRequest(
            url: url,
            detailID: detailID
        )
    }
    
    private func makeDetailID(
        _ detailID: DetailID = anyMessage()
    ) -> DetailID {
        
        return detailID
    }
    
    private struct Body: Decodable {
        
        let documentId: String
    }
}
