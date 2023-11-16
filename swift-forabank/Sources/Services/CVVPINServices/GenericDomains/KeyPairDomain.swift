//
//  KeyPairDomain.swift
//  
//
//  Created by Igor Malyarov on 02.10.2023.
//

/// A namespace.
public enum KeyPairDomain<PublicKey, PrivateKey> {}

public extension KeyPairDomain {
    
    typealias KeyPair = (publicKey: PublicKey, privateKey: PrivateKey)
    typealias Get = () throws -> KeyPair
    
    // MARK: - Async
    typealias Success = KeyPair
    typealias Failure = Error
    typealias Result = Swift.Result<Success, Failure>
    typealias Completion = (Result) -> Void
    typealias AsyncGet = (@escaping Completion) -> Void
}
