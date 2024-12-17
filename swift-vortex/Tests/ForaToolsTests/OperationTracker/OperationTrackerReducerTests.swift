//
//  OperationTrackerTests.swift
//
//
//  Created by Igor Malyarov on 27.08.2024.
//

import ForaTools
import XCTest

final class OperationTrackerReducerTests: XCTestCase {
    
    func test_fail_shouldChangeState() {
        
        assert(.inflight, event: .fail) {
            
            $0 = .failure
        }
    }
    
    func test_fail_shouldNotDeliverEffect() {
        
        assert(.inflight, event: .fail, delivers: nil)
    }
    
    func test_reset_shouldResetFailedState() {
        
        assert(.failure, event: .reset) {
            
            $0 = .notStarted
        }
    }
    
    func test_reset_shouldNotDeliverEffectOnFailedState() {
        
        assert(.failure, event: .reset, delivers: nil)
    }
    
    func test_reset_shouldNotChangeLoadingState() {
        
        assert(.inflight, event: .reset)
    }
    
    func test_reset_shouldNotDeliverEffectOnLoadingState() {
        
        assert(.inflight, event: .reset, delivers: nil)
    }
    
    func test_reset_shouldResetLoadedState() {
        
        assert(.success, event: .reset) {
            
            $0 = .notStarted
        }
    }
    
    func test_reset_shouldNotDeliverEffectOnLoadedState() {
        
        assert(.success, event: .reset, delivers: nil)
    }
    
    func test_reset_shouldNotChangeNotStartedState() {
        
        assert(.notStarted, event: .reset) {
            
            $0 = .notStarted
        }
    }
    
    func test_reset_shouldNotDeliverEffectOnNotStartedState() {
        
        assert(.notStarted, event: .reset, delivers: nil)
    }
    
    func test_start_shouldChangeNotStartedStateToLoading() {
        
        assert(.notStarted, event: .start) {
            
            $0 = .inflight
        }
    }
    
    func test_start_shouldDeliverStartEffectOnNotStartedState() {
        
        assert(.notStarted, event: .start, delivers: .start)
    }
    
    func test_start_shouldChangeFailedStateToLoading() {
        
        assert(.failure, event: .start) {
            
            $0 = .inflight
        }
    }
    
    func test_start_shouldDeliverStartEffectOnLoadedState() {
        
        assert(.success, event: .start, delivers: .start)
    }
    
    func test_start_shouldChangeLoadedStateToLoading() {
        
        assert(.success, event: .start) {
            
            $0 = .inflight
        }
    }
    
    func test_start_shouldDeliverStartEffectOnFailedState() {
        
        assert(.failure, event: .start, delivers: .start)
    }
    
    func test_start_shouldNotChangeLoadingState() {
        
        assert(.inflight, event: .start)
    }
    
    func test_start_shouldNotDeliverEffectOnLoadingState() {
        
        assert(.inflight, event: .start, delivers: nil)
    }
    
    func test_succeed_shouldChangeState() {
        
        assert(.inflight, event: .succeed) {
            
            $0 = .success
        }
    }
    
    func test_succeed_shouldNotDeliverEffect() {
        
        assert(.inflight, event: .succeed, delivers: nil)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = OperationTrackerReducer
    
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
