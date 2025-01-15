//
//  RequestFactory+createGetCollateralLandingRequest.swift
//  Vortex
//
//  Created by Valentin Ozerov on 28.11.2024.
//

import Foundation
import RemoteServices
import CollateralLoanLandingGetCollateralLandingBackend

extension RequestFactory {
    
    static func createGetCollateralLandingRequest(
        serial: String?,
        landingId: String
    ) throws -> URLRequest {
        
        var parameters: [(String, String)] = [
            ("landingTypes", landingId)
        ]

        if let serial {
            
            parameters.append(("serial", serial))
        }
        
        let endpoint = Services.Endpoint.getCollateralLanding
        let url = try endpoint.url(withBase: Config.serverAgentEnvironment.baseURL, parameters: parameters)
        
        return try RemoteServices.RequestFactory.createGetCollateralLandingRequest(url: url)
    }
}
