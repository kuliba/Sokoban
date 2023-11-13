//
//  TestHelpers.swift
//  
//
//  Created by Igor Malyarov on 02.10.2023.
//

import CVVPINServices
import Foundation

func anyError(_ domain: String = "any error") -> Error {
    
    NSError(domain: domain, code: -1)
}

func makeCardID(
    _ rawValue: Int = 987654321
) -> CardID {
    
    .init(rawValue: rawValue)
}

func makeEventID(
    _ rawValue: String = UUID().uuidString
) -> EventID {
    
    .init(rawValue: rawValue)
}

func makeECDHKeyPair(
    publicKeyValue: String = UUID().uuidString,
    privateKeyValue: String = UUID().uuidString
) -> ECDHKeyPairDomain.KeyPair {
    
    (.init(publicKeyValue), .init(privateKeyValue))
}

func makeOTP(
    _ rawValue: String = .init(UUID().uuidString.prefix(6))
) -> OTP {
    
    .init(rawValue: rawValue)
}

func makePIN(
    _ rawValue: String = .init(UUID().uuidString.prefix(4))
) -> PIN {
    
    .init(rawValue: rawValue)
}

func makePublicKeyAuthenticationResponse(
    publicServerSessionKeyValue: String = anyData().base64EncodedString(),
    sessionIDValue: String = UUID().uuidString,
    sessionTTLValue: TimeInterval = 5
) -> PublicKeyAuthenticationResponse {
    
    .init(
        publicServerSessionKey: .init(value: publicServerSessionKeyValue),
        sessionID: .init(value: sessionIDValue),
        sessionTTL: .init(sessionTTLValue)
    )
}

typealias RSAKeyPairDomain = KeyPairDomain<RSAPublicKey, RSAPrivateKey>

func makeRSAKeyPair(
    publicKeyValue: String = UUID().uuidString,
    privateKeyValue: String = UUID().uuidString
) -> RSAKeyPair {
    
    (.init(publicKeyValue), .init(privateKeyValue))
}

func makeRSAPrivateKey(
    _ rawValue: String = UUID().uuidString
) -> RSAPrivateKey {
    
    .init(rawValue)
}

func makeSessionID(
    _ rawValue: String = UUID().uuidString
) -> SessionID {
    
    .init(rawValue: rawValue)
}

func makeSessionKeyWithEvent(
    sessionKeyValue: String = UUID().uuidString,
    eventIDValue: String = UUID().uuidString,
    sessionTTLValue: TimeInterval = 5
) -> SessionKeyWithEvent {
    
    .init(
        sessionKey: .init(value: sessionKeyValue),
        eventID: .init(value: eventIDValue),
        sessionTTL: .init(value: sessionTTLValue)
    )
}

func makeSymmetricKey(
    _ value: String = UUID().uuidString
) -> SymmetricKey {
    
    .init(value)
}
