//
//  RequestFactory+createCollateralLoanLandingGetConsentsRequest.swift
//
//
//  Created by Valentin Ozerov on 28.10.2024.
//

import Foundation
import RemoteServices

public extension RequestFactory {

    struct CreateGetConsentsCollateralLoanApplicationPayload: Equatable {
        
        public let applicationId: Int
        public let docIds: [String: String]

        public init(applicationId: Int, docIds: [String: String]) {
            self.applicationId = applicationId
            self.docIds = docIds
        }
    }

    static func createCollateralLoanLandingGetConsentsRequest(
        url: URL,
        payload: CreateGetConsentsCollateralLoanApplicationPayload
    ) throws -> URLRequest {
        
        var request = createEmptyRequest(.get, with: url)
        request.httpBody = try payload.httpBody
        return request
    }
}

public extension RequestFactory.CreateGetConsentsCollateralLoanApplicationPayload {
    
    var httpBody: Data {

        get throws {
            
            let parameters: [String: Any] = [
                "applicationId": applicationId,
                "docIds": docIds
            ]
                        
            return try JSONSerialization.data(
                withJSONObject: parameters as [String: Any]
            )
        }
    }
}
