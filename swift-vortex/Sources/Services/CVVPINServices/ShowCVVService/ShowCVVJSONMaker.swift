//
//  ShowCVVJSONMaker.swift
//  
//
//  Created by Igor Malyarov on 03.10.2023.
//

import Foundation

public struct ShowCVVJSONMaker<CardID, RSAPublicKey, RSAPrivateKey, SessionID, SymmetricKey>
where CardID: RawRepresentable<Int>,
      SessionID: RawRepresentable<String> {
    
    public typealias HashSignVerify = (String, RSAPublicKey, RSAPrivateKey) throws -> Data
    public typealias AESEncrypt = (Data, SymmetricKey) throws -> Data
    
    private let hashSignVerify: HashSignVerify
    private let aesEncrypt: AESEncrypt
    
    public init(
        hashSignVerify: @escaping HashSignVerify,
        aesEncrypt: @escaping AESEncrypt
    ) {
        self.hashSignVerify = hashSignVerify
        self.aesEncrypt = aesEncrypt
    }
}

public extension ShowCVVJSONMaker {
    
    func makeSecretJSON(
        with cardID: CardID,
        and sessionID: SessionID,
        publicKey: RSAPublicKey,
        privateKey: RSAPrivateKey,
        symmetricKey: SymmetricKey
    ) throws -> Data {
        
        let json = try makeJSON(
            with: cardID,
            and: sessionID,
            publicKey: publicKey,
            privateKey: privateKey
        )
        let encrypted = try aesEncrypt(json, symmetricKey)
        let secretJSON = try makeSecretJSON(sessionID, encrypted)
        
        return secretJSON
    }
}

private extension ShowCVVJSONMaker {
    
    func makeJSON(
        with cardID: CardID,
        and sessionID: SessionID,
        publicKey: RSAPublicKey,
        privateKey: RSAPrivateKey
    ) throws -> Data {
        
        let concatenation = "\(cardID.rawValue)" + sessionID.rawValue
        let signature = try hashSignVerify(concatenation, publicKey, privateKey)
        let signatureBase64 = signature.base64EncodedString()
        
        let json = try JSONSerialization.data(withJSONObject: [
            // int(11)
            "cardId": "\(cardID.rawValue)",
            // String(40)
            "sessionId": sessionID.rawValue,
            // String(1024): BASE64-строка с цифровой подписью
            "signature": signatureBase64
        ] as [String: String])
        
        return json
    }
    
    func makeSecretJSON(
        _ sessionID: SessionID,
        _ data: Data
    ) throws -> Data {
        
        let json = try JSONSerialization.data(withJSONObject: [
            // String(40)
            "sessionId": sessionID.rawValue,
            // String(4096): BASE64
            "data": data.base64EncodedString()
        ] as [String: String])
        
        return json
    }
}
