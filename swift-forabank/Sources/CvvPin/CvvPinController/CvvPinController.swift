//
//  CvvPinController.swift
//  
//
//  Created by Igor Malyarov on 16.07.2023.
//

public final class CvvPinController {
    
    private let sessionCodeLoader: SessionCodeLoader
    private let secretRequestCrypto: SecretRequestCrypto
    private let publicServerSessionKeyAPIClient: PublicServerSessionKeyAPIClient
    private let symmetricCrypto: SymmetricCrypto
    private let publicKeyAPIClient: PublicKeyAPIClient
    
    public init(
        sessionCodeLoader: SessionCodeLoader,
        secretRequestCrypto: SecretRequestCrypto,
        publicServerSessionKeyAPIClient: PublicServerSessionKeyAPIClient,
        symmetricCrypto: SymmetricCrypto,
        publicKeyAPIClient: PublicKeyAPIClient
    ) {
        self.sessionCodeLoader = sessionCodeLoader
        self.secretRequestCrypto = secretRequestCrypto
        self.publicServerSessionKeyAPIClient = publicServerSessionKeyAPIClient
        self.symmetricCrypto = symmetricCrypto
        self.publicKeyAPIClient = publicKeyAPIClient
    }
    
    public typealias AuthResult = Result<Auth, Error>
    public typealias AuthCompletion = (AuthResult) -> Void
    
    public func auth(completion: @escaping AuthCompletion) {
        
        sessionCodeLoader.load { [weak self] in
            
            guard let self else { return }
            
            switch $0 {
                
            case let .failure(error):
                completion(.failure(error))
                
            case let .success(sessionCode):
                
                makeSecretRequest(
                    sessionCode: sessionCode.cryptoSessionCode,
                    completion: completion
                )
            }
        }
    }
    
    private func makeSecretRequest(
        sessionCode: CryptoSessionCode,
        completion: @escaping AuthCompletion
    ) {
        secretRequestCrypto.makeSecretRequest(sessionCode: sessionCode) { [weak self] in
            
            guard let self else { return }
            
            switch $0 {
                
            case let .failure(error):
                completion(.failure(error))
                
            case let .success(secretRequest):
                
                getPublicServerSessionKey(
                    secretRequest: secretRequest.secretRequest,
                    completion: completion
                )
            }
        }
    }
    
    private func getPublicServerSessionKey(
        secretRequest: SecretRequest,
        completion: @escaping AuthCompletion
    ) {
        publicServerSessionKeyAPIClient.get(secretRequest) { [weak self] in
            
            guard let self else { return }
            
            switch $0 {
                
            case let .failure(error):
                completion(.failure(error))
                
            case let .success(payload):
                
                makeSymmetricKey(
                    payload: payload.symmetricCryptoPayload,
                    completion: completion
                )
            }
        }
    }
    
    private func makeSymmetricKey(
        payload: SymmetricCrypto.Payload,
        completion: @escaping AuthCompletion
    ) {
        symmetricCrypto.makeSymmetricKey(with: payload) { [weak self] in
            
            guard let self else { return }
            
            switch $0 {
            case let .failure(error):
                completion(.failure(error))
                
            case let .success(symmetricKey):
                
                self.sendPublicKey(
                    symmetricKey: symmetricKey.apiSymmetricKey,
                    completion: completion
                )
            }
        }
    }
    
    private func sendPublicKey(
        symmetricKey: APISymmetricKey,
        completion: @escaping AuthCompletion
    ) {
        publicKeyAPIClient.sendPublicKey(symmetricKey) { [weak self] result in
            
            guard self != nil else { return }
            
            completion(.init {
                let (sessionID, apiSymmetricKey) = try result.get()
                return .init(
                    sessionID: sessionID,
                    symmetricKey: apiSymmetricKey.symmetricKey
                )
            })
        }
    }
    
    public struct Auth: Equatable {
        
        let sessionID: SessionID
        let symmetricKey: SymmetricKey
        
        public init(
            sessionID: SessionID,
            symmetricKey: SymmetricKey
        ) {
            self.sessionID = sessionID
            self.symmetricKey = symmetricKey
        }
    }
}

// MARK: - Mappers

private extension SessionCode {
    
    var cryptoSessionCode: CryptoSessionCode {
        
        .init(value: value)
    }
}

private extension CryptoSecretRequest {
    
    var secretRequest: SecretRequest {
        
        .init()
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

public extension SymmetricKey {
    
    var apiSymmetricKey: APISymmetricKey {
        
        .init(value: value)
    }
}

private extension APISymmetricKey {
    
    var symmetricKey: SymmetricKey {
        
        .init(value: value)
    }
}
