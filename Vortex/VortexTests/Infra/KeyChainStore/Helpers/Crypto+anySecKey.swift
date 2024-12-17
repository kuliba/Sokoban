//
//  Crypto+anySecKey.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 14.10.2023.
//

import ForaCrypto
import Foundation

func anySecKey(
    _ keyClass: Crypto.KeyClass
) throws -> SecKey {
    
    let pair = try Crypto.generateKeyPair(
        keyType: .rsa,
        keySize: .bits4096,
        isPermanent: true
    )
    
    switch keyClass {
    case .publicKey:
        return pair.publicKey
        
    case .privateKey:
        return pair.privateKey
    }
}
