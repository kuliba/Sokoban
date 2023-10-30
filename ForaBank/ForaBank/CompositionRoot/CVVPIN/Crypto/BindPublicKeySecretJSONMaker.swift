//
//  BindPublicKeySecretJSONMaker.swift
//  ForaBank
//
//  Created by Igor Malyarov on 23.10.2023.
//

import Foundation

#warning("delete `BindPublicKeySecretJSONMaker` - not used anymore")
final class BindPublicKeySecretJSONMaker<PublicKey, PrivateKey> {
    
    typealias LoadSessionKeyResult = Result<SessionKey, Error>
    typealias LoadSessionKeyCompletion = (LoadSessionKeyResult) -> Void
    typealias LoadSessionKey = (@escaping LoadSessionKeyCompletion) -> Void
    
    typealias SaveKeyPairResult = Result<Void, Error>
    typealias SaveKeyPairCompletion = (SaveKeyPairResult) -> Void
    typealias SaveKeyPair = ((PublicKey, PrivateKey), @escaping SaveKeyPairCompletion) -> Void

    typealias GenerateKeyPair = () throws -> (PrivateKey, PublicKey)
    typealias SignEncryptOTP = (String, PrivateKey) throws -> Data
    typealias X509Representation = (PublicKey) throws -> Data
    typealias AESEncrypt = (Data, SessionKey) throws -> Data

    private let loadSessionKey: LoadSessionKey
    private let saveKeyPair: SaveKeyPair
    
    private let generateKeyPair: GenerateKeyPair
    private let signEncryptOTP: SignEncryptOTP
    private let x509Representation: X509Representation
    private let aesEncrypt: AESEncrypt

    init(
        loadSessionKey: @escaping LoadSessionKey,
        saveKeyPair: @escaping SaveKeyPair,
        generateKeyPair: @escaping GenerateKeyPair,
        signEncryptOTP: @escaping SignEncryptOTP,
        x509Representation: @escaping X509Representation,
        aesEncrypt:  @escaping AESEncrypt
    ) {
        self.loadSessionKey = loadSessionKey
        self.saveKeyPair = saveKeyPair
        self.generateKeyPair = generateKeyPair
        self.signEncryptOTP = signEncryptOTP
        self.x509Representation = x509Representation
        self.aesEncrypt = aesEncrypt
    }
    
    typealias Completion = (Result<Data, Error>) -> Void
    
    func makeSecretJSON(
        otp: String,
        completion: @escaping Completion
    ) {
        loadSessionKey(otp, completion)
    }
}

private extension BindPublicKeySecretJSONMaker {
    
    func loadSessionKey(
        _ otp: String,
        _ completion: @escaping Completion
    ) {
        loadSessionKey { [weak self] result in
            
            guard let self else { return }
    
            switch result {
            case let .failure(error):
                completion(.failure(error))
                
            case let .success(sessionKey):
                makeJSON(with: otp, and: sessionKey, completion)
            }
        }
    }
    
    func makeJSON(
        with otp: String,
        and sessionKey: SessionKey,
        _ completion: @escaping Completion
    ) {
        do {
            let (encryptedSignedOTP, publicKey, privateKey) = try retrySignEncryptOTP(otp)
            
            saveKeyPair((publicKey, privateKey)) { [weak self] result in
                
                guard let self else { return }
                
                completion(.init {
                    
                    try self.make(sessionKey: sessionKey, publicKey: publicKey, encryptedSignedOTP: encryptedSignedOTP)
                })
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    func make(
        sessionKey: SessionKey,
        publicKey: PublicKey,
        encryptedSignedOTP: Data
    ) throws -> Data {
        
        let publicKeyX509Representation = try x509Representation(publicKey)
        
        let procClientSecretOTP = encryptedSignedOTP.base64EncodedString()
        let clientPublicKeyRSA = publicKeyX509Representation.base64EncodedString()
        
        let json = try JSONSerialization.data(withJSONObject: [
            "procClientSecretOTP": procClientSecretOTP,
            "clientPublicKeyRSA": clientPublicKeyRSA
        ] as [String: String])
        
        let data = try aesEncrypt(json, sessionKey)
        
        return data
    }
    
    func retrySignEncryptOTP(
        _ otp: String
    ) throws -> (Data, PublicKey, PrivateKey) {
        
        try retry {
            
            let (privateKey, publicKey) = try generateKeyPair()
            let encryptedSignedOTP = try signEncryptOTP(otp, privateKey)
            
            return (encryptedSignedOTP, publicKey, privateKey)
        }
    }
}

func retry<T>(
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

