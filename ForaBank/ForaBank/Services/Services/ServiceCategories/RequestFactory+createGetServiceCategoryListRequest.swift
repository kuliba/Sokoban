//
//  RequestFactory+createGetServiceCategoryListRequest.swift
//  ForaBank
//
//  Created by Igor Malyarov on 13.08.2024.
//

import ServiceCategoriesBackendV0
import Foundation
import RemoteServices

extension ForaBank.RequestFactory {
    
    static func createGetServiceCategoryListRequest(
        serial: String?
    ) throws -> URLRequest {
        
        let base = Config.serverAgentEnvironment.baseURL
        let endpoint = Services.Endpoint.getServiceCategoryList
        let endpointURL = try! endpoint.url(withBase: base)
        let url = try endpointURL.appendingSerial(serial)
        
        return try RemoteServices.RequestFactory.createGetServiceCategoryListRequest(url: url)
    }
}
