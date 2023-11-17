//
//  composePublicKeyAuth.swift
//  
//
//  Created by Igor Malyarov on 10.10.2023.
//

import Foundation

// MARK: - Public Key Authentication

public extension CVVPINComposer
where ECDHPublicKey: Base64StringEncodable,
      RSAPublicKey: Base64StringEncodable,
      SessionID == PublicKeyAuthenticationResponse.SessionID {
    
    typealias PublicKeyAuth = PublicKeyAuthenticator<KeyServiceAPIError, RSAPublicKey, RSAPrivateKey>
    
    func composePublicKeyAuth(
        currentDate: @escaping () -> Date = Date.init
    ) -> PublicKeyAuth {
        
        typealias Mapper = PublicKeyAuthenticationResponseMapper<ECDHPrivateKey, SymmetricKey>
        
        let mapper = Mapper(
            publicTransportDecrypt: crypto.publicTransportDecrypt,
            makeSymmetricKey: crypto.makeSymmetricKey
        )
        let infra = self.infra
        let cachingMapper = PublicKeyAuthenticationResponseMapperDecorator(
            decoratee: mapper,
            save: { symmetricKey, sessionID, ttl in
                
                let validUntil = currentDate() + ttl
                
                infra.saveSessionID(sessionID, validUntil)
                infra.saveSymmetricKey(symmetricKey, validUntil)
            }
        )
        
        typealias Exchange = KeyExchange<KeyServiceAPIError, ECDHPublicKey, ECDHPrivateKey, RSAPublicKey, RSAPrivateKey, SymmetricKey>
        
        let keyExchange = Exchange(
            makeECDHKeyPair: crypto.makeECDHKeyPair,
            sign: crypto.sign,
            process: remote.keyAuthProcess,
            makeSymmetricKey: cachingMapper.makeSymmetricKey
        )
        
        return .init(
            infra: .init(
                loadRSAKeyPair: infra.loadRSAKeyPair,
                loadSessionKeyWithEvent: infra.loadSessionKeyWithEvent
            ),
            exchangeKeys: keyExchange.exchangeKeysVoid
        )
    }
}

// MARK: - Adapter

private extension KeyExchange {
    
    func exchangeKeysVoid(
        keyPair: (publicKey: RSAPublicKey, privateKey: RSAPrivateKey),
        completion: @escaping (Swift.Result<Void, KeyExchangeError<APIError>>) -> Void
    ) {
        exchangeKeys(
            rsaKeyPair: (keyPair.publicKey, keyPair.privateKey)
        ) { completion($0.map { _ in () }) }
    }
}
