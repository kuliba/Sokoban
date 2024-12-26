//
//  Model+signRequest.swift
//  Vortex
//
//  Created by Igor Malyarov on 01.08.2023.
//

import Foundation
import ServerAgent

extension Model {
    
    func signRequest(
        _ request: URLRequest,
        withToken token: TokenProvider.Token
    ) -> URLRequest {
        
        var request = request
        request.setValue(token, forHTTPHeaderField: "X-XSRF-TOKEN")
        
        // TODO: find a better place for this responsibility
        // cookies headers
        request.httpShouldHandleCookies = false
        let cookies = (serverAgent as? ServerAgent)?.cookies ?? []
        request.allHTTPHeaderFields = HTTPCookie.requestHeaderFields(with: cookies)
        
        // headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return request
    }
}
