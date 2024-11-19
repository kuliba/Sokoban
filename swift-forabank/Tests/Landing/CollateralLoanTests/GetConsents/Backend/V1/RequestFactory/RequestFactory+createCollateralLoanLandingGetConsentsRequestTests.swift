//
//  RequestFactory+createCollateralLoanLandingGetConsentsRequestTests.swift
//
//
//  Created by Valentin Ozerov on 18.11.2024.
//

import RemoteServices
import XCTest
import CollateralLoanLandingGetConsentsBackend

final class RequestFactory_createCollateralLoanLandingSaveConsentsRequestTests: XCTestCase {
    
    func test_createRequest_shouldSetHTTPMethodToGET() throws {
        
        let request = RequestFactory.createEmptyRequest(.get, with: anyURL())
        
        XCTAssertNoDiff(request.httpMethod, "GET")
    }
    
    func test_createRequest_shouldSetCachePolicy() throws {
        
        let request = RequestFactory.createEmptyRequest(.get, with: anyURL())
        
        XCTAssertNoDiff(request.cachePolicy, .reloadIgnoringLocalAndRemoteCacheData)
    }
    
    func test_createRequest_shouldCreateValidURL() throws {
        
        let url = anyURL()
        let applicationId = Int.random(in: (0...Int.max))
        let files = [String](repeating: anyMessage(), count: 3)
        let payload = Payload.stub(applicationId: applicationId, files: files)
        
        let request = try RequestFactory.createCollateralLoanLandingGetConsentsRequest(
            url: url,
            payload: payload
        )
        // [[Int]](repeating: [1,2,3], count: 3).flatMap{$0}
        let requestUrl = try XCTUnwrap(request.url)
        let urlComponents = try XCTUnwrap(URLComponents(url: requestUrl, resolvingAgainstBaseURL: false))
        let queryItems = try XCTUnwrap(urlComponents.queryItems)

        XCTAssertNoDiff(String(applicationId), queryItems.first { $0.name == "applicationId" }?.value)
        XCTAssertNoDiff(
            try payload.mapFiles,
            queryItems.first { $0.name == "files" }?.value
        )
    }
}

extension RequestFactory_createCollateralLoanLandingSaveConsentsRequestTests {
    
    typealias Payload = RequestFactory.CreateCollateralLoanLandingGetConsentsPayload
}

// MARK: - Helpers

private extension RequestFactory.CreateCollateralLoanLandingGetConsentsPayload {
    
    static func stub(
        applicationId: Int = .random(in: (0...Int.max)),
        files: [String] = [anyMessage()]
    ) -> Self {
        Self(applicationId: applicationId, files: files)
    }
    
    var mapFiles: String {

        get throws {
            
            let data = try JSONSerialization.data(withJSONObject: files as [String])
            
            guard
                let output = String(data: data, encoding: String.Encoding.utf8)
            else {
                throw TranscodeError.dataToStringConversionFailure
            }
            
            return output
        }
    }
    
    enum TranscodeError: Error {
        
        case dataToStringConversionFailure
    }
}
