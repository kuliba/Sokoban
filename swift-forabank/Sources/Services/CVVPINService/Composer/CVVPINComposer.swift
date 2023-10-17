//
//  CVVPINComposer.swift
//  
//
//  Created by Igor Malyarov on 09.10.2023.
//

import Foundation

public final class CVVPINComposer<CardID, ChangePINAPIError, CVV, ECDHPublicKey, ECDHPrivateKey, EventID, KeyServiceAPIError, OTP, PIN, RemoteCVV, RSAPublicKey, RSAPrivateKey, SessionID, ShowCVVAPIError, SymmetricKey>
where ChangePINAPIError: Error,
      KeyServiceAPIError: Error,
      ShowCVVAPIError: Error {
    
    public typealias Crypto = CVVPINCrypto<ECDHPublicKey, ECDHPrivateKey, RSAPublicKey, RSAPrivateKey, SymmetricKey>
    public typealias Infra = CVVPINInfra<CardID, ChangePINAPIError, EventID, KeyServiceAPIError, OTP, PIN, RemoteCVV, RSAPublicKey, RSAPrivateKey, SessionID, ShowCVVAPIError, SymmetricKey>
    
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
