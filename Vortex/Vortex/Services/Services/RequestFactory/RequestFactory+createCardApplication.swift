//
//  RequestFactory+createCardApplication.swift
//
//
//  Created by Дмитрий Савушкин on 27.01.2025.
//

import Foundation
import RemoteServices
import CreateCardApplication

extension RequestFactory {
    
    static func createCardApplicationRequest(
        payload: CreateCardApplicationPayload
    ) throws -> URLRequest{
        
        let base = Config.serverAgentEnvironment.baseURL
        let endpoint = Services.Endpoint.createCardApplication
        let endpointURL = try! endpoint.url(withBase: base)

        return try RemoteServices.RequestFactory.createCardApplication(
            url: endpointURL,
            payload: payload
        )
    }
}
