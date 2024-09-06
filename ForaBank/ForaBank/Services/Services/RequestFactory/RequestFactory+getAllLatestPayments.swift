//
//  RequestFactory+getAllLatestPaymentsV2.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 13.05.2024.
//

import Foundation
import RemoteServices

extension RequestFactory {
    
    static func createGetAllLatestPaymentsV2Request(
        _ kind: LatestPaymentKind
    ) -> URLRequest {
        
        let parameters: [(String, String)] = [
            kind.parameterService()
        ]
        
        let endpoint = Services.Endpoint.getAllLatestPaymentsV2
        let url = try! endpoint.url(
            withBase: Config.serverAgentEnvironment.baseURL,
            parameters: parameters
        )
        
        return RemoteServices.RequestFactory.createEmptyRequest(.get, with: url)
    }
}
