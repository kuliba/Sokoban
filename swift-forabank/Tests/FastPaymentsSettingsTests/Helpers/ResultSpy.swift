//
//  ResultSpy.swift
//  
//
//  Created by Igor Malyarov on 26.01.2024.
//

final class ResultSpy<Payload, Success, Failure: Error> {
    
    typealias InternalSpy = SpyOf<Payload, Success, Failure>
    
    private let spy: InternalSpy
    
    init() {
        self.spy = .init()
    }
}

extension ResultSpy {
    
    typealias Completion = (Result<Success, Failure>) -> Void
    
    var callCount: Int { spy.callCount }
    
    func process(
        _ payload: Payload,
        completion: @escaping Completion
    ) {
        spy.process(payload, completion: completion)
    }

    func complete(
        with result: Result<Success, Failure>,
        at index: Int = 0
    ) {
        spy.complete(with: result, at: index)
    }
    
    func complete(
        with success: Success,
        at index: Int = 0
    ) {
        spy.complete(with: .success(success), at: index)
    }
    
    func complete(
        with failure: Failure,
        at index: Int = 0
    ) {
        spy.complete(with: .failure(failure), at: index)
    }
}

extension ResultSpy where Payload == Void {
    
    func process(completion: @escaping Completion) {
        
        process((), completion: completion)
    }
}
