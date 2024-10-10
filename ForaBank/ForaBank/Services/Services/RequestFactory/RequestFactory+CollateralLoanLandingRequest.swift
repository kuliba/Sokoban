//
//  RequestFactory+CollateralLoanLandingRequest.swift
//  ForaBank
//
//  Created by Valentin Ozerov on 04.10.2024.
//

import Foundation
import RemoteServices

extension RequestFactory {
    static func createGetCollateralLoanLandingRequest(
        with parameters: [(String, String)]
    ) throws -> URLRequest {
        let endpoint = Services.Endpoint.createLandingRequest
        let url = try endpoint.url(
            withBase: Config.serverAgentEnvironment.baseURL,
            parameters: parameters
        )
        
        return RemoteServices.RequestFactory.createEmptyRequest(.get, with: url)
    }
}

