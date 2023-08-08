//
//  ComposedSymmetricKeyService.swift
//  
//
//  Created by Igor Malyarov on 20.07.2023.
//

public final class ComposedSymmetricKeyService: SymmetricKeyService {
    
    public typealias PublicServerSessionKeyAPIClient = CryptoAPIClient<SecretRequest, PublicServerSessionKeyPayload>
    
    private let secretRequestCrypto: SecretRequestCrypto
    private let publicServerSessionKeyAPIClient: any PublicServerSessionKeyAPIClient
    private let symmetricCrypto: SymmetricCrypto
    
    public init(
        secretRequestCrypto: SecretRequestCrypto,
        publicServerSessionKeyAPIClient: any PublicServerSessionKeyAPIClient,
        symmetricCrypto: SymmetricCrypto
    ) {
        self.secretRequestCrypto = secretRequestCrypto
        self.publicServerSessionKeyAPIClient = publicServerSessionKeyAPIClient
        self.symmetricCrypto = symmetricCrypto
    }
    
    public typealias SymmetricKeyResult = SymmetricKeyService.Result
    public typealias SymmetricKeyCompletion = SymmetricKeyService.SymmetricKeyCompletion
    
    public func makeSymmetricKey(
        with sessionCode: CryptoSessionCode,
        completion: @escaping SymmetricKeyCompletion
    ) {
        secretRequestCrypto.makeSecretRequest(sessionCode: sessionCode) { [weak self] in
            
            guard let self else { return }
            
            switch $0 {
                
            case let .failure(error):
                completion(.failure(error))
                
            case let .success(secretRequest):
                
                getPublicServerSessionKey(secretRequest.secretRequest, completion)
            }
        }
    }
    
    private func getPublicServerSessionKey(
        _ secretRequest: SecretRequest,
        _ completion: @escaping SymmetricKeyCompletion
    ) {
        publicServerSessionKeyAPIClient.get(secretRequest) { [weak self] in
            
            guard let self else { return }
            
            switch $0 {
                
            case let .failure(error):
                completion(.failure(error))
                
            case let .success(payload):
                
                makeSymmetricKey(payload.symmetricCryptoPayload, completion)
            }
        }
    }
    
    private func makeSymmetricKey(
        _ payload: SymmetricCrypto.Payload,
        _ completion: @escaping SymmetricKeyCompletion
    ) {
        symmetricCrypto.makeSymmetricKey(with: payload) { [weak self] result in
            
            guard self != nil else { return }
            
            completion(result)
        }
    }
}

// MARK: - Mappers

private extension CryptoSecretRequest {
    
    var secretRequest: SecretRequest {
        
        .init(code: code.value, data: data)
    }
}

private extension PublicServerSessionKeyPayload {
    
    var symmetricCryptoPayload: SymmetricCrypto.Payload {
        
        .init(
            publicServerSessionKey: publicServerSessionKey.value,
            eventID: eventID.value,
            sessionTTL: sessionTTL
        )
    }
}
