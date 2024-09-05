//
//  RequestFactory+createGetServiceCategoryListRequest.swift
//  ForaBank
//
//  Created by Igor Malyarov on 13.08.2024.
//

import ServiceCategoriesBackend
import Foundation
import RemoteServices

extension ForaBank.RequestFactory {
    
    static func createGetServiceCategoryListRequest(
    ) throws -> URLRequest {
        
        let base = Config.serverAgentEnvironment.baseURL
        let endpoint = Services.Endpoint.getServiceCategoryList
        let endpointURL = try! endpoint.url(withBase: base)
        
        return try RemoteServices.RequestFactory.createGetServiceCategoryListRequest(url: endpointURL)
    }
}

