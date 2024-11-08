//
//  RequestFactory+createCollateralLoanLandingSaveConsentsRequest.swift
//
//
//  Created by Valentin Ozerov on 24.10.2024.
//

import Foundation
import RemoteServices

public extension RequestFactory {

    struct SaveConsentsPayload: Equatable {
        
        public let applicationId: Int
        public let verificationCode: String

        public init(applicationId: Int, verificationCode: String) {
            self.applicationId = applicationId
            self.verificationCode = verificationCode
        }
    }

    static func createSaveConsentsRequest(
        url: URL,
        payload: SaveConsentsPayload
    ) throws -> URLRequest {
        
        var request = createEmptyRequest(.post, with: url)
        request.httpBody = try payload.httpBody
        return request
    }
}

extension RequestFactory.SaveConsentsPayload {
    
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
