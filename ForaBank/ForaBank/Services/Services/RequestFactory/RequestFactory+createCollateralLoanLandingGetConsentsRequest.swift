//
//  RequestFactory+createCollateralLoanLandingGetConsentsRequest.swift
//  Vortex
//
//  Created by Valentin Ozerov on 18.11.2024.
//

import Foundation
import RemoteServices
import CollateralLoanLandingGetConsentsBackend

extension RequestFactory {
    
    static func createGetConsentsRequest(
        with payload: RemoteServices.RequestFactory.GetConsentsPayload
    ) throws -> URLRequest {
        
        let endpoint = Services.Endpoint.getConsents
        let url = try endpoint.url(
            withBase: Config.serverAgentEnvironment.baseURL
        )
        
        return try RemoteServices.RequestFactory.createGetConsentsRequest(
            url: url,
            payload: payload
        )
    }
}
