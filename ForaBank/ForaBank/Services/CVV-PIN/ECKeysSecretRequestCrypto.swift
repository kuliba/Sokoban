//
//  ECKeysSecretRequestCrypto.swift
//  ForaBank
//
//  Created by Igor Malyarov on 03.08.2023.
//

import CvvPin
import Foundation

final class ECKeysSecretRequestCrypto: SecretRequestCrypto {
    
    typealias MakePublicKey = () throws -> SecKey
    typealias Encrypt = (Data) throws -> Data
    
    private let makePublicKey: MakePublicKey
    private let encrypt: Encrypt
    
    init(
        makePublicKey: @escaping MakePublicKey,
        encrypt: @escaping Encrypt
    ) {
        self.makePublicKey = makePublicKey
        self.encrypt = encrypt
    }
    
    func makeSecretRequest(
        sessionCode: CvvPin.CryptoSessionCode,
        completion: @escaping Completion
    ) {
        makeSecretRequest(
            sessionCode: sessionCode,
            wrapInJSON: Self.wrapInJSON(_:),
            completion: completion
        )
    }
    
    // private func for explicit shape
    private func makeSecretRequest(
        sessionCode: CvvPin.CryptoSessionCode,
        wrapInJSON: @escaping (Data) throws -> Data,
        completion: @escaping Completion
    ) {
        completion(.init {
            
            let publicKey = try makePublicKey()
            let data = try CSRFAgent<AESEncryptionAgent>
                .externalKeyData(from: publicKey)
            // NB: keep for debugging so far
            // let keyBase64 = "MHYwEAYHKoZIzj0CAQYFK4EEACIDYgAEFZp5pRhs5snqQLa5AsGGtPKvaFfxF3CgSDMKCmwCAKmeZtKetmdUAq/UrfFjP7k7rbH+QSLisR/g3XHFVwQY/CSbuqII5i5Adh2ssCtYmQ7oDbvmk9PbeyCZE4twlNtV"
            // let data = Data(base64Encoded: keyBase64)!
            let wrapped = try wrapInJSON(data)
            let encrypted = try encrypt(wrapped)
            let base64 = encrypted.base64EncodedString()
            
            return .init(
                code: .init(value: sessionCode.value),
                data: base64
            )
        })
    }
    
    #warning("move this wrapper out to the caller and inject, this is not crypto responsibility")
    private static func wrapInJSON(
        _ keyRawRepresentation: Data
    ) throws -> Data {
        
        let pasKey = "publicApplicationSessionKey"
        let base64 = keyRawRepresentation.base64EncodedString()
        let json: [String: Any] = [pasKey: base64]
        let data = try JSONSerialization.data(withJSONObject: json)
        
        return data
    }
}
