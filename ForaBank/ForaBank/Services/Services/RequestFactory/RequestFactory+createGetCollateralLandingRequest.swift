//
//  RequestFactory+createGetCollateralLandingRequest.swift
//  ForaBank
//
//  Created by Valentin Ozerov on 28.11.2024.
//

import Foundation
import RemoteServices
import CollateralLoanLandingGetCollateralLandingBackend

extension RequestFactory {
    static func createGetCollateralLandingRequest(
        serial: String,
        landingType: RemoteServices.RequestFactory.CollateralLoanLandingType
    ) throws -> URLRequest {
        
        let parameters: [(String, String)] = [
            ("serial", serial),
            ("landingTypes", landingType.rawValue)
        ]
        
        let endpoint = Services.Endpoint.getCollateralLanding
        let url = try endpoint.url(withBase: Config.serverAgentEnvironment.baseURL, parameters: parameters)
        
        return try RemoteServices.RequestFactory.createGetCollateralLandingRequest(url: url)
    }
}

extension RemoteServices.RequestFactory.CollateralLoanLandingType {
    
    var rawValue: String {
        
        switch self {
        case .car:        return "CAR_LANDING"
        case .realEstate: return "REAL_ESTATE_LANDING"
        }
    }
}
