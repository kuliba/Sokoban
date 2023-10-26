//
//  CachingGetProcessingSessionCodeServiceDecorator.swift
//  
//
//  Created by Igor Malyarov on 20.10.2023.
//

public final class CachingGetProcessingSessionCodeServiceDecorator {
    
    
    public typealias CacheResult = Result<Void, Error>
    public typealias CacheCompletion = (CacheResult) -> Void
    public typealias Payload = GetProcessingSessionCodeService.Response
    public typealias Cache = (Payload, @escaping CacheCompletion) -> Void
    
    private let decoratee: GetProcessingSessionCodeService
    private let cache: Cache
    
    public init(
        decoratee: GetProcessingSessionCodeService,
        cache: @escaping Cache
    ) {
        self.decoratee = decoratee
        self.cache = cache
    }
}

public extension CachingGetProcessingSessionCodeServiceDecorator {
    
    func getCode(
        completion: @escaping GetProcessingSessionCodeService.Completion
    ) {
        decoratee.getCode { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case let .failure(error):
                completion(.failure(error))
                
            case let .success(response):
                cache(response) { _ in
                    
                    // ignoring cache result
                    completion(.success(response))
                }
            }
        }
    }
}
