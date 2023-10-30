//
//  LiveCVVPINJSONMaker.swift
//  ForaBank
//
//  Created by Igor Malyarov on 29.10.2023.
//

import CryptoKit
import CVVPIN_Services
import ForaCrypto
import Foundation

struct LiveCVVPINJSONMaker {
    
    let crypto: CVVPINCrypto
}

/// Used if `AuthenticateWithPublicKeyService`
extension LiveCVVPINJSONMaker {
    
    typealias RSAKeyPair = RSADomain.KeyPair

    func makeRequestJSON(
        publicKey: P384KeyAgreementDomain.PublicKey,
        rsaKeyPair: RSAKeyPair
    ) throws -> Data {
        
        // signature это хеш рассчитанный по алгоритму SHA256 от конкатенированных строк clientPublicKeyRSA (CLIENT-PUBLIC-KEY) и publicApplicationSessionKey (PaS) зашифрованный с помощью CLIENT-SECRET-KEY
        
        // Пример для Kotlin:
        //      val privateKeyBA = Base64.decode(
        //          cryptoStorageRead(ctx, "RSAClientPrivateKey"),
        //          Base64.NO_WRAP
        //      )
        //      val keySpec = PKCS8EncodedKeySpec(privateKeyBA)
        //      val keyFactory = KeyFactory.getInstance("RSA")
        //      val privateKey = keyFactory.generatePrivate(keySpec)
        //      val signer = Signature.getInstance("SHA256withRSA")
        //      signer.initSign(privateKey, SecureRandom())
        //      signer.update(hashSHA256)
        //      val signature = signer.sign()
        //      return Base64.encodeToString(signature, Base64.NO_WRAP)
        
        let rsaPublicKeyData = try crypto.x509Representation(publicKey: rsaKeyPair.publicKey)
        let rsaPublicKeyBase64 = rsaPublicKeyData.base64EncodedString()
        
        let keyData = publicKey.derRepresentation
        let publicApplicationSessionKeyBase64 = keyData.base64EncodedString()
        
        let concat = rsaPublicKeyBase64 + publicApplicationSessionKeyBase64
        let concatData = Data(concat.utf8)
        let hash = SHA256
            .hash(data: concatData)
            .withUnsafeBytes { Data($0) }
#warning("move signNoHash to type field")
        let signature = try ForaCrypto.Crypto.signNoHash(
            hash,
            withPrivateKey: rsaKeyPair.privateKey.key,
            algorithm: .rsaSignatureDigestPKCS1v15Raw
        )
        
        // Поскольку clientPublicKeyRSA и открытый ECDH-ключ (PaS) это бинарные величины, то JSON запроса (requestJSON) содержит их закодированными в формате BASE64 в полях clientPublicKeyRSA и publicApplicationSessionKey:
        //   - clientPublicKeyRSA открытый RSA-ключ клиента переданный в Процессинг на этапе активации функционала CVV-PIN
        //   - publicApplicationSessionKey сессионный открытый ключ приложения PaS
        //   - signature цифровая подпись запроса
        //
        //     {
        //         "clientPublicKeyRSA": "EFk57aH...f0wYHKxA==",                   // String(1024): BASE64 encoded CLIENT-PUBLIC-KEY
        //         "publicApplicationSessionKey": "MFkwEwYHK...fFkhMr57aH/0xA==",  // String(1024): BASE64 encoded зашифрованный PaS
        //         "signature": "YHK09fFkhM...f0wYHKxA=="                          // String(1024): BASE64-строка с цифровой подписью
        //     }
        
        let data = try JSONSerialization.data(withJSONObject: [
            "clientPublicKeyRSA": rsaPublicKeyBase64,
            "publicApplicationSessionKey": publicApplicationSessionKeyBase64,
            "signature": signature.base64EncodedString()
        ] as [String: String])
        
        return data
    }
}

/// used in `bindPublicKeyWithEventId`
/// based on`BindPublicKeySecretJSONMaker`
extension LiveCVVPINJSONMaker {
    
