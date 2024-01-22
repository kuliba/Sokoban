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
            initiate(dispatch)
        }
    }
}

extension TickEffectHandler {
    
    typealias InitiateResult = Result<Void, TickFailure>
    typealias InitiateCompletion = (InitiateResult) -> Void
    typealias Initiate = (@escaping InitiateCompletion) -> Void
}

extension TickEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias State = TickState
    typealias Event = TickEvent
    typealias Effect = TickEffect
}

private extension TickEffectHandler {

    func initiate(
        _ dispatch: @escaping Dispatch
    ) {
        initiate { result in
        
            switch result {
            case .success(()):
                dispatch(.start)
            
            case .failure(.connectivityError):
                dispatch(.failure(.connectivityError))
                
            case let .failure(.serverError(message)):
                dispatch(.failure(.serverError(message)))
            }
        }
    }
}

import RxViewModel
import XCTest

extension TickEffectHandler: EffectHandler {}

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
    
    func test_initiate_shouldDeliverStartOnSuccess() {
        
        let (sut, spy) = makeSUT()
        
        expect(sut, with: .initiate, toDeliver: .start, on: {
            
            spy.complete(with: .success(()))
        })
    }
    
    func test_initiate_shouldDeliverConnectivityErrorOnConnectivityFailure() {
        
        let (sut, spy) = makeSUT()
        
        expect(sut, with: .initiate, toDeliver: .failure(.connectivityError), on: {
            
            spy.complete(with: .failure(.connectivityError))
        })
    }
    
    func test_initiate_shouldDeliverServerErrorOnServerFailure() {
        
        let message = anyMessage()
        let (sut, spy) = makeSUT()
        
        expect(sut, with: .initiate, toDeliver: .failure(.serverError(message)), on: {
            
            spy.complete(with: .failure(.serverError(message)))
        })
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
