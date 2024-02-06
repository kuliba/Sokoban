//
//  RequestFactory+createFastPaymentContractFindListRequest.swift
//  ForaBank
//
//  Created by Igor Malyarov on 02.02.2024.
//

import FastPaymentsSettings
import Foundation

extension RequestFactory {
    
    static func createFastPaymentContractFindListRequest(
    ) -> URLRequest {
        
        let base = Config.serverAgentEnvironment.baseURL
        let endpoint = Services.Endpoint.fastPaymentContractFindList
        let endpointURL = try! endpoint.url(withBase: base)
        
        return FastPaymentsSettings.RequestFactory.createFastPaymentContractFindListRequest(url: endpointURL)
    }
}
