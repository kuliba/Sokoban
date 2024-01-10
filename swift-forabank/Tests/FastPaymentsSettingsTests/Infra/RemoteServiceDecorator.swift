//
//  RemoteServiceDecorator.swift
//  
//
//  Created by Igor Malyarov on 10.01.2024.
//

final class RemoteServiceDecorator<Input, Output, ProcessError>
where ProcessError: Error {
    
    private let decoratee: Decoratee
    private let decoration: Decoration
    
    init(
        decoratee: Decoratee,
        decoration: @escaping Decoration
    ) {
        self.decoratee = decoratee
        self.decoration = decoration
    }
}

extension RemoteServiceDecorator: RemoteServiceInterface {

    func process(
        _ input: Input,
        completion: @escaping ProcessCompletion
    ) {
        decoratee.process(input) { [weak self] result in
        
            self?.decoration(result) { completion(result) }
        }
    }
}

extension RemoteServiceDecorator {
    
    typealias Decoratee = any RemoteServiceInterface<Input, Output, ProcessError>
    typealias Decoration = (ProcessResult, @escaping () -> Void) -> Void
    
    typealias ProcessResult = Result<Output, ProcessError>
    typealias ProcessCompletion = (ProcessResult) -> Void
}
