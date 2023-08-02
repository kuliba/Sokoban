//
//  Services+getProcessingSessionCode.swift
//  ForaBank
//
//  Created by Igor Malyarov on 31.07.2023.
//

import GetProcessingSessionCodeService
extension Services {
    
    typealias GetProcessingSessionCode = GetProcessingSessionCodeService
    
    static func getProcessingSessionCode(
        httpClient: HTTPClient
    ) -> GetProcessingSessionCode {
        
        let endpoint = Services.Endpoint.getProcessingSessionCode
        let url = try! endpoint.url(withBase: Config.serverAgentEnvironment.baseURL)
        
        return GetProcessingSessionCodeService(
            url: url,
            performRequest: httpClient.perform(_:completion:)
        )
    }
}
