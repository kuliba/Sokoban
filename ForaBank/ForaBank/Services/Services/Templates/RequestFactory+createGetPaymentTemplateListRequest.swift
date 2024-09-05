//
//  RequestFactory+createGetPaymentTemplateListRequest.swift
//  ForaBank
//
//  Created by Igor Malyarov on 05.09.2024.
//

import PaymentTemplateBackend
import Foundation
import RemoteServices

extension ForaBank.RequestFactory {
    
    static func createGetPaymentTemplateListRequestV3(
    ) throws -> URLRequest {
        
        let base = Config.serverAgentEnvironment.baseURL
        let endpoint = Services.Endpoint.getPaymentTemplateListV3
        let endpointURL = try! endpoint.url(withBase: base)
        
        return try RemoteServices.RequestFactory.createGetPaymentTemplateListRequest(url: endpointURL)
    }
}
