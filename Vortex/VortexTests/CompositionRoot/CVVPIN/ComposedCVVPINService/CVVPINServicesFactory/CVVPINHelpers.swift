//
//  CVVPINHelpers.swift
//  VortexTests
//
//  Created by Igor Malyarov on 11.11.2023.
//

import CVVPIN_Services
import VortexCrypto
@testable import Vortex

func anyTransportKeyResult() ->
Result<LiveExtraLoggingCVVPINCrypto.TransportKey, Error> {
    
    Result {
        
        try VortexCrypto.Crypto.generateKeyPair(keyType: .rsa, keySize: .bits4096)
    }
    .map(\.publicKey)
    .map(LiveExtraLoggingCVVPINCrypto.TransportKey.init(key:))
}

func anyProcessingKeyResult() ->
Result<LiveExtraLoggingCVVPINCrypto.ProcessingKey, Error> {
    
    Result {
        
        try VortexCrypto.Crypto.generateKeyPair(
            keyType: .rsa,
            keySize: .bits4096
        )
    }
    .map(\.publicKey)
    .map(LiveExtraLoggingCVVPINCrypto.ProcessingKey.init(key:))
}

func anyRSAKeyPair() throws -> RSADomain.KeyPair {
    
    let (publicKey, privateKey) = try VortexCrypto.Crypto.generateKeyPair(
        keyType: .rsa,
        keySize: .bits4096
    )
    
    return (privateKey: .init(key: privateKey), publicKey: .init(key: publicKey))
}

