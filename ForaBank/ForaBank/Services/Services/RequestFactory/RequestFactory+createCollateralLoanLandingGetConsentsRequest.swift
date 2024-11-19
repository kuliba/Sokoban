//
//  RequestFactory+createCollateralLoanLandingGetConsentsRequest.swift
//  ForaBank
//
//  Created by Valentin Ozerov on 18.11.2024.
//

import Foundation
import RemoteServices
import CollateralLoanLandingGetConsentsBackend

extension RequestFactory {
    
    static func createCollateralLoanLandingGetConsentsRequest(
        with payload: RemoteServices.RequestFactory.CreateCollateralLoanLandingGetConsentsPayload
    ) throws -> URLRequest {
        
        let endpoint = Services.Endpoint.getConsents
        let url = try endpoint.url(
            withBase: Config.serverAgentEnvironment.baseURL
        )
        
        return try RemoteServices.RequestFactory.createCollateralLoanLandingGetConsentsRequest(
            url: url,
            payload: payload
        )
    }
}
