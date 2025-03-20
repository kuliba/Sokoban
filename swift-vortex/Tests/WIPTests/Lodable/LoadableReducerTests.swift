//
//  LoadableReducerTests.swift
//
//
//  Created by Igor Malyarov on 20.03.2025.
//

import XCTest

final class LoadableReducerTests: LoadableTests {
    
    // MARK: - load
    
    func test_load_shouldResetResult_onNilResource_resultSuccess() {
        
        let state = makeState(result: .success(.init()))
        
        assert(state, event: .load) {
            
            $0.result = nil
        }
    }
    
    func test_load_shouldSetEffect_onNilResource_resultSuccess() {
        
        let state = makeState(result: .success(.init()))
        
        assert(state, event: .load, delivers: .load)
    }
    
    func test_load_shouldResetResult_onNonNilResource_resultSuccess() {
        
        let state = makeState(result: .success(.init()))
        
        assert(state, event: .load) {
            
            $0.result = nil
        }
    }
    
    func test_load_shouldSetEffect_onNonNilResource_resultSuccess() {
        
        let state = makeState(result: .success(.init()))
        
        assert(state, event: .load, delivers: .load)
    }
    
    func test_load_shouldResetResult_onNilResource_resultFailure() {
        
        let state = makeState(failure: makeFailure())
        
        assert(state, event: .load) {
            
            $0.result = nil
        }
    }
    
    func test_load_shouldSetEffect_onNilResource_resultFailure() {
        
        let state = makeState(failure: makeFailure())
        
        assert(state, event: .load, delivers: .load)
    }
    
    func test_load_shouldResetResult_onNonNilResource_resultFailure() {
        
        let state = makeState(failure: makeFailure())
        
        assert(state, event: .load) {
            
            $0.result = nil
        }
    }
    
    func test_load_shouldSetEffect_onNonNilResource_resultFailure() {
        
        let state = makeState(failure: makeFailure())
        
        assert(state, event: .load, delivers: .load)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = LoadableReducer<Resource, Failure>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func makeState(
        resource: Resource? = nil,
        result: Result<LoadableState<Resource, Failure>.Success, Failure>? = nil
    ) -> LoadableState<Resource, Failure> {
        
        return .init(resource: resource, result: result)
    }
    
    private func makeState(
        resource: Resource? = nil,
        failure: Failure
    ) -> LoadableState<Resource, Failure> {
        
        return .init(resource: resource, result: .failure(failure))
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
        
        let (_, receivedEffect): (SUT.State, SUT.Effect?) = sut.reduce(state, event)
        
        XCTAssertNoDiff(
            receivedEffect,
            expectedEffect,
            "\nExpected \(String(describing: expectedEffect)), but got \(String(describing: receivedEffect)) instead.",
            file: file, line: line
        )
        
        return receivedEffect
    }
}
