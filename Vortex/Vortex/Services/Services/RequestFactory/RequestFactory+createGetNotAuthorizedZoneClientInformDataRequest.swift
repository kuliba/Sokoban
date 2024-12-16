//
//  RequestFactory+createGetNotAuthorizedZoneClientInformDataRequest.swift
//  Vortex
//
//  Created by Nikolay Pochekuev on 29.10.2024.
//

import Foundation
import URLRequestFactory
import RemoteServices

extension RequestFactory {
    
    static func createGetNotAuthorizedZoneClientInformDataRequest() -> URLRequest {
        
        let base = Config.serverAgentEnvironment.baseURL
        let endpoint = Services.Endpoint.getNotAuthorizedZoneClientInform
        let url = try! endpoint.url(withBase: base)
        
        let request = RemoteServices.RequestFactory.createGetNotAuthorizedZoneClientInformData(url: url)
        return request
    }
}
