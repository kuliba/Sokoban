//
//  RequestFactory+CollateralLoanShowCaseRequest.swift
//  ForaBank
//
//  Created by Valentin Ozerov on 04.10.2024.
//

import Foundation
import RemoteServices

extension RequestFactory {
    public enum URLError: Error {
        case invalidURL
    }

    static func createGetCollateralLoanShowRequest() throws -> URLRequest {
        let parameters: [(String, String)] = [
            ("type", "COLLATERAL_SHOWCASE")
        ]
        
        let endpoint = Services.Endpoint.createLandingRequest
        let url = try! endpoint.url(
            withBase: Config.serverAgentEnvironment.baseURL,
            parameters: parameters
        )
        
        return RemoteServices.RequestFactory.createEmptyRequest(.get, with: url)
    }
}
