//
//  RequestFactory+createGetClientConsentMe2MePullRequest.swift
//  ForaBank
//
//  Created by Igor Malyarov on 02.02.2024.
//

import FastPaymentsSettings
import Foundation
import RemoteServices

extension RequestFactory {
    
    static func createGetClientConsentMe2MePullRequest(
    ) -> URLRequest {
        
        let base = Config.serverAgentEnvironment.baseURL
        let endpoint = Services.Endpoint.getClientConsentMe2MePull
        let endpointURL = try! endpoint.url(withBase: base)
        
        return RemoteServices.RequestFactory.createGetClientConsentMe2MePullRequest(url: endpointURL)
    }
}
