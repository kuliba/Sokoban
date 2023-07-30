//
//  CvvPinController.swift
//  
//
//  Created by Igor Malyarov on 16.07.2023.
//

public final class CvvPinController {
    
    public typealias PublicKeyAPIClient = CryptoAPIClient<APISymmetricKey, (SessionID, APISymmetricKey)>
    
    private let sessionCodeLoader: SessionCodeLoader
    private let symmetricKeyMaker: SymmetricKeyMaker
    private let publicKeyAPIClient: any PublicKeyAPIClient
    
    public init(
        sessionCodeLoader: SessionCodeLoader,
        symmetricKeyMaker: SymmetricKeyMaker,
        publicKeyAPIClient: any PublicKeyAPIClient
    ) {
        self.sessionCodeLoader = sessionCodeLoader
        self.symmetricKeyMaker = symmetricKeyMaker
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
                
                makeSecretRequest(sessionCode.cryptoSessionCode, completion)
            }
        }
    }
    
    private func makeSecretRequest(
        _ sessionCode: CryptoSessionCode,
        _ completion: @escaping AuthCompletion
    ) {
        symmetricKeyMaker.makeSymmetricKey(with: sessionCode) { [weak self] in
            
            guard let self else { return }
            
            switch $0 {
            case let .failure(error):
                completion(.failure(error))
                
            case let .success(symmetricKey):
                
                self.sendPublicKey(symmetricKey.apiSymmetricKey, completion)
            }
        }
    }
    
    private func sendPublicKey(
        _ symmetricKey: APISymmetricKey,
        _ completion: @escaping AuthCompletion
    ) {
        publicKeyAPIClient.get(symmetricKey) { [weak self] result in
            
            guard self != nil else { return }
            
            completion(.init {
                try result.map(Auth.init).get()
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

private extension CvvPinController.Auth {
    
    init(
        sessionID: SessionID,
        apiSymmetricKey: APISymmetricKey
    ) {
        self.init(
            sessionID: sessionID,
            symmetricKey: apiSymmetricKey.symmetricKey
        )
    }
}

private extension SessionCode {
    
    var cryptoSessionCode: CryptoSessionCode {
        
        .init(value: value)
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
