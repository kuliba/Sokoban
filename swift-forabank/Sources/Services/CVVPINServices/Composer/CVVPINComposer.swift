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
    public typealias Infra = CVVPINInfra<EventID, RSAPublicKey, RSAPrivateKey, SessionID, SymmetricKey>
    public typealias Remote = CVVPINRemote<RemoteCVV, SessionID, ChangePINAPIError, KeyServiceAPIError, ShowCVVAPIError>
    
    public let crypto: Crypto
    public let infra: Infra
    public let remote: Remote
    
    public init(
        crypto: Crypto,
        infra: Infra,
        remote: Remote
    ) {
        self.crypto = crypto
        self.infra = infra
        self.remote = remote
    }
}