    func makeSecretJSON(
        otp: String,
        sessionKey: SessionKey
    ) throws -> (
        data: Data,
        keyPair: RSAKeyPair
    ) {
        // В момент шифрования может возникнуть exception DATA_TOO_LARGE_FOR_MODULUS
        //
        // Данная ошибка означает, что число, которое представляет собой зашифрованный ОТР-код, слишком большое (т.е. CLIENT-SECRET-OTP >= p * q) для RSA-ключа, которым выполняется шифрование.
        //
        // Поэтому нужно сгенерировать новую пару, которыми будет повторно зашифрован тот же самый ОТР-код, но с вероятностью близкой к 100% этой ошибки уже не возникнет, поскольку p и q будут другими.
        let (encryptedSignedOTP, publicKey, privateKey) = try retry {
            
            let (privateKey, publicKey) = try crypto.generateRSA4096BitKeyPair()
            let encryptedSignedOTP = try crypto.signEncryptOTP(
                otp: otp,
                privateKey: privateKey
            )
            
            return (encryptedSignedOTP, publicKey, privateKey)
        }
        
        let publicKeyX509Representation = try crypto.x509Representation(publicKey: publicKey)
        
        let procClientSecretOTP = encryptedSignedOTP.base64EncodedString()
        let clientPublicKeyRSA = publicKeyX509Representation.base64EncodedString()
        
        let json = try JSONSerialization.data(withJSONObject: [
            "procClientSecretOTP": procClientSecretOTP,
            "clientPublicKeyRSA": clientPublicKeyRSA
        ] as [String: String])
        
        let data = try crypto.aesEncrypt(
            data: json,
            sessionKey: sessionKey
        )
        
        return (data, (privateKey, publicKey))
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
        publicKey: P384KeyAgreementDomain.PublicKey
    ) throws -> Data {
        
        // see Services+keyExchangeService.swift:20
        let keyData = try crypto.publicKeyData(forPublicKey: publicKey)
        let data = try JSONSerialization.data(withJSONObject: [
            "publicApplicationSessionKey": keyData.base64EncodedString()
        ] as [String: String])
        let encrypted = try crypto.transportEncrypt(data: data)
        
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
        otpEventID: ChangePINService.OTPEventID
    ) throws -> Data {
        
#warning("replace with own implementation")
        
        let maker = ChangePINSecretJSONMaker.loggingLive
        let json = try maker.makePINChangeJSON(
            sessionID: sessionID,
            cardID: .init(value: cardID.cardIDValue),
            otp: .init(value: otp.otpValue),
            pin: .init(value: pin.pinValue),
            eventID: otpEventID
        )
        
        return json
    }
}

/// `ShowCVV`
extension LiveCVVPINJSONMaker {
    
    func makeSecretJSON(
        with cardID: ShowCVVService.CardID,
        and sessionID: ShowCVVService.SessionID,
        rsaKeyPair: RSAKeyPair,
        sessionKey: SessionKey
    ) throws -> Data {
        
        #warning("move to crypto")
        let hashSignVerify = ShowCVVCrypto.hashSignVerify(string:publicKey:privateKey:)
        
        let concatenation = "\(cardID.cardIDValue)" + sessionID.sessionIDValue
        let signature = try hashSignVerify(
            concatenation,
            rsaKeyPair.publicKey.key,
            rsaKeyPair.privateKey.key
        )
        let signatureBase64 = signature.base64EncodedString()
        
        let json = try JSONSerialization.data(withJSONObject: [
            // int(11)
            "cardId": "\(cardID.cardIDValue)",
            // String(40)
            "sessionId": sessionID.sessionIDValue,
            // String(1024): BASE64-строка с цифровой подписью
            "signature": signatureBase64
        ] as [String: String])
        
        let encrypted = try crypto.aesEncrypt(
            data: json,
            sessionKey: sessionKey
        )
        
        return encrypted
    }
}
