//
//  CVVPINComposer.swift
//  
//
//  Created by Igor Malyarov on 09.10.2023.
//

import Foundation

public final class CVVPINComposer<CardID, CVV, ECDHPublicKey, ECDHPrivateKey, EventID, OTP, PIN, RemoteCVV, RSAPublicKey, RSAPrivateKey, SessionID, SymmetricKey> {
    
    public typealias Crypto = CVVPINCrypto<ECDHPublicKey, ECDHPrivateKey, RSAPublicKey, RSAPrivateKey, SymmetricKey>
    public typealias Infra = CVVPINInfra<CardID, EventID, OTP, PIN, RemoteCVV, RSAPublicKey, RSAPrivateKey, SessionID, SymmetricKey>
    
    let crypto: Crypto
    let infra: Infra
    
    public init(
        crypto: Crypto,
        infra: Infra
    ) {
        self.crypto = crypto
        self.infra = infra
    }
}
