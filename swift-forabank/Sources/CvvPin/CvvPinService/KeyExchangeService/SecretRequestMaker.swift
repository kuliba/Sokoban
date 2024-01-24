//
//  SecretRequestMaker.swift
//  
//
//  Created by Igor Malyarov on 09.08.2023.
//

import Foundation

public final class SecretRequestMaker {
    
    public typealias PublicKeyData = () throws -> Data
    public typealias Encrypt = (Data) throws -> Data
    
    private let publicKeyData: PublicKeyData
    private let encrypt: Encrypt
    
    public init(
        publicKeyData: @escaping PublicKeyData,
        encrypt: @escaping Encrypt
    ) {
        self.publicKeyData = publicKeyData
        self.encrypt = encrypt
    }
    
    public func makeSecretRequest(
        sessionCode: KeyExchangeDomain.SessionCode
    ) throws -> KeyExchangeDomain.SecretRequest {
        
        typealias Wrapper = PublicApplicationSessionKeyJSONWrapper
        
        let publicKeyData = try publicKeyData()
        let wrapped = try Wrapper.wrap(publicKeyData)
        let encrypted = try encrypt(wrapped)
        
        return .init(
            code: .init(value: sessionCode.value),
            data: encrypted
        )
    }
}

enum PublicApplicationSessionKeyJSONWrapper {
    
    static func wrap(
        _ keyRawRepresentation: Data
    ) throws -> Data {
        
        let base64 = keyRawRepresentation.base64EncodedString()
        let data = try JSONSerialization.data(withJSONObject: [
            "publicApplicationSessionKey": base64
        ] as [String: Any])
        
        return data
    }
}
