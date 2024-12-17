//
//  CVVPINJSONMaker.swift
//  ForaBank
//
//  Created by Igor Malyarov on 29.10.2023.
//

import CVVPIN_Services
import ForaCrypto
import Foundation

// TODO: make generic to decouple from ForaCrypto & CVVPIN_Services
protocol CVVPINJSONMaker {
    
    typealias ECDHPublicKey = ECDHDomain.PublicKey
    typealias RSAKeyPair = RSADomain.KeyPair
    typealias RSAPrivateKey = RSADomain.PrivateKey

    /// Used if `AuthenticateWithPublicKeyService`
    func makeRequestJSON(
        publicKey: ECDHPublicKey,
        rsaKeyPair: RSAKeyPair
    ) throws -> Data
    
    /// used in `bindPublicKeyWithEventId`
    func makeSecretJSON(
        otp: String,
        sessionKey: SessionKey
    ) throws -> (
        data: Data,
        keyPair: RSAKeyPair
    )
    
    /// Used in `formSessionKey`.
    func makeSecretRequestJSON(
        publicKey: ECDHPublicKey
    ) throws -> Data
    
    /// `ChangePINCrypto`
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
    ) throws -> Data
    
    /// `ShowCVV`
    func makeShowCVVSecretJSON(
        with cardID: ShowCVVService.CardID,
        and sessionID: ShowCVVService.SessionID,
        rsaKeyPair: RSAKeyPair,
        sessionKey: SessionKey
    ) throws -> Data
}
