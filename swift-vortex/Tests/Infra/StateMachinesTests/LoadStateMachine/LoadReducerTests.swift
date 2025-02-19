//
//  LoadReducerTests.swift
//
//
//  Created by Igor Malyarov on 19.02.2025.
//

import XCTest

final class LoadReducerTests: LoadTests {
    
    // MARK: - load
    
    func test_load_shouldSetStateToLoadingNil_onPendingState() {
        
        assert(.pending, event: .load) {
            
            $0 = .loading(nil)
        }
    }
    
    func test_load_shouldDeliverLoadEffect_onPendingState() {
        
        assert(.pending, event: .load, delivers: .load)
    }
    
    func test_load_shouldSetStateToLoadingNil_onFailureState() {
        
        assert(.failure(makeFailure()), event: .load) {
            
            $0 = .loading(nil)
        }
    }
    
    func test_load_shouldDeliverLoadEffect_onFailureState() {
        
        assert(.failure(makeFailure()), event: .load, delivers: .load)
    }
    
    func test_load_shouldSetStateToLoadingSuccess_onCompletedState() {
        
        let success = makeSuccess()
        
        assert(.completed(success), event: .load) {
            
            $0 = .loading(success)
        }
    }
    
    func test_load_shouldDeliverLoadEffect_onCompletedState() {
        
        assert(.completed(makeSuccess()), event: .load, delivers: .load)
    }
    
    func test_load_shouldNotChangeState_onLoadingNilState() {
        
        assert(.loading(nil), event: .load)
    }
    
    func test_load_shouldNotDeliverLoadEffect_onLoadingNilState() {
        
        assert(.loading(nil), event: .load, delivers: nil)
    }
    
    func test_load_shouldNotChangeState_onLoadingState() {
        
        assert(.loading(makeSuccess()), event: .load)
    }
    
    func test_load_shouldNotDeliverLoadEffect_onLoadingState() {
        
        assert(.loading(makeSuccess()), event: .load, delivers: nil)
    }
    
    // MARK: - loaded
    
    func test_loaded_shouldChangeStateToFailure_onLoadedFailure_onCompletedState() {
        
        let failure = makeFailure()
        
        assert(.completed(makeSuccess()), event: .loaded(.failure(failure))) {
            
            $0 = .failure(failure)
        }
    }
    
    func test_load_shouldNotDeliverLoadEffect_onLoadedFailure_onCompletedState() {
        
        assert(.completed(makeSuccess()), event: .loaded(.failure(makeFailure())), delivers: nil)
    }
    
    func test_loaded_shouldChangeStateToFailure_onLoadedFailure_onFailureState() {
        
        let failure = makeFailure()
        
        assert(.failure(makeFailure()), event: .loaded(.failure(failure))) {
            
            $0 = .failure(failure)
        }
    }
    
    func test_load_shouldNotDeliverLoadEffect_onLoadedFailure_onFailureState() {
        
        assert(.failure(makeFailure()), event: .loaded(.failure(makeFailure())), delivers: nil)
    }
    
    func test_loaded_shouldChangeStateToFailure_onLoadedFailure_onPendingState() {
        
        let failure = makeFailure()
        
        assert(.pending, event: .loaded(.failure(failure))) {
            
            $0 = .failure(failure)
        }
    }
    
    func test_load_shouldNotDeliverLoadEffect_onLoadedFailure_onPendingState() {
        
        assert(.pending, event: .loaded(.failure(makeFailure())), delivers: nil)
    }
    
    func test_loaded_shouldChangeStateToFailure_onLoadedFailure_onLoadingNilState() {
        
        let failure = makeFailure()
        
        assert(.loading(nil), event: .loaded(.failure(failure))) {
            
            $0 = .failure(failure)
        }
    }
    
    func test_load_shouldNotDeliverLoadEffect_onLoadedFailure_onLoadingNilState() {
        
        assert(.loading(nil), event: .loaded(.failure(makeFailure())), delivers: nil)
    }
    
    func test_loaded_shouldChangeStateToFailure_onLoadedFailure_onLoadingState() {
        
        let failure = makeFailure()
        
        assert(.loading(makeSuccess()), event: .loaded(.failure(failure))) {
            
            $0 = .failure(failure)
        }
    }
    
    func test_load_shouldNotDeliverLoadEffect_onLoadedFailure_onLoadingState() {
        
        assert(.loading(makeSuccess()), event: .loaded(.failure(makeFailure())), delivers: nil)
    }
    
    func test_loaded_shouldChangeStateToCompleted_onLoadedSuccess_onCompletedState() {
        
        let success = makeSuccess()
        
        assert(.completed(makeSuccess()), event: .loaded(.success(success))) {
            
            $0 = .completed(success)
        }
    }
    
    func test_load_shouldNotDeliverLoadEffect_onLoadedSuccess_onCompletedState() {
        
        assert(.completed(makeSuccess()), event: .loaded(.success(makeSuccess())), delivers: nil)
    }
    
    func test_loaded_shouldChangeStateToCompleted_onLoadedSuccess_onFailureState() {
        
        let success = makeSuccess()
        
        assert(.failure(makeFailure()), event: .loaded(.success(success))) {
            
            $0 = .completed(success)
        }
    }
    
    func test_load_shouldNotDeliverLoadEffect_onLoadedSuccess_onFailureState() {
        
        assert(.failure(makeFailure()), event: .loaded(.success(makeSuccess())), delivers: nil)
    }
    
    func test_loaded_shouldChangeStateToCompleted_onLoadedSuccess_onLoadingNilState() {
        
        let success = makeSuccess()
        
        assert(.loading(nil), event: .loaded(.success(success))) {
            
            $0 = .completed(success)
        }
    }
    
    func test_load_shouldNotDeliverLoadEffect_onLoadedSuccess_onLoadingNilState() {
        
        assert(.loading(nil), event: .loaded(.success(makeSuccess())), delivers: nil)
    }
    
    func test_loaded_shouldChangeStateToCompleted_onLoadedSuccess_onLoadingState() {
        
        let success = makeSuccess()
        
        assert(.loading(makeSuccess()), event: .loaded(.success(success))) {
            
            $0 = .completed(success)
        }
    }
    
    func test_load_shouldNotDeliverLoadEffect_onLoadedSuccess_onLoadingState() {
        
        assert(.loading(makeSuccess()), event: .loaded(.success(makeSuccess())), delivers: nil)
    }
    
    func test_loaded_shouldChangeStateToCompleted_onLoadedSuccess_onPendingState() {
        
        let success = makeSuccess()
        
        assert(.pending, event: .loaded(.success(success))) {
            
            $0 = .completed(success)
        }
    }
    
    func test_load_shouldNotDeliverLoadEffect_onLoadedSuccess_onPendingState() {
        
        assert(.pending, event: .loaded(.success(makeSuccess())), delivers: nil)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = LoadReducer<Success, Failure>
    
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
