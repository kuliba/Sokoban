//
//  RequestFactory+createGetPaymentTemplateListRequestV3.swift
//  ForaBank
//
//  Created by Igor Malyarov on 05.09.2024.
//

import PaymentTemplateBackendV3
import Foundation
import RemoteServices

extension ForaBank.RequestFactory {
    
    static func createGetPaymentTemplateListRequestV3(
        serial: String?
    ) throws -> URLRequest {
        
        let base = Config.serverAgentEnvironment.baseURL
        let endpoint = Services.Endpoint.getPaymentTemplateListV3
        let endpointURL = try! endpoint.url(withBase: base)
        let url = try endpointURL.appendingSerial(serial)

        return try RemoteServices.RequestFactory.createGetPaymentTemplateListRequest(url: url)
    }
}
