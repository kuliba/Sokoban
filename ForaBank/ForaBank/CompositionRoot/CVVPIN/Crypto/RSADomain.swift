//
//  CVVPINCryptoDomain.swift
//  ForaBank
//
//  Created by Igor Malyarov on 30.10.2023.
//

import Foundation

/// A namespace.
enum RSADomain {
    
    typealias PrivateKey = RSAPrivateKey
    typealias PublicKey = RSAPublicKey
    typealias KeyPair = (privateKey: PrivateKey, publicKey: PublicKey)
}

extension RSADomain {
    
    struct RSAPrivateKey {
        
        let key: SecKey
    }
    
    struct RSAPublicKey {
        
        let key: SecKey
    }
}
