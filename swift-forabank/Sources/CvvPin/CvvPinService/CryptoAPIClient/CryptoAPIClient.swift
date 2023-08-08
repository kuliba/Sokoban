//
//  CryptoAPIClient.swift
//  
//
//  Created by Igor Malyarov on 19.07.2023.
//

public protocol CryptoAPIClient<Request, Response> {
    
    associatedtype Request
    associatedtype Response
    
    typealias Result = Swift.Result<Response, Error>
    typealias Completion = (Result) -> Void
    
    func get(
        _ request: Request,
        completion: @escaping Completion
    )
}
