//
//  RequestFactory+createCollateralLoanLandingSaveConsentsRequest.swift
//
//
//  Created by Valentin Ozerov on 24.10.2024.
//

import Foundation
import RemoteServices

public extension RequestFactory {

    struct CreateCollateralLoanLandingSaveConsentsPayload: Equatable {
        
        public let applicationId: Int
        public let verificationCode: String

        public init(applicationId: Int, verificationCode: String) {
            self.applicationId = applicationId
            self.verificationCode = verificationCode
        }
    }

    static func createCollateralLoanLandingSaveConsentsRequest(
        url: URL,
        payload: CreateCollateralLoanLandingSaveConsentsPayload
    ) throws -> URLRequest {
        
        var request = createEmptyRequest(.post, with: url)
        request.httpBody = try payload.httpBody
        return request
    }
}

public extension RequestFactory.CreateCollateralLoanLandingSaveConsentsPayload {
    
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
