//
//  RequestFactory+getDigitalCardLanding.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 03.12.2024.
//

import Foundation
import RemoteServices
import OrderCardLandingBackend

extension RequestFactory {
    
    static func createGetDigitalCardLandingRequest(
    ) throws -> URLRequest {
        
        let endpoint = Services.Endpoint.getCardLanding
        let url = try! endpoint.url(
            withBase: Config.serverAgentEnvironment.baseURL
        )
        
        return try RemoteServices.RequestFactory.createGetDigitalCardLandingRequest(
            url: url
        )
    }
}
