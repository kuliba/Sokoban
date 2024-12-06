//
//  RequestFactory+createGetAuthorizedZoneClientInformDataRequest.swift
//  Vortex
//
//  Created by Nikolay Pochekuev on 22.10.2024.
//

import Foundation
import URLRequestFactory
import RemoteServices

extension RequestFactory {
    
    static func createGetAuthorizedZoneClientInformDataRequest() -> URLRequest {
        
        let base = Config.serverAgentEnvironment.baseURL
        let endpoint = Services.Endpoint.getAuthorizedZoneClientInform
        let url = try! endpoint.url(withBase: base)
        
        let request = RemoteServices.RequestFactory.createGetAuthorizedZoneClientInformData(url: url)
        return request
    }
}
