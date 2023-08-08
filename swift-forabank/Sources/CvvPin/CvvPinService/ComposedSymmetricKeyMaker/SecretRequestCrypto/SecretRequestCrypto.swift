//
//  SecretRequestCrypto.swift
//  
//
//  Created by Igor Malyarov on 18.07.2023.
//

public protocol SecretRequestCrypto {
    
    typealias Result = Swift.Result<CryptoSecretRequest, Error>
    typealias Completion = (Result) -> Void
    
    func makeSecretRequest(
        sessionCode: CryptoSessionCode,
        completion: @escaping Completion
    )
}
