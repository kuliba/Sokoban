//
//  RSAKeyPairCacheCleaningBindPublicKeyWithEventIDServiceDecorator.swift
//  
//
//  Created by Igor Malyarov on 20.10.2023.
//

public final class RSAKeyPairCacheCleaningBindPublicKeyWithEventIDServiceDecorator {
    
    public typealias Service = BindPublicKeyWithEventIDService
    public typealias ClearRSAKeyPairCache = () -> Void
    
    private let decoratee: Service
    private let clearCache: ClearRSAKeyPairCache
    
    public init(
        decoratee: Service,
        clearCache: @escaping ClearRSAKeyPairCache
    ) {
        self.decoratee = decoratee
        self.clearCache = clearCache
    }
}

extension RSAKeyPairCacheCleaningBindPublicKeyWithEventIDServiceDecorator {
    
    public func bind(
        otp: Service.OTP,
        completion: @escaping Service.Completion
    ) {
        decoratee.bind(with: otp) { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case let .failure(error):
                // clear cache if retryAttempts == 0
                if case .server = error {
                    clearCache()
                }
                completion(.failure(error))
                
            case let .success(response):
                completion(.success(response))
            }
        }
    }
}
