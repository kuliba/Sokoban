//
//  RequestFactory+createPrepareDeleteDefaultBankRequest.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 03.10.2024.
//

import FastPaymentsSettings
import Foundation
import RemoteServices

extension RequestFactory {
    
    static func createPrepareDeleteDefaultBankRequest(
    ) -> URLRequest {
        
        let base = Config.serverAgentEnvironment.baseURL
        let endpoint = Services.Endpoint.prepareDeleteBankDefault
        let endpointURL = try! endpoint.url(withBase: base)
        
        return RemoteServices.RequestFactory.createPrepareDeleteBankDefaultRequest(url: endpointURL)
    }
}
