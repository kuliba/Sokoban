//
//  RequestFactory+createGetCollateralLoanLandingConsentsRequest.swift
//  
//
//  Created by Valentin Ozerov on 24.10.2024.
//

import Foundation
import RemoteServices

public extension RequestFactory {

    struct CreateSaveConsentsCollateralLoanApplicationPayload: Equatable {
        
        public let applicationId: Int
        public let verificationCode: String

        public init(applicationId: Int, verificationCode: String) {
            self.applicationId = applicationId
            self.verificationCode = verificationCode
        }
    }

    static func createGetCollateralLoanLandingSaveConsentsRequest(
        url: URL,
        payload: CreateSaveConsentsCollateralLoanApplicationPayload
    ) throws -> URLRequest {
        
        var request = createEmptyRequest(.post, with: url)
        request.httpBody = try payload.httpBody
        return request
    }
}

public extension RequestFactory.CreateSaveConsentsCollateralLoanApplicationPayload {
    
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
