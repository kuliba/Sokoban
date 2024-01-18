//
//  TickEffectHandlerTests.swift
//
//
//  Created by Igor Malyarov on 18.01.2024.
//

final class TickEffectHandler {
    
    private let initiate: Initiate
    
    init(initiate: @escaping Initiate) {
        
        self.initiate = initiate
    }
}

extension TickEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case .initiate:
            initiate { _ in }
        }
    }
}

extension TickEffectHandler {
    
    typealias InitiateResult = Result<Void, Failure>
    typealias InitiateCompletion = (InitiateResult) -> Void
    typealias Initiate = (@escaping InitiateCompletion) -> Void
    
    enum Failure: Error, Equatable {
        
        case connectivityError
        case serverError(String)
    }
}

extension TickEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias State = TickState
    typealias Event = TickEvent
    typealias Effect = TickEffect
}

import XCTest

final class TickEffectHandlerTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, spy) = makeSUT()
        
        XCTAssertEqual(spy.callCount, 0)
    }
    
    func test_initiate_shouldCallCollaborator() {
        
        let (sut, spy) = makeSUT()
        
        sut.handleEffect(.initiate) { _ in }
        
        XCTAssertEqual(spy.callCount, 1)
    }
    // MARK: - Helpers
    
    private typealias SUT = TickEffectHandler
    private typealias State = SUT.State
    private typealias Event = SUT.Event
    private typealias Effect = SUT.Effect

    private typealias InitiateSpy = Spy<Void, SUT.InitiateResult>

    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spy: InitiateSpy
    ) {
        
        let spy = InitiateSpy()
        let sut = SUT(initiate: spy.process(completion:))
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        
        return (sut, spy)
    }
}
