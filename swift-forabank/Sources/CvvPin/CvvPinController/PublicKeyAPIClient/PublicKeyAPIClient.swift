//
//  PublicKeyAPIClient.swift
//  
//
//  Created by Igor Malyarov on 16.07.2023.
//

public protocol PublicKeyAPIClient {
    
    typealias Result = Swift.Result<(SessionID, APISymmetricKey), Error>
    typealias SendPublicKeyCompletion = (Result) -> Void
    
    func sendPublicKey(
        _ symmetricKey: APISymmetricKey,
        completion: @escaping SendPublicKeyCompletion
    )
}
