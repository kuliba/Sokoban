//
//  KeyExchangeCryptographer+makeSecretRequestJSON.swift
//  ForaBank
//
//  Created by Igor Malyarov on 22.10.2023.
//

import Foundation
import ForaCrypto
import CryptoKit

extension KeyExchangeCryptographer {
    
    /// Used in `formSessionKey`.
    func makeSecretRequestJSON(
        publicKey: P384KeyAgreementDomain.PublicKey
    ) throws -> Data {
        
        // see Services+keyExchangeService.swift:20
        let keyData = try publicKeyData(publicKey)
        let data = try JSONSerialization.data(withJSONObject: [
            "publicApplicationSessionKey": keyData.base64EncodedString()
        ] as [String: String])
        let encrypted = try transportEncrypt(data)
        
        return encrypted
    }
    
    typealias RSAKeyPair = (publicKey: SecKey, privateKey: SecKey)
    
    /// Used in `authenticateWithPublicKey`.
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
        
        let rsaPublicKeyData = try rsaKeyPair.publicKey.x509Representation()
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
            withPrivateKey: rsaKeyPair.privateKey,
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
