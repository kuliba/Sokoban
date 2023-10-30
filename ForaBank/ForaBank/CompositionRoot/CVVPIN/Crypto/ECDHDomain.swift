//
//  ECDHDomain.swift
//  ForaBank
//
//  Created by Igor Malyarov on 30.10.2023.
//

import CryptoKit

enum ECDHDomain {
    
    typealias PrivateKey = P384.KeyAgreement.PrivateKey
    typealias PublicKey = P384.KeyAgreement.PublicKey
    typealias KeyPair = (privateKey: PrivateKey, publicKey: PublicKey)
}
