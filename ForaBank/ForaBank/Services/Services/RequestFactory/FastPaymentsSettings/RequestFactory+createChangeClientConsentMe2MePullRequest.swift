//
//  RequestFactory+createChangeClientConsentMe2MePullRequest.swift
//  ForaBank
//
//  Created by Igor Malyarov on 03.02.2024.
//

import FastPaymentsSettings
import RemoteServices
import Foundation

extension RequestFactory {
    
    typealias BankIDList = RemoteServices.RequestFactory.BankIDList
    
    static func createChangeClientConsentMe2MePullRequest(
        _ payload: BankIDList
    ) throws -> URLRequest {
        
        let base = Config.serverAgentEnvironment.baseURL
        let endpoint = Services.Endpoint.changeClientConsentMe2MePull
        let endpointURL = try! endpoint.url(withBase: base)
        
        return try RemoteServices.RequestFactory.createChangeClientConsentMe2MePullRequest(url: endpointURL, payload: payload)
    }
}
