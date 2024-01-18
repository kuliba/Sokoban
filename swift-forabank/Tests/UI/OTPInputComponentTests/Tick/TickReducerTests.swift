//
//  TickReducerTests.swift
//
//
//  Created by Igor Malyarov on 18.01.2024.
//

final class TickReducer {
    
    private let interval: Int
    
    init(interval: Int = 60) {
     
        self.interval = interval
    }
}

extension TickReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        switch (state.core, event) {
        case (.idle, .appear):
            return (.init(.idle), .initiate)
            
        case (.idle, .start):
            let state = State(.running(remaining: interval))
            return (state, nil)
            
        case let (.idle, .failure(tickFailure)):
            return (.init(.idle, status: .failure(tickFailure)), nil)
            
        default:
            fatalError()
        }
    }
}

extension TickReducer {
    
    typealias State = TickState
    typealias Event = TickEvent
    typealias Effect = TickEffect
}

import XCTest

final class TickReducerTests: XCTestCase {
    
    func test_appear_shouldNotChangeState_idle() {
        
        assert(.init(.idle), .appear, reducedTo: .init(.idle))
    }
    
    func test_appear_shouldDeliverEffect_idle() {
        
        assert(.init(.idle), .appear, effect: .initiate)
    }
    
    func test_start_shouldSetStateToRunning_idle() {
        
        let sut = makeSUT(interval: 77)
        
        assert(sut: sut, .init(.idle), .start, reducedTo: .init(
            .running(remaining: 77)
        ))
    }
    
    func test_start_shouldNotDeliverEffect_idle() {
        
        assert(.init(.idle), .start, effect: nil)
    }
    
    func test_failure_shouldSetStateToFailure_idle_connectivity() {
        
        assert(.init(.idle), connectivity(), reducedTo: .init(
            .idle,
            status: connectivity()
        ))
    }
    
    func test_failure_shouldNotDeliverEffect_idle_connectivity() {
        
        assert(.init(.idle), connectivity(), effect: nil)
    }
    
    func test_failure_shouldSetStateToFailure_idle_server() {
        
        let message = anyMessage()
        
        assert(.init(.idle), serverError(message), reducedTo: .init(
            .idle,
            status: serverError(message)
        ))
    }
    
    func test_failure_shouldNotDeliverEffect_idle_server() {
        
        let message = anyMessage()
        
        assert(.init(.idle), serverError(message), effect: nil)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = TickReducer
    private typealias State = SUT.State
    private typealias Event = SUT.Event
    private typealias Effect = SUT.Effect
    
    private func makeSUT(
        interval: Int = 60,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT(interval: interval)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func assert(
        sut: SUT? = nil,
        _ state: State,
        _ event: Event,
        reducedTo expectedState: State,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let sut = sut ?? makeSUT(file: file, line: line)
        let (receivedState, _) = sut.reduce(state, event)
        
        XCTAssertNoDiff(
            receivedState,
            expectedState,
            "\nExpected \(expectedState), but got \(receivedState) instead.",
            file: file, line: line
        )
    }
    
    private func assert(
        sut: SUT? = nil,
        _ state: State,
        _ event: Event,
        effect expectedEffect: Effect?,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let sut = sut ?? makeSUT(file: file, line: line)
        let (_, receivedEffect) = sut.reduce(state, event)
        
        XCTAssertNoDiff(
            receivedEffect,
            expectedEffect,
            "\nExpected \(String(describing: expectedEffect)), but got \(String(describing: receivedEffect)) instead.",
            file: file, line: line
        )
    }
}
