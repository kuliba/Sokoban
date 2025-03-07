//
//  RequestFactory+createGetSplashScreenSettingsRequest.swift
//  Vortex
//
//  Created by Igor Malyarov on 07.03.2025.
//

import Foundation
import GetSplashScreenServices
import RemoteServices

extension RequestFactory {
    
    static func createGetSplashScreenSettingsRequest(
        serial: String?,
        period: String
    ) throws -> URLRequest {
        
        let base = Config.serverAgentEnvironment.baseURL
        let endpoint = Services.Endpoint.getSplashScreenSettings
        let endpointURL = try! endpoint.url(withBase: base)
        let url = try endpointURL.appendingQueryItems(parameters: [
            "serial": serial,
            "enum": period
        ].compactMapValues { $0 }) // TODO: improve `appendingQueryItems` with `compactMapValues`
        
        return RemoteServices.RequestFactory.createEmptyRequest(.get, with: url)
    }
}
