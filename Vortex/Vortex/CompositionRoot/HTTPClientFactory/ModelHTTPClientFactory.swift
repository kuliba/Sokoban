//
//  ModelHTTPClientFactory.swift
//  Vortex
//
//  Created by Igor Malyarov on 24.06.2024.
//

import VortexTools
import Foundation

final class ModelHTTPClientFactory {
    
    let logger: LoggerAgentProtocol
    let model: Model
    
    init(
        logger: LoggerAgentProtocol,
        model: Model
    ) {
        self.model = model
        self.logger = logger
    }
}

extension ModelHTTPClientFactory: HTTPClientFactory {
    
    func makeHTTPClient() -> HTTPClient {
        
        let httpClient = model.authenticatedHTTPClient()
        
        let isBlacklisted: (URLRequest, Int) -> Bool = { _,_ in false }
        
        return AnyLoader(httpClient.performRequest(_:completion:))
            .blacklisted(isBlacklisted: isBlacklisted)
            .mapError(\.error)
    }
}

extension AnyLoader: HTTPClient
where Payload == Request,
      Response == Result<(Data, HTTPURLResponse), Error> {
    
    public func performRequest(
        _ request: Request,
        completion: @escaping Completion
    ) {
        load(request, completion)
    }
}

private extension BlacklistDecorator.Error {
    
    var error: Error {
        
        switch self {
        case .blacklistedError:
            return BlacklistedError()//NSError(domain: "BlacklistedError", code: 1, userInfo: nil)
            
        case .loadFailure(let error):
            return error
        }
    }
    
    struct BlacklistedError: Error {}
}
