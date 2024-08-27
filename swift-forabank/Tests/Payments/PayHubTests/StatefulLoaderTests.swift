//
//  StatefulLoaderTests.swift
//
//
//  Created by Igor Malyarov on 27.08.2024.
//

/// Represents the possible states of the `StatefulLoader`.
enum StatefulLoaderState: Equatable {
    
    /// The loader has failed to load the resource.
    case failed
    /// The loader is currently in the process of loading the resource.
    case loading
    /// The loader has successfully loaded the resource.
    case loaded
    /// The loader has not started the loading process.
    case notStarted
}

/// Represents the possible events that can trigger state changes in the `StatefulLoader`.
enum StatefulLoaderEvent: Equatable {
    
    /// Initiates the loading process.
    case load
    /// Indicates that the loading process has failed.
    case loadFailure
    /// Indicates that the loading process has succeeded.
    case loadSuccess
    /// Resets the loader to its initial state, allowing it to be reused.
    case reset
}

/// Represents the effects that can be triggered by events in the `StatefulLoader`.
enum StatefulLoaderEffect: Equatable {
    
    /// Effect to perform the loading operation.
    case load
}

/// A reducer that manages state transitions in the `StatefulLoader` based on incoming events.
final class StatefulLoaderReducer {
    
    /// Initialises a new instance of the `StatefulLoaderReducer`.
    init() {}
}

extension StatefulLoaderReducer {
    
    /// Reduces the current state based on the given event and returns the new state and any triggered effect.
    /// - Parameters:
    ///   - state: The current state of the loader.
    ///   - event: The event that triggers a state transition.
    /// - Returns: A tuple containing the new state and an optional effect that was triggered.
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case .load:
            load(&state, &effect)
            
        case .loadFailure:
            state = .failed
            
        case .loadSuccess:
            state = .loaded
            
        case .reset:
            reset(&state, &effect)
        }
        
        return (state, effect)
    }
}

extension StatefulLoaderReducer {
    
    /// Typealias for the possible states of the StatefulLoader.
    typealias State = StatefulLoaderState
    /// Typealias for the possible events that can trigger state changes.
    typealias Event = StatefulLoaderEvent
    /// Typealias for the possible effects that can be triggered.
    typealias Effect = StatefulLoaderEffect
}

private extension StatefulLoaderReducer {
    
    /// Handles the logic for transitioning to the `loading` state and triggering the `load` effect.
    /// - Parameters:
    ///   - state: The current state, which will be updated to `loading` if appropriate.
    ///   - effect: An optional effect that will be set to `load` if the transition occurs.
    func load(
        _ state: inout State,
        _ effect: inout Effect?
    ) {
        switch state {
        case .failed, .loaded, .notStarted:
            state = .loading
            effect = .load
            
        default:
            break
        }
    }
    
    /// Handles the logic for transitioning to the `notStarted` state when a reset event is triggered.
    /// - Parameters:
    ///   - state: The current state, which will be updated to `notStarted` if appropriate.
    ///   - effect: An optional effect, which is not used in this case.
    func reset(
        _ state: inout State,
        _ effect: inout Effect?
    ) {
        switch state {
        case .failed, .loaded:
            state = .notStarted
            
        default:
            break
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
    
    func test_load_shouldDeliverLoadEffectOnNotStartedState() {
        
        assert(.notStarted, event: .load, delivers: .load)
    }
    
    func test_load_shouldChangeFailedStateToLoading() {
        
        assert(.failed, event: .load) {
            
            $0 = .loading
        }
    }
    
    func test_load_shouldDeliverLoadEffectOnLoadedState() {
        
        assert(.loaded, event: .load, delivers: .load)
    }
    
    func test_load_shouldChangeLoadedStateToLoading() {
        
        assert(.loaded, event: .load) {
            
            $0 = .loading
        }
    }
    
    func test_load_shouldDeliverLoadEffectOnFailedState() {
        
        assert(.failed, event: .load, delivers: .load)
    }
    
    func test_load_shouldNotChangeLoadingState() {
        
        assert(.loading, event: .load)
    }
    
    func test_load_shouldNotDeliverEffectOnLoadingState() {
        
        assert(.loading, event: .load, delivers: nil)
    }
    
    func test_loadFailure_shouldChangeState() {
        
        assert(.loading, event: .loadFailure) {
            
            $0 = .failed
        }
    }
    
    func test_loadFailure_shouldNotDeliverEffect() {
        
        assert(.loading, event: .loadFailure, delivers: nil)
    }
    
    func test_loadSuccess_shouldChangeState() {
        
        assert(.loading, event: .loadSuccess) {
            
            $0 = .loaded
        }
    }
    
    func test_loadSuccess_shouldNotDeliverEffect() {
        
        assert(.loading, event: .loadSuccess, delivers: nil)
    }
    
    func test_reset_shouldResetFailedState() {
        
        assert(.failed, event: .reset) {
            
            $0 = .notStarted
        }
    }
    
    func test_reset_shouldNotDeliverEffectOnFailedState() {
        
        assert(.failed, event: .reset, delivers: nil)
    }
    
    func test_reset_shouldNotChangeLoadingState() {
        
        assert(.loading, event: .reset)
    }
    
    func test_reset_shouldNotDeliverEffectOnLoadingState() {
        
        assert(.loading, event: .reset, delivers: nil)
    }
    
    func test_reset_shouldResetLoadedState() {
        
        assert(.loaded, event: .reset) {
            
            $0 = .notStarted
        }
    }
    
    func test_reset_shouldNotDeliverEffectOnLoadedState() {
        
        assert(.loaded, event: .reset, delivers: nil)
    }
    
    func test_reset_shouldNotChangeNotStartedState() {
        
        assert(.notStarted, event: .reset) {
            
            $0 = .notStarted
        }
    }
    
    func test_reset_shouldNotDeliverEffectOnNotStartedState() {
        
        assert(.notStarted, event: .reset, delivers: nil)
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
