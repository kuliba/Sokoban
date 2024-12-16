//
//  FireAndForgetDecorator.swift
//
//
//  Created by Igor Malyarov on 12.09.2024.
//

/// A decorator that applies a decoration after the decoratee completes its operation,
/// without waiting for the decoration to complete.
///
/// The `FireAndForgetDecorator` allows for two main operations:
/// - The `decoratee` is the main operation which completes and returns a result.
/// - The `decoration` is applied after the `decoratee` completes but does not block the main operation's result.
public final class FireAndForgetDecorator<Payload, Response, Failure: Error> {
    
    private let decoratee: Decoratee
    private let decoration: Decoration
    
    /// Initialises the decorator with the decoratee and decoration closures.
    ///
    /// - Parameters:
    ///   - decoratee: The main operation that returns a `Result` upon completion.
    ///   - decoration: The decoration applied after the `decoratee` completes successfully.
    public init(
        decoratee: @escaping Decoratee,
        decoration: @escaping Decoration
    ) {
        self.decoratee = decoratee
        self.decoration = decoration
    }
}

public extension FireAndForgetDecorator {
    
    /// The completion type for the decoratee, which returns a `Result` with either a `Response` or `Failure`.
    typealias DecorateeCompletion = (Result<Response, Failure>) -> Void
    
    /// The signature of the decoratee, which takes a `Payload` and a completion closure.
    typealias Decoratee = (Payload, @escaping DecorateeCompletion) -> Void
    
    /// The completion type for the decoration, which is called after the decoration is complete.
    typealias DecorationCompletion = () -> Void
    
    /// The signature of the decoration, which takes the `Response` and a completion closure.
    typealias Decoration = (Response, @escaping DecorationCompletion) -> Void
}

public extension FireAndForgetDecorator {
    
    /// Calls the `decoratee` with the given payload and applies the `decoration` after the `decoratee` completes.
    ///
    /// - Parameters:
    ///   - payload: The input for the `decoratee`.
    ///   - completion: The completion closure for the `decoratee`, which handles the result of the operation.
    func callAsFunction(
        _ payload: Payload,
        completion: @escaping DecorateeCompletion
    ) {
        decoratee(payload) { [weak self] in
            
            guard let self else { return }
            
            switch $0 {
            case let .failure(failure):
                completion(.failure(failure))
                
            case let .success(response):
                completion(.success(response))
                self.decoration(response) {}
            }
        }
    }
}

public extension FireAndForgetDecorator
where Payload == Void,
      Failure == Never {
    
    convenience init(
        decoratee: @escaping (@escaping (Response) -> Void) -> Void,
        decoration: @escaping Decoration
    ) {
        self.init(
            decoratee: { _, completion in
                
                decoratee { completion(.success($0)) }
            },
            decoration: decoration
        )
    }
}

public extension FireAndForgetDecorator
where Payload == Void {
    
    convenience init(
        decoratee: @escaping (@escaping DecorateeCompletion) -> Void,
        decoration: @escaping Decoration
    ) {
        self.init(
            decoratee: { _, completion in decoratee(completion) },
            decoration: decoration
        )
    }
    
    func callAsFunction(
        completion: @escaping DecorateeCompletion
    ) {
        self.callAsFunction((), completion: completion)
    }
}
