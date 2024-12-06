//
//  HTTPClientFactorySpy.swift
//  VortexTests
//
//  Created by Igor Malyarov on 17.11.2024.
//

@testable import ForaBank

final class HTTPClientFactorySpy: HTTPClientFactory {
    
    func makeHTTPClient() -> any HTTPClient {
        
        HTTPClientSpy()
    }
}
