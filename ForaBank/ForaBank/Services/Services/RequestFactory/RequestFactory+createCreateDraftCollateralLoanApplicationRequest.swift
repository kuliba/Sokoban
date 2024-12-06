//
//  RequestFactory+createCreateDraftCollateralLoanApplicationRequest.swift
//  Vortex
//
//  Created by Valentin Ozerov on 27.11.2024.
//

import Foundation
import RemoteServices
import CollateralLoanLandingCreateDraftCollateralLoanApplicationBackend

extension RequestFactory {
    
    static func createCreateDraftCollateralLoanApplicationRequest(
        with payload: RemoteServices.RequestFactory.CreateDraftCollateralLoanApplicationPayload
    ) throws -> URLRequest {
        
        let endpoint = Services.Endpoint.createDraftCollateralLoanApplication
        let url = try! endpoint.url(
            withBase: Config.serverAgentEnvironment.baseURL
        )
        
        return try RemoteServices.RequestFactory.createCreateDraftCollateralLoanApplicationRequest(
            url: url,
            payload: payload
        )
    }
}
