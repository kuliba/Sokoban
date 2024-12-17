//
//  RequestFactory+createGetC2BSubRequest.swift
//  ForaBank
//
//  Created by Igor Malyarov on 04.02.2024.
//

import FastPaymentsSettings
import Foundation
import RemoteServices

extension RequestFactory {
    
    static func createGetC2BSubRequest(
    ) -> URLRequest {
        
        let base = Config.serverAgentEnvironment.baseURL
        let endpoint = Services.Endpoint.getC2BSub
        let endpointURL = try! endpoint.url(withBase: base)
        
        return RemoteServices.RequestFactory.createGetC2BSubRequest(url: endpointURL)
    }
}
