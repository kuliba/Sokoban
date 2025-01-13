//
//  CachingKeyGeneratorDecorator.swift
//  
//
//  Created by Igor Malyarov on 17.08.2023.
//

import CryptoKit

public final class CachingKeyGeneratorDecorator<PrivateKey, PublicKey> {
    
    public typealias KeyPair = (privateKey: PrivateKey, publicKey: PublicKey)
    public typealias GenerateKeyPair = (@escaping (Result<KeyPair, Error>) -> Void) -> Void
    public typealias CacheKey = KeyCacheDomain<PrivateKey>.SaveKey
    
    private let decoratee: GenerateKeyPair
    private let cacheKey: CacheKey
    
    public init(
        decoratee: @escaping GenerateKeyPair,
        cacheKey: @escaping CacheKey
    ) {
        self.decoratee = decoratee
        self.cacheKey = cacheKey
    }
    
    public var generateKeyPair: GenerateKeyPair {
        
        return { [decoratee, cacheKey] completion in
            
            decoratee { result in
                
                switch result {
                case let .failure(error):
                    completion(.failure(error))
                    
                case let .success(keyPair):
                    cacheKey(keyPair.privateKey) { cacheResult in
                        
                        switch cacheResult {
                        case let .failure(error):
                            completion(.failure(error))
                            
                        case .success:
                            completion(.success(keyPair))
                        }
                    }
                }
            }
        }
    }
}
