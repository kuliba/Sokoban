//
//  Model+cachelessAuthorizedHTTPClient.swift
//  Vortex
//
//  Created by Andryusina Nataly on 03.10.2023.
//

import Foundation

extension Model {
    
    func cachelessAuthorizedHTTPClient(
        httpClient: HTTPClient = HTTPFactory.cachelessLoggingNoSharedCookiesURLSessionHTTPClient()
    ) -> HTTPClient {
        
        AuthenticatedHTTPClientDecorator(
            decoratee: httpClient,
            tokenProvider: self,
            signRequest: signRequest
        )
    }
}
