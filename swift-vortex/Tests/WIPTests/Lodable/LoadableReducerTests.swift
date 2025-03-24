//
//  LoadableReducerTests.swift
//
//
//  Created by Igor Malyarov on 20.03.2025.
//

import XCTest

final class LoadableReducerTests: LoadableTests {
    
    // MARK: - load
    
    func test_load_shouldNotChangeState_onNilResource_loading() {
        
        let state = makeState(status: .loading)
        
        assert(state, event: .load)
    }
    
    func test_load_shouldNotDeliverEffect_onNilResource_loading() {
        
        let state = makeState(status: .loading)
        
        assert(state, event: .load, delivers: nil)
    }
    
    func test_load_shouldNotChangeState_onNonNilResource_loading() {
        
        let state = makeState(resource: makeResource(), status: .loading)
        
        assert(state, event: .load)
    }
    
    func test_load_shouldNotDeliverEffect_onNonNilResource_loading() {
        
        let state = makeState(resource: makeResource(), status: .loading)
        
        assert(state, event: .load, delivers: nil)
    }
    
    func test_load_shouldChangeStatus_onNilResource_loaded() {
        
        let state = makeState(status: .loaded)
        
        assert(state, event: .load) { $0.status = .loading }
    }
    
    func test_load_shouldDeliverEffect_onNilResource_loaded() {
        
        let state = makeState(status: .loaded)
        
        assert(state, event: .load, delivers: .load)
    }
    
    func test_load_shouldChangeStatus_onNonNilResource_loaded() {
        
        let state = makeState(resource: makeResource(), status: .loaded)
        
        assert(state, event: .load) { $0.status = .loading }
    }
    
    func test_load_shouldDeliverEffect_onNonNilResource_loaded() {
        
        let state = makeState(resource: makeResource(), status: .loaded)
        
        assert(state, event: .load, delivers: .load)
    }
    
    func test_load_shouldChangeStatus_onNilResource_failure() {
        
        let state = makeState(status: .failure(makeFailure()))
        
        assert(state, event: .load) { $0.status = .loading }
    }
    
    func test_load_shouldDeliverEffect_onNilResource_failure() {
        
        let state = makeState(status: .failure(makeFailure()))
        
        assert(state, event: .load, delivers: .load)
    }
    
    func test_load_shouldChangeStatus_onNonNilResource_failure() {
        
        let state = makeState(resource: makeResource(), status: .failure(makeFailure()))
        
        assert(state, event: .load) { $0.status = .loading }
    }
    
    func test_load_shouldDeliverEffect_onNonNilResource_failure() {
        
        let state = makeState(resource: makeResource(), status: .failure(makeFailure()))
        
        assert(state, event: .load, delivers: .load)
    }
    
    // MARK: - loaded
    
    func test_loaded_shouldChangeStatus_onFailure_resourceNil_loading() {
        
        let failure = makeFailure()
        let state = makeState(status: .loading)
        
        assert(state, event: .loaded(.failure(failure))) {
            
            $0.status = .failure(failure)
        }
    }
    
    func test_loaded_shouldNotDeliverEffect_onFailure_resourceNil_loading() {
        
        let state = makeState(status: .loading)
        
        assert(state, event: .loaded(.failure(makeFailure())), delivers: nil)
    }
    
    func test_loaded_shouldChangeStateStatus_onFailure_resourceNonNil_loading() {
        
        let failure = makeFailure()
        let state = makeState(resource: makeResource(), status: .loading)
        
        assert(state, event: .loaded(.failure(failure))) {
            
            $0.status = .failure(failure)
        }
    }
    
    func test_loaded_shouldNotDeliverEffect_onFailure_resourceNonNil_loading() {
        
        let state = makeState(resource: makeResource(), status: .loading)
        
        assert(state, event: .loaded(.failure(makeFailure())), delivers: nil)
    }
    
    func test_loaded_shouldChangeStatus_onFailure_resourceNil_loaded() {
        
        let failure = makeFailure()
        let state = makeState(status: .loaded)
        
        assert(state, event: .loaded(.failure(failure))) {
            
            $0.status = .failure(failure)
        }
    }
    
    func test_loaded_shouldNotDeliverEffect_onFailure_resourceNil_loaded() {
        
        let state = makeState(status: .loaded)
        
        assert(state, event: .loaded(.failure(makeFailure())), delivers: nil)
    }
    
