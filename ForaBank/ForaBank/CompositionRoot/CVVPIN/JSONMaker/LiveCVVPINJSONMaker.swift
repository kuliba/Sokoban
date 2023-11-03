//
//  LiveCVVPINJSONMaker.swift
//  ForaBank
//
//  Created by Igor Malyarov on 29.10.2023.
//

import CryptoKit
import CVVPIN_Services
import Foundation

struct LiveCVVPINJSONMaker {
    
    let crypto: CVVPINCrypto
}

extension LiveCVVPINJSONMaker {
    
    typealias ECDHPublicKey = ECDHDomain.PublicKey
    typealias RSAKeyPair = RSADomain.KeyPair
    typealias RSAPrivateKey = RSADomain.PrivateKey
}

/// Used if `AuthenticateWithPublicKeyService`
extension LiveCVVPINJSONMaker {
    
    func makeRequestJSON(
        publicKey: ECDHPublicKey,
        rsaKeyPair: RSAKeyPair
    ) throws -> Data {
        
        let rsaPublicKeyData = try crypto.x509Representation(
            publicKey: rsaKeyPair.publicKey
        )
        let clientPublicKeyRSA = rsaPublicKeyData.base64EncodedString()
        
        let ecdhPublicKeyData = try crypto.publicKeyData(
            forPublicKey: publicKey
        )
        let publicApplicationSessionKey = ecdhPublicKeyData.base64EncodedString()
        
        let concat = clientPublicKeyRSA + publicApplicationSessionKey
        let signed = try crypto.sign(
            data: .init(concat.utf8),
            withPrivateKey: rsaKeyPair.privateKey
        )
        let signature = signed.base64EncodedString()
        
        let data = try JSONSerialization.data(withJSONObject: [
            "clientPublicKeyRSA": clientPublicKeyRSA,
            "publicApplicationSessionKey": publicApplicationSessionKey,
            "signature": signature
        ] as [String: String])
        
        return data
    }
}

/// used in `bindPublicKeyWithEventId`
extension LiveCVVPINJSONMaker {
    
    func makeSecretJSON(
        otp: String,
        sessionKey: SessionKey
    ) throws -> (
        data: Data,
        keyPair: RSAKeyPair
    ) {
        /// В момент шифрования может возникнуть exception DATA_TOO_LARGE_FOR_MODULUS
        ///
        /// Данная ошибка означает, что число, которое представляет собой зашифрованный ОТР-код, слишком большое (т.е. CLIENT-SECRET-OTP >= p * q) для RSA-ключа, которым выполняется шифрование.
        ///
        /// Поэтому нужно сгенерировать новую пару, которыми будет повторно зашифрован тот же самый ОТР-код, но с вероятностью близкой к 100% этой ошибки уже не возникнет, поскольку p и q будут другими.
        let (encryptedSignedOTP, rsaPrivateKey, rsaPublicKey) = try retry {
            
            let (rsaPrivateKey, rsaPublicKey) = try crypto.generateRSA4096BitKeyPair()
            let clientSecretOTP = try crypto.signNoHash(
                .init(otp.utf8),
                withPrivateKey: rsaPrivateKey
            )
            
            let procClientSecretOTP = try crypto.transportEncryptNoPadding(
                data: clientSecretOTP
            )
            
            return (procClientSecretOTP, rsaPrivateKey, rsaPublicKey)
        }
        
        let rsaPublicKeyData = try crypto.x509Representation(
            publicKey: rsaPublicKey
        )
        
        let procClientSecretOTP = encryptedSignedOTP.base64EncodedString()
        let clientPublicKeyRSA = rsaPublicKeyData.base64EncodedString()
        
        let json = try JSONSerialization.data(withJSONObject: [
            "procClientSecretOTP": procClientSecretOTP,
            "clientPublicKeyRSA": clientPublicKeyRSA
        ] as [String: String])
        
        let data = try crypto.aesEncrypt(
            data: json,
            sessionKey: sessionKey
        )
        
        return (data, (rsaPrivateKey, rsaPublicKey))
    }
}

private func retry<T>(
    attempts retryAttempts: Int = 1,
    action: () throws -> T
) rethrows -> T {
    
    do {
        return try action()
    } catch {
        guard retryAttempts > 0 else { throw error }
        
        return try retry(attempts: retryAttempts - 1, action: action)
    }
}

/// `formSessionKey`
extension LiveCVVPINJSONMaker {
    
    func makeSecretRequestJSON(
        publicKey: ECDHPublicKey
    ) throws -> Data {
        
        let publicKeyData = try crypto.publicKeyData(forPublicKey: publicKey)
        let publicApplicationSessionKeyBase64 = publicKeyData.base64EncodedString()
        
        let data = try JSONSerialization.data(withJSONObject: [
            "publicApplicationSessionKey": publicApplicationSessionKeyBase64
        ] as [String: String])
        
        let encrypted = try crypto.transportEncryptWithPadding(data: data)
        
        return encrypted
    }
}

/// `ChangePINCrypto`
extension LiveCVVPINJSONMaker {
    
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
        sessionID: ChangePINService.SessionID,
        cardID: ChangePINService.CardID,
        otp: ChangePINService.OTP,
        pin: ChangePINService.PIN,
        otpEventID: ChangePINService.OTPEventID,
        sessionKey: SessionKey,
        rsaPrivateKey: RSAPrivateKey
    ) throws -> Data {
        
        let sessionID = sessionID.sessionIDValue
        let cardID = "\(cardID.cardIDValue)"
        let otpCode = otp.otpValue
        let otpEventID = otpEventID.eventIDValue
        
        let secretPINData = try crypto.processingEncryptWithPadding(
            data: .init(pin.pinValue.utf8)
        )
        let secretPIN = secretPINData.base64EncodedString()
        
        let concat = sessionID + cardID + otpCode + otpEventID + secretPIN
        let signed = try crypto.sign(
            data: .init(concat.utf8),
            withPrivateKey: rsaPrivateKey
        )
        let signature = signed.base64EncodedString()
        
        let json = try JSONSerialization.data(withJSONObject: [
            "sessionId": sessionID, // String(40)
            "cardId":    cardID, // int(11)
            "otpCode":   otpCode, // String(6)
            "eventId":   otpEventID, // String(40)
            "secretPIN": secretPIN, // String(1024)
            "signature": signature // String(1024)
        ] as [String: String])
        
        let encrypted = try crypto.aesEncrypt(
            data: json,
            sessionKey: sessionKey
        )
        
        return encrypted
    }
}

extension LiveCVVPINJSONMaker {
    
    func makeShowCVVSecretJSON(
        with cardID: ShowCVVService.CardID,
        and sessionID: ShowCVVService.SessionID,
        rsaKeyPair: RSAKeyPair,
        sessionKey: SessionKey
    ) throws -> Data {
        
        let cardID = "\(cardID.cardIDValue)"
        let sessionID = sessionID.sessionIDValue
        
        let signedHash = try crypto.hashSignVerify(
            string: cardID + sessionID,
            publicKey: rsaKeyPair.publicKey,
            privateKey: rsaKeyPair.privateKey
        )
        let signature = signedHash.base64EncodedString()
        
        let json = try JSONSerialization.data(withJSONObject: [
            "cardId":    cardID,
            "sessionId": sessionID,
            "signature": signature
        ] as [String: String])
        
        let encrypted = try crypto.aesEncrypt(
            data: json,
            sessionKey: sessionKey
        )
        
        return encrypted
    }
}
