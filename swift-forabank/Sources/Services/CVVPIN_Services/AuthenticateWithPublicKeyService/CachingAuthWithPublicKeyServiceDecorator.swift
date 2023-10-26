//
//  CachingAuthWithPublicKeyServiceDecorator.swift
//  
//
//  Created by Igor Malyarov on 20.10.2023.
//

/// - Note: `SessionKey` is `SymmetricKey` is `SharedSecret`
///
#warning("component looks similar to CachingFormSessionKeyServiceDecorator")
public final class CachingAuthWithPublicKeyServiceDecorator {
    
    public typealias Service = AuthenticateWithPublicKeyService
    public typealias Success = Service.Success
    
    public typealias CacheResult = Result<Void, Error>
    public typealias CacheCompletion = (CacheResult) -> Void
    
    public typealias CacheSessionIDPayload = (Success.SessionID, Success.SessionTTL)
    public typealias CacheSessionID = (CacheSessionIDPayload, @escaping CacheCompletion) -> Void
    
    public typealias CacheSessionKey = (Success.SessionKey, @escaping CacheCompletion) -> Void
    
    private let decoratee: Service
    private let cacheSessionID: CacheSessionID
    private let cacheSessionKey: CacheSessionKey
    
    public init(
        decoratee: Service,
        cacheSessionID: @escaping CacheSessionID,
        cacheSessionKey: @escaping CacheSessionKey
    ) {
        self.decoratee = decoratee
        self.cacheSessionID = cacheSessionID
        self.cacheSessionKey = cacheSessionKey
    }
}

public extension CachingAuthWithPublicKeyServiceDecorator {
    
    func authenticateWithPublicKey(
        completion: @escaping Service.Completion
    ) {
        decoratee.authenticateWithPublicKey { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case let .failure(error):
                completion(.failure(error))
                
            case let .success(success):
                cache(success, completion)
            }
        }
    }
}

private extension CachingAuthWithPublicKeyServiceDecorator {
    
    func cache(
        _ success: Success,
        _ completion: @escaping Service.Completion
    ) {
        let payload = (success.sessionID, success.sessionTTL)
        
        cacheSessionID(payload) { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case .failure:
                completion(.failure(.other(.activationFailure)))
                
            case .success:
                cacheSessionKey(success.sessionKey) { [weak self] result in
                    
                    guard self != nil else { return }
                    
                    completion(
                        .success(success)
                        .mapError { _ in .other(.activationFailure) }
                    )
                }
            }
        }
    }
}
