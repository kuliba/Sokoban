//
//  SymmetricCrypto.swift
//  
//
//  Created by Igor Malyarov on 16.07.2023.
//

public protocol SymmetricKeyService {
    
    typealias Result = Swift.Result<SymmetricKey, Error>
    typealias SymmetricKeyCompletion = (Result) -> Void
    
    func makeSymmetricKey(
        with sessionCode: CryptoSessionCode,
        completion: @escaping SymmetricKeyCompletion
    )
}
