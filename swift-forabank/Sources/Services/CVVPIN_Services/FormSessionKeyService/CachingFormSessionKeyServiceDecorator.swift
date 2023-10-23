//
//  CachingFormSessionKeyServiceDecorator.swift
//  
//
//  Created by Igor Malyarov on 20.10.2023.
//

/// - Note: `SessionKey` is `SymmetricKey` is `SharedSecret`
///
public final class CachingFormSessionKeyServiceDecorator {
    
    public typealias Service = FormSessionKeyService
    public typealias Cache = (FormSessionKeyService.Success) -> Void
    
    private let decoratee: Service
    private let cache: Cache
    
    public init(
        decoratee: Service,
        cache: @escaping Cache
    ) {
        self.decoratee = decoratee
        self.cache = cache
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
                cache(success)
                completion(.success(success))
            }
        }
    }
}
