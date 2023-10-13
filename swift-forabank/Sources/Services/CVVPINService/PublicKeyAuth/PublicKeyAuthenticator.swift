//
//  PublicKeyAuthenticator.swift
//  
//
//  Created by Igor Malyarov on 01.10.2023.
//

import Foundation

public final class PublicKeyAuthenticator<RSAPublicKey, RSAPrivateKey> {
    
    public typealias KeyExchangeDomain = RemoteServiceDomainOf<(RSAPublicKey, RSAPrivateKey), Void>
    public typealias ExchangeKeys = KeyExchangeDomain.AsyncGet
    
    private let infra: Infra
    private let exchangeKeys: ExchangeKeys
    
    public init(
        infra: Infra,
        exchangeKeys: @escaping ExchangeKeys
    ) {
        self.infra = infra
        self.exchangeKeys = exchangeKeys
    }
}

public extension PublicKeyAuthenticator {
    
    typealias Completion = (Result<Void, Error>) -> Void
    
    func authenticateWithPublicKey(
        completion: @escaping Completion
    ) {
        infra.loadRSAKeyPair { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case let .failure(error):
                completion(.failure(error))
                
            case let .success(rsaKeyPair):
                loadSessionKeyWithEvent(rsaKeyPair.publicKey, rsaKeyPair.privateKey, completion)
            }
        }
    }
}

// MARK: - Interface

extension PublicKeyAuthenticator {
    
    public struct Infra {
        
        public typealias RSAKeyPairDomain = KeyPairDomain<RSAPublicKey, RSAPrivateKey>
        public typealias LoadRSAKeyPair = RSAKeyPairDomain.AsyncGet
        
        public typealias SessionKeyWithEventLoaderDomain = DomainOf<SessionKeyWithEvent>
        public typealias LoadSessionKeyWithEvent = SessionKeyWithEventLoaderDomain.AsyncGet
        
        let loadRSAKeyPair: LoadRSAKeyPair
        let loadSessionKeyWithEvent: LoadSessionKeyWithEvent
        
        public init(
            loadRSAKeyPair: @escaping LoadRSAKeyPair,
            loadSessionKeyWithEvent: @escaping LoadSessionKeyWithEvent
        ) {
            self.loadRSAKeyPair = loadRSAKeyPair
            self.loadSessionKeyWithEvent = loadSessionKeyWithEvent
        }
    }
}

// MARK: - Implementation

private extension PublicKeyAuthenticator {
    
    func loadSessionKeyWithEvent(
        _ rsaPublicKey: RSAPublicKey,
        _ rsaPrivateKey: RSAPrivateKey,
        _ completion: @escaping Completion
    ) {
        infra.loadSessionKeyWithEvent { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case .failure:
                handleFailure(rsaPublicKey, rsaPrivateKey, completion)
                
            case .success:
                completion(.success(()))
            }
        }
    }
    
    func handleFailure(
        _ rsaPublicKey: RSAPublicKey,
        _ rsaPrivateKey: RSAPrivateKey,
        _ completion: @escaping Completion
    ) {
        exchangeKeys((rsaPublicKey, rsaPrivateKey)) { [weak self] result in
            
            guard self != nil else { return }
            
            completion(result)
        }
    }
}
