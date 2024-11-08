//
//  RequestFactory+createCollateralLoanLandingSaveConsentsRequestTests.swift
//
//
//  Created by Valentin Ozerov on 24.10.2024.
//

import RemoteServices
import XCTest
import CollateralLoanLandingSaveConsentsBackend

final class RequestFactory_createCollateralLoanLandingSaveConsentsRequestTests: XCTestCase {
    
    func test_createRequest_shouldSetHTTPMethodToPOST() throws {
        
        let request = try RequestFactory.createSaveConsentsRequest(url: anyURL(), payload: .stub())
        
        XCTAssertNoDiff(request.httpMethod, "POST")
    }
    
    func test_createRequest_shouldSetCachePolicy() throws {
        
        let request = try RequestFactory.createSaveConsentsRequest(url: anyURL(), payload: .stub())

        XCTAssertNoDiff(request.cachePolicy, .reloadIgnoringLocalAndRemoteCacheData)
    }
    
    func test_createRequest_shouldSetWithHTTPBody() throws {
        
        let applicationId = Int.random(in: (0...Int.max))
        let verificationCode = anyMessage()

        let payload = RequestFactory.SaveConsentsPayload.stub(
            applicationId: applicationId,
            verificationCode: verificationCode
        )
        let request = try RequestFactory.createSaveConsentsRequest(url: anyURL(), payload: payload)

        request.
        
        let decodedBody = try request.decodedBody(as: RequestFactory.SaveConsentsPayload.self)
        
        XCTAssertNoDiff(decodedBody.applicationId, payload.applicationId)
        XCTAssertNoDiff(decodedBody.verificationCode, payload.verificationCode)
    }
}

extension RequestFactory_createCollateralLoanLandingSaveConsentsRequestTests {
    
    typealias Payload = RequestFactory.SaveConsentsPayload
}

// MARK: - Helpers

private struct Body: Decodable {
    
    let applicationId: Int
    let verificationCode: String
    
    static let stub = Self(
        applicationId: .random(in: (0...Int.max)),
        verificationCode: anyMessage()
    )
}

extension Body {
    
    var httpBody: Data {

        get throws {
            
            let parameters: [String: Any] = [
                "applicationId": applicationId,
                "verificationCode": verificationCode
            ]
                        
            return try JSONSerialization.data(
                withJSONObject: parameters as [String: Any]
            )
        }
    }
}

extension RequestFactory.SaveConsentsPayload {
    
    static func stub(
        applicationId: Int = .random(in: (0...Int.max)),
        verificationCode: String = anyMessage()
    ) -> Self {
        
        Self(
            applicationId: applicationId,
            verificationCode: verificationCode
        )
    }
}

extension RequestFactory.SaveConsentsPayload: Decodable {

    enum CodingKeys: CodingKey {
        
        case applicationId
        case verificationCode
    }
    
    public init(from decoder: any Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.applicationId = try container.decode(Int.self, forKey: .applicationId)
        self.link = try container.decodeWrapper(String.self, forKey: Item.CodingKeys.link, defaultValue: "")
        self.detail = try container.decodeIfPresent(Item.Detail.self, forKey: Item.CodingKeys.detail) ?? nil
    }
}
