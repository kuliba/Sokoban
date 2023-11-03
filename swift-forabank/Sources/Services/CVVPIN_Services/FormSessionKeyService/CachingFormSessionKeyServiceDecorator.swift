//
//  CachingFormSessionKeyServiceDecorator.swift
//  
//
//  Created by Igor Malyarov on 20.10.2023.
//

/// - Note: `SessionKey` is `SymmetricKey` is `SharedSecret`
///
#warning("component looks similar to CachingAuthWithPublicKeyServiceDecorator")
public final class CachingFormSessionKeyServiceDecorator {
    
    public typealias Service = FormSessionKeyService
    public typealias Success = Service.Success
    
    public typealias CacheResult = Result<Void, Error>
    public typealias CacheCompletion = (CacheResult) -> Void
    
    public typealias CacheSessionIDPayload = (Success.EventID, Success.SessionTTL)
    public typealias CacheSessionID = (CacheSessionIDPayload, @escaping CacheCompletion) -> Void
    
    public typealias CacheSessionKey = (Service.SessionKey, @escaping CacheCompletion) -> Void

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

public extension CachingFormSessionKeyServiceDecorator {
    
    func formSessionKey(
        completion: @escaping Service.Completion
    ) {
        decoratee.formSessionKey { [weak self] result in
            
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

private extension CachingFormSessionKeyServiceDecorator {
    
    func cache(
        _ success: Success,
        _ completion: @escaping Service.Completion
    ) {
        let payload = (success.eventID, success.sessionTTL)
        
        cacheSessionID(payload) { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case .failure:
                #warning("error mapping to non-related case")
                completion(.failure(.serviceError(.makeSessionKeyFailure)))
                
            case .success:
                cacheSessionKey(success.sessionKey) { [weak self] result in
                    
                    guard self != nil else { return }
                    
                    #warning("error mapping to non-related case")
                    completion(
                        .success(success)
                        .mapError { _ in .serviceError(.makeSessionKeyFailure) }
                    )
                }
            }
        }
    }
}