    func test_loaded_shouldChangeStateStatus_onFailure_resourceNonNil_loaded() {
        
        let failure = makeFailure()
        let state = makeState(resource: makeResource(), status: .loaded)
        
        assert(state, event: .loaded(.failure(failure))) {
            
            $0.status = .failure(failure)
        }
    }
    
    func test_loaded_shouldNotDeliverEffect_onFailure_resourceNonNil_loaded() {
        
        let state = makeState(resource: makeResource(), status: .loaded)
        
        assert(state, event: .loaded(.failure(makeFailure())), delivers: nil)
    }
    
    func test_loaded_shouldChangeStatus_onFailure_resourceNil_failure() {
        
        let failure = makeFailure()
        let state = makeState(status: .failure(makeFailure()))
        
        assert(state, event: .loaded(.failure(failure))) {
            
            $0.status = .failure(failure)
        }
    }
    
    func test_loaded_shouldNotDeliverEffect_onFailure_resourceNil_failure() {
        
        let state = makeState(status: .failure(makeFailure()))
        
        assert(state, event: .loaded(.failure(makeFailure())), delivers: nil)
    }
    
    func test_loaded_shouldChangeStatus_onFailure_resourceNonNil_failure() {
        
        let failure = makeFailure()
        let state = makeState(resource: makeResource(), status: .failure(makeFailure()))
        
        assert(state, event: .loaded(.failure(failure))) {
            
            $0.status = .failure(failure)
        }
    }
    
    func test_loaded_shouldNotDeliverEffect_onFailure_resourceNonNil_failure() {
        
        let state = makeState(resource: makeResource(), status: .failure(makeFailure()))
        
        assert(state, event: .loaded(.failure(makeFailure())), delivers: nil)
    }
    
    func test_loaded_shouldChangeState_onSuccess_resourceNil_loaded() {
        
        let resource = makeResource()
        let state = makeState(status: .loaded)
        
        assert(state, event: .loaded(.success(resource))) {
            
            $0.resource = resource
            $0.status = .loaded
        }
    }
    
    func test_loaded_shouldNotDeliverEffect_onSuccess_resourceNil_loaded() {
        
        let state = makeState(status: .loaded)
        
        assert(state, event: .loaded(.success(makeResource())), delivers: nil)
    }
    
    func test_loaded_shouldChangeState_onSuccess_resourceNonNil_loaded() {
        
        let resource = makeResource()
        let state = makeState(resource: makeResource(), status: .loaded)
        
        assert(state, event: .loaded(.success(resource))) {
            
            $0.resource = resource
            $0.status = .loaded
        }
    }
    
    func test_loaded_shouldNotDeliverEffect_onSuccess_resourceNonNil_loaded() {
        
        let state = makeState(resource: makeResource(), status: .loaded)
        
        assert(state, event: .loaded(.success(makeResource())), delivers: nil)
    }
    
    func test_loaded_shouldChangeState_onSuccess_resourceNil_failure() {
        
        let resource = makeResource()
        let state = makeState(status: .failure(makeFailure()))
        
        assert(state, event: .loaded(.success(resource))) {
            
            $0.resource = resource
            $0.status = .loaded
        }
    }
    
    func test_loaded_shouldNotDeliverEffect_onSuccess_resourceNil_failure() {
        
        let state = makeState(status: .failure(makeFailure()))
        
        assert(state, event: .loaded(.success(makeResource())), delivers: nil)
    }
    
    func test_loaded_shouldChangeState_onSuccess_resourceNonNil_failure() {
        
        let resource = makeResource()
        let state = makeState(resource: makeResource(), status: .failure(makeFailure()))
        
        assert(state, event: .loaded(.success(resource))) {
            
            $0.resource = resource
            $0.status = .loaded
        }
    }
    
    func test_loaded_shouldNotDeliverEffect_onSuccess_resourceNonNil_failure() {
        
        let state = makeState(resource: makeResource(), status: .failure(makeFailure()))
        
        assert(state, event: .loaded(.success(makeResource())), delivers: nil)
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
        status: State.LoadStatus
    ) -> LoadableState<Resource, Failure> {
        
        return .init(resource: resource, status: status)
    }
    
    private func makeState(
        resource: Resource? = nil,
        failure: Failure
    ) -> LoadableState<Resource, Failure> {
        
        return .init(resource: resource, status: .failure(failure))
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
