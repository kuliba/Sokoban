//
//  TickReducerTests.swift
//
//
//  Created by Igor Malyarov on 18.01.2024.
//

final class TickReducer {
    
}

extension TickReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        switch (state, event) {
        case (.idle, .appear):
            return (.idle, .initiate)
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
        
        assert(.idle, .appear, reducedTo: .idle)
    }
    
    func test_appear_shouldDeliverEffect_idle() {
        
        assert(.idle, .appear, effect: .initiate)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = TickReducer
    private typealias State = SUT.State
    private typealias Event = SUT.Event
    private typealias Effect = SUT.Effect
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT()
        
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
