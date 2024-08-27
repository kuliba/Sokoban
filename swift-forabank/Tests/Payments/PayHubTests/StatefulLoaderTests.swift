//
//  StatefulLoaderTests.swift
//  
//
//  Created by Igor Malyarov on 27.08.2024.
//

enum StatefulLoaderState: Equatable {
    
    case notStarted
    case loading
}
enum StatefulLoaderEvent: Equatable {
    
    case load
}
enum StatefulLoaderEffect: Equatable {
    
    case load
}

final class StatefulLoaderReducer {}

extension StatefulLoaderReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case .load:
            load(&state, &effect)
        }
        
        return (state, effect)
    }
}

extension StatefulLoaderReducer {
    
    typealias State = StatefulLoaderState
    typealias Event = StatefulLoaderEvent
    typealias Effect = StatefulLoaderEffect
}

private extension StatefulLoaderReducer {
    
    func load(
    _ state: inout State,
    _ effect: inout Effect?
    ) {
        switch state {
        case .loading:
            break
            
        case .notStarted:
            state = .loading
            effect = .load
        }
    }
}

import XCTest

final class StatefulLoaderReducerTests: XCTestCase {
    
    func test_load_shouldChangeNotStartedStateToLoading() {
        
        assert(.notStarted, event: .load) {
            
            $0 = .loading
        }
    }
    
    func test_loadShouldDeliverLoadEffectOnNotStartedState() {
        
        assert(.notStarted, event: .load, delivers: .load)
    }

    func test_load_shouldNotChangeLoadingState() {
        
        assert(.loading, event: .load)
    }
    
    func test_loadShouldNotDeliverEffectOnLoadingState() {
        
        assert(.loading, event: .load, delivers: nil)
    }

    // MARK: - Helpers
    
    private typealias SUT = StatefulLoaderReducer
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }

    @discardableResult
    private func assert(
        sut: SUT? = nil,
        _ state: SUT.State,
        event: SUT.Event,
        updateStateToExpected: ((inout SUT.State) -> Void)? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT.State {
        
        let sut = sut ?? makeSUT(file: file, line: line)
        
        var expectedState = state
        updateStateToExpected?(&expectedState)
        
        let (receivedState, _) = sut.reduce(state, event)
        
        XCTAssertNoDiff(
            receivedState,
            expectedState,
            "\nExpected \(String(describing: expectedState)), but got \(String(describing: receivedState)) instead.",
            file: file, line: line
        )
        
        return receivedState
    }
    
    @discardableResult
    private func assert(
        sut: SUT? = nil,
        _ state: SUT.State,
        event: SUT.Event,
        delivers expectedEffect: SUT.Effect?,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT.Effect? {
        
        let sut = sut ?? makeSUT(file: file, line: line)
        
        let (_, receivedEffect) = sut.reduce(state, event)
        
        XCTAssertNoDiff(
            receivedEffect,
            expectedEffect,
            "\nExpected \(String(describing: expectedEffect)), but got \(String(describing: receivedEffect)) instead.",
            file: file, line: line
        )
        
        return receivedEffect
    }
}
