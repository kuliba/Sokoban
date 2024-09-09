//
//  RequestFactory+createGetAllLatestPaymentsV3Request.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 07.09.2024.
//

import Foundation
import LatestPaymentsBackendV3
import RemoteServices

extension RequestFactory {
    
    static func createGetAllLatestPaymentsV3Request(
        parameters: [String]
    ) throws -> URLRequest {
        
        let endpoint = Services.Endpoint.getAllLatestPaymentsV3
        let url = try! endpoint.url(
            withBase: Config.serverAgentEnvironment.baseURL
        )
        
        return try RemoteServices.RequestFactory.createGetAllLatestPaymentsRequest(parameters: parameters, url: url)
    }
}
