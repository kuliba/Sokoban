//
//  RequestFactory+createGetShowcaseRequest.swift
//  ForaBank
//
//  Created by Valentin Ozerov on 04.10.2024.
//

import Foundation
import RemoteServices

extension RequestFactory {
    static func createGetShowcaseRequest(
        serial: String?
    ) throws -> URLRequest {
        
        let endpoint = Services.Endpoint.getShowcaseCollateralLoanLanding
        let url = try endpoint.url(withBase: Config.serverAgentEnvironment.baseURL).appendingSerial(serial)
        
        return RemoteServices.RequestFactory.createGetShowcaseRequest(url: url)
    }
}

