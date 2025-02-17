//
//  RequestFactory+createGetBannersMyProductListV2Request.swift
//  Vortex
//
//  Created by Andryusina Nataly on 17.02.2025.
//

import Foundation
import RemoteServices
import GetBannersMyProductListService

extension RequestFactory {
  
    // TODO: add tests
    
    static func createGetBannersMyProductListV2Request(
        _ serial: String?,
        _ timeout: TimeInterval = 120.0
    ) throws -> URLRequest {
        
        let parameters: [(String, String)] = [
            ("serial", serial ?? "")
        ]

        let endpoint = Services.Endpoint.getBannersMyProductListV2
        let url = try! endpoint.url(
            withBase: Config.serverAgentEnvironment.baseURL,
            parameters: parameters
        )
        
        return try RemoteServices.RequestFactory.createGetBannersMyProductListRequest(serial: serial, url: url)
    }
}
