//
//  APIClient.swift
//  
//
//  Created by Igor Malyarov on 13.07.2023.
//

import Foundation

public protocol APIClient<Payload, ServerStatusCode> {
    
    associatedtype Payload: Decodable
    associatedtype ServerStatusCode: Decodable
    
    typealias Response = API.ServerResponse<Payload, ServerStatusCode>
    typealias Completion = (Result<Response, Error>) -> Void
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func data(
        _ data: APIRequest,
        completion: @escaping Completion
    )
}

public extension APIClient {
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func data(
        completion: @escaping Completion
    ) {
        data(.empty, completion: completion)
    }
}

public enum APIRequest: Equatable {
    
    case empty
}
