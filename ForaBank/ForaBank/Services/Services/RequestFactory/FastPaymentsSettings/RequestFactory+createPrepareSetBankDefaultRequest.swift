//
//  RequestFactory+createPrepareSetBankDefaultRequest.swift
//  ForaBank
//
//  Created by Igor Malyarov on 03.02.2024.
//

import FastPaymentsSettings
import Foundation
import RemoteServices

extension RequestFactory {
    
    static func createPrepareSetBankDefaultRequest(
    ) -> URLRequest {
        
        let base = Config.serverAgentEnvironment.baseURL
        let endpoint = Services.Endpoint.prepareSetBankDefault
        let endpointURL = try! endpoint.url(withBase: base)
        
        return RemoteServices.RequestFactory.createPrepareSetBankDefaultRequest(url: endpointURL)
    }
}
