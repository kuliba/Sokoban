//
//  SerialStampedCachingDecorator.swift
//
//
//  Created by Igor Malyarov on 10.09.2024.
//

public final class SerialStampedCachingDecorator<Payload, Response> {
    
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
    
    typealias DecorateeCompletion = (Result<SerialStamped<Response>, Error>) -> Void
    typealias Decoratee = (SerialStamped<Payload>, @escaping DecorateeCompletion) -> Void
    typealias CacheCompletion = (Result<Void, Error>) -> Void
    typealias Cache = (SerialStamped<Response>, @escaping CacheCompletion) -> Void
}

public extension SerialStampedCachingDecorator {
    
    func load(
        _ payload: SerialStamped<Payload>,
        completion: @escaping DecorateeCompletion
    ) {
        decoratee(payload) { [weak self] in
            
            guard let self else { return }
            
            switch $0 {
            case let .failure(failure):
                completion(.failure(failure))
                
            case let .success(success):
                if success.serial != payload.serial {
                    self.cache(success) { _ in completion(.success(success)) }
                } else {
                    completion(.success(success))
                }
            }
        }
    }
}

public extension SerialStampedCachingDecorator where Payload == Void {
    
    typealias Serial = String
    
    convenience init(
        decoratee: @escaping (Serial?, @escaping DecorateeCompletion) -> Void,
        cache: @escaping Cache
    ) {
        self.init(
            decoratee: { payload, completion in
                
                decoratee(payload.serial, completion)
            },
            cache: cache
        )
    }
    
    func load(
        serial: Serial?,
        completion: @escaping DecorateeCompletion
    ) {
        self.load(.init(serial: serial), completion: completion)
    }
}
