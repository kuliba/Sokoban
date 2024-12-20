//
//  NilifyDecorator.swift
//
//
//  Created by Igor Malyarov on 27.03.2024.
//

public final class NilifyDecorator<Payload, Response, Failure: Error> {
    
    private let decoratee: Decoratee
    
    public init(decoratee: @escaping Decoratee) {
        
        self.decoratee = decoratee
    }
}

public extension NilifyDecorator {
    
    func process(
        _ payload: Payload,
        _ completion: @escaping Completion
    ) {
        decoratee(payload) { [weak self] in
            
            guard self != nil else { return }
            
            completion(try? $0.get())
        }
    }
}

public extension NilifyDecorator {
    
    typealias DecorateeCompletion = (Result<Response, Failure>) -> Void
    typealias Decoratee = (Payload, @escaping DecorateeCompletion) -> Void
    
    typealias Completion = (Response?) -> Void
}
