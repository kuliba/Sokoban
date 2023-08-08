//
//  Model+authorizedHTTPClient.swift
//  ForaBank
//
//  Created by Igor Malyarov on 01.08.2023.
//

import Foundation

extension Model {
    
    func authorizedHTTPClient(
        httpClient: HTTPClient = HTTPFactory.loggingNoSharedCookieStoreURLSessionHTTPClient()
    ) -> HTTPClient {
        
        AuthenticatedHTTPClientDecorator(
            decoratee: httpClient,
            tokenProvider: self,
            signRequest: signRequest
        )
    }
}
