//
//  SymmetricCrypto.swift
//  
//
//  Created by Igor Malyarov on 16.07.2023.
//

public protocol SymmetricCrypto {
    
    typealias Payload = SymmetricCryptoPayload
    typealias Result = Swift.Result<SymmetricKey, Error>
    typealias SymmetricKeyCompletion = (Result) -> Void
    
    func makeSymmetricKey(
        with payload: Payload,
        completion: @escaping SymmetricKeyCompletion
    )
}
