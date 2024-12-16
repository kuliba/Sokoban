//
//  RemoteServiceDecorator.swift
//
//
//  Created by Igor Malyarov on 10.01.2024.
//

public final class RemoteServiceDecorator<Input, Output, ProcessError>
where ProcessError: Error {
    
    private let decoratee: Decoratee
    private let decoration: Decoration
    
    public init(
        decoratee: Decoratee,
        decoration: @escaping Decoration
    ) {
        self.decoratee = decoratee
        self.decoration = decoration
    }
}

extension RemoteServiceDecorator: RemoteServiceInterface {
    
    public func process(
        _ input: Input,
        completion: @escaping ProcessCompletion
    ) {
        decoratee.process(input) { [weak self] result in
            
            self?.decoration(result) { completion(result) }
        }
    }
}

public extension RemoteServiceDecorator {
    
    typealias Decoratee = any RemoteServiceInterface<Input, Output, ProcessError>
    typealias Decoration = (ProcessResult, @escaping () -> Void) -> Void
    
    typealias ProcessResult = Result<Output, ProcessError>
    typealias ProcessCompletion = (ProcessResult) -> Void
}
