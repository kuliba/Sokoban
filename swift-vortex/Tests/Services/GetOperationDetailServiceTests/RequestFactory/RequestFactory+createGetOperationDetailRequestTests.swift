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
        XCTAssertNoDiff(body.paymentOperationDetailId, detailID)
    }
    
    func test_createRequest_shouldSetHTTPBodyJSON() throws {
        
        let detailID = makeDetailID()
        let request = try createRequest(detailID: detailID)
        
        try assertBody(of: request, hasJSON: """
        { "paymentOperationDetailId": \(detailID) }
        """
        )
    }
    
    // MARK: - Helpers
    
    private typealias DetailID = Int
    
    private func createRequest(
        _ url: URL = anyURL(),
        detailID: DetailID? = nil
    ) throws -> URLRequest {
        
        try RequestFactory.createGetOperationDetailRequest(
            url: url,
            detailID: detailID ?? makeDetailID()
        )
    }
    
    private func makeDetailID(
        _ id: Int = .random(in: 1...100)
    ) -> DetailID {
        
        return id
    }
    
    private struct Body: Decodable {
        
        let paymentOperationDetailId: Int
    }
}
