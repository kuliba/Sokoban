//
//  SerialStampedCachingDecorator.swift
//
//
//  Created by Igor Malyarov on 10.09.2024.
//

public final class SerialStampedCachingDecorator<Response> {
    
    private let decoratee: Decoratee
    private let cache: Cache
    
    public init(
        decoratee: @escaping Decoratee,
        cache: @escaping Cache
    ) {
        self.decoratee = decoratee
        self.cache = cache
    }
}

public extension SerialStampedCachingDecorator {
    
    typealias Serial = String
    typealias DecorateeCompletion = (Result<SerialStamped<Response>, Error>) -> Void
    typealias Decoratee = (Serial?, @escaping DecorateeCompletion) -> Void
    typealias CacheCompletion = (Result<Void, Error>) -> Void
    typealias Cache = (SerialStamped<Response>, @escaping CacheCompletion) -> Void
}

public extension SerialStampedCachingDecorator {
    
    func decorated(
        _ serial: Serial?,
        completion: @escaping DecorateeCompletion
    ) {
        decoratee(serial) { [weak self] in
            
            guard let self else { return }
            
            switch $0 {
            case let .failure(failure):
                completion(.failure(failure))
                
            case let .success(success):
                if success.serial != serial {
                    self.cache(success) { _ in completion(.success(success)) }
                } else {
                    completion(.success(success))
                }
            }
        }
    }
}
