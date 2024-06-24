//
//  HTTPClientFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 24.06.2024.
//

enum HTTPClientFactory {}

extension HTTPClientFactory {
    
    static func makeHTTPClient(
        with model: Model,
        logger: LoggerAgentProtocol
    ) -> HTTPClient {
        
        model.authenticatedHTTPClient()
    }
}
