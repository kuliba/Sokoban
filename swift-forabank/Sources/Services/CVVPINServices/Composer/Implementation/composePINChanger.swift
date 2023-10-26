//
//  composePINChanger.swift
//  
//
//  Created by Igor Malyarov on 10.10.2023.
//

import Foundation

// MARK: - Change PIN

extension CVVPINComposer
where CardID: RawRepresentable<Int>,
      EventID: RawRepresentable<String>,
      OTP: RawRepresentable<String>,
      PIN: RawRepresentable<String>,
      SessionID: RawRepresentable<String> {
    
    public typealias PINChanger = ChangePINService<ChangePINAPIError, CardID, EventID, OTP, PIN, RSAPrivateKey, SessionID, SymmetricKey>
    typealias PINRequestMaker = SecretPINRequestMaker<CardID, EventID, OTP, PIN, SessionID, SymmetricKey>
    
    func composePINChanger() -> PINChanger {
        
        let pinRequestMaker = PINRequestMaker(crypto: .init(
            aesEncrypt: crypto.aesEncrypt,
            encryptWithProcessingPublicRSAKey: crypto.encryptWithProcessingPublicRSAKey,
            sha256Hash: crypto.sha256Hash
        ))
        
        return .init(
            infra: .init(
                loadSessionID: infra.loadSessionID,
                loadSymmetricKey: infra.loadSymmetricKey,
                loadEventID: infra.loadEventID,
                process: remote.changePINProcess
            ),
            makePINChangeJSON: pinRequestMaker.makePINChangeJSON,
            makeSecretPINRequest: pinRequestMaker.makeSecretPIN
        )
    }
}
