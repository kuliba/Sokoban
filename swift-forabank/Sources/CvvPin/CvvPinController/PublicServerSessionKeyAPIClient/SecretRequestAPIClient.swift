//
//  SecretRequestAPIClient.swift
//  
//
//  Created by Igor Malyarov on 18.07.2023.
//

public protocol PublicServerSessionKeyAPIClient {
    
    typealias Result = Swift.Result<PublicServerSessionKeyPayload, Error>
    typealias Completion = (Result) -> Void
    
    func get(
        _ request: SecretRequest,
        completion: @escaping Completion
    )
}
