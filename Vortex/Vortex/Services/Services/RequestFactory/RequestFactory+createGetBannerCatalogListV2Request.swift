//
//  RequestFactory+createGetBannerCatalogListV2Request.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 02.09.2024.
//

import Foundation

extension RequestFactory {
    
    static func createGetBannerCatalogListV2Request(
        _ serial: String?,
        _ timeout: TimeInterval = 120.0
    ) throws -> URLRequest {
        
        let parameters: [(String, String)] = [
            ("serial", serial ?? "")
        ]

        let endpoint = Services.Endpoint.getBannerCatalogListV2
        let url = try! endpoint.url(
            withBase: Config.serverAgentEnvironment.baseURL,
            parameters: parameters
        )
        
        var request = URLRequest(url: url)
        request.timeoutInterval = timeout
        request.httpMethod = RequestMethod.get.rawValue
        
        return request
    }
}
