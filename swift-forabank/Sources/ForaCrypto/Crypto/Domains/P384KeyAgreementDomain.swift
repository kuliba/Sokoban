//
//  P384KeyAgreementDomain.swift
//  
//
//  Created by Igor Malyarov on 17.08.2023.
//

import CryptoKit

/// A namespace.
public enum P384KeyAgreementDomain {}

public extension P384KeyAgreementDomain {
    
    typealias PrivateKey = P384.KeyAgreement.PrivateKey
    typealias PublicKey = P384.KeyAgreement.PublicKey
    typealias KeyPair = (privateKey: PrivateKey, publicKey: PublicKey)
    
    typealias SaveKey = (P384.KeyAgreement.PrivateKey) throws -> Void
    typealias GenerateKeyPair = () throws -> KeyPair
}
