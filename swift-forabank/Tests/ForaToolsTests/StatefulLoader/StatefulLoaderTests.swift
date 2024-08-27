//
//  StatefulLoaderTests.swift
//
//
//  Created by Igor Malyarov on 27.08.2024.
//

import ForaTools
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
