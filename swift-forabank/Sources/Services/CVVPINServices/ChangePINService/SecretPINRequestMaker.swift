//
//  SecretPINRequestMaker.swift
//  
//
//  Created by Igor Malyarov on 05.10.2023.
//

import Foundation

public struct SecretPINRequestMaker<CardID, EventID, OTP, PIN, SessionID, SymmetricKey>
where SessionID: RawRepresentable<String>,
      CardID: RawRepresentable<Int>,
      EventID: RawRepresentable<String>,
      OTP: RawRepresentable<String>,
      PIN: RawRepresentable<String> {
    
    public typealias Crypto = ChangePINCrypto<SymmetricKey>
    
    private let crypto: Crypto
    
    public init(crypto: Crypto) {
        
        self.crypto = crypto
    }
}

public extension SecretPINRequestMaker {
    
    typealias PINChangeJSON = Data
    
    #warning("actually this pattern is reused in many places. consider generalising it")
    func makeSecretPIN(
        sessionID: SessionID,
        pinChangeJSON: PINChangeJSON,
        symmetricKey key: SymmetricKey
    ) throws -> Data {
        
        let encrypted = try crypto.aesEncrypt(pinChangeJSON, key)
        let json = try JSONSerialization.data(withJSONObject: [
            "sessionId": sessionID.rawValue,
            "data": encrypted.base64EncodedString()
        ])
        
        return json
    }
}

public extension SecretPINRequestMaker {
    
    /// Запрос PIN-CHANGE-JSON содержит:
    ///
    /// - `sessionID` - (SID) уникальный идентификатор сессии
    /// - `cardId` - идентификатор карты в АБС и ПЦ вида 10020230949 (int(11))
    /// - `otpCode` - ОТР-код подтверждения операции по смене PIN-кода
    /// - `eventId` - уникальный ID события проверки OTP-кода
    /// - `secretPIN` - зашифрованный ПИН-код введенный клиентом (SECRET-PIN)
    /// - `signature` - ЭЦП запроса (SHA256 хеш-сумма рассчитанная от sessionID + cardId + otpCode + eventId + secretPIN зашифрованный закрытым RSA-ключом клиента RSA-CLIENT-SECRET-KEY):
    ///
    /// {
    ///     "sessionId": "42c14881-19de-42d4-95a3-502e2ed466cd", // String(40)
    ///     "cardId": 1212098777373, // int(11)
    ///     "otpCode": "123456", // String(6)
    ///     "eventId": "6cc1e2ed4881-15ae-42d4-99d3-50248814642d", // String(40)
    ///     "secretPIN": "0LLQu9GE0YvRg...tGE0YvQstGA0LA=", // String(1024)
    ///     "signature": "YHK09fFkhM...f0wYHKxA==" // String(1024)
    /// }
    func makePINChangeJSON(
        sessionID: SessionID,
        cardID: CardID,
        otp: OTP,
        pin: PIN,
        eventID: EventID
    ) throws -> Data {
        
        let secretPIN = try crypto.encryptWithProcessingPublicRSAKey(.init(pin.rawValue.utf8))
        let concat = sessionID.rawValue + "\(cardID.rawValue)" + otp.rawValue + eventID.rawValue + secretPIN.base64EncodedString()
        let signature = crypto.sha256Hash(concat)
        
        let json = try JSONSerialization.data(withJSONObject: [
            "sessionId": sessionID.rawValue, // String(40)
            "cardId":    cardID.rawValue, // int(11)
            "otpCode":   otp.rawValue, // String(6)
            "eventId":   eventID.rawValue, // String(40)
            "secretPIN": secretPIN.base64EncodedString(), // String(1024)
            "signature": signature.base64EncodedString() // String(1024)
        ] as [String: Any])
        
        return json
    }
}

public struct ChangePINCrypto<SymmetricKey> {
    
    public typealias AESEncrypt = (Data, SymmetricKey) throws -> Data
    public typealias EncryptWithProcessingPublicRSAKey = (Data) throws -> Data
    public typealias SHA256Hash = (String) -> Data
    
    let aesEncrypt: AESEncrypt
    let encryptWithProcessingPublicRSAKey: EncryptWithProcessingPublicRSAKey
    let sha256Hash: SHA256Hash
    
    public init(
        aesEncrypt: @escaping AESEncrypt,
        encryptWithProcessingPublicRSAKey: @escaping EncryptWithProcessingPublicRSAKey,
        sha256Hash: @escaping SHA256Hash
    ) {
        self.aesEncrypt = aesEncrypt
        self.encryptWithProcessingPublicRSAKey = encryptWithProcessingPublicRSAKey
        self.sha256Hash = sha256Hash
    }
}
