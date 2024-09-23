//
//  FlowButtonReducerTests.swift
//
//
//  Created by Igor Malyarov on 18.08.2024.
//

import PayHub
import XCTest

final class FlowButtonReducerTests: FlowButtonTests {
    
    // MARK: - buttonTap
    
    func test_buttonTap_shouldNotChangeState() {
        
        assert(makeState(), event: .buttonTap)
    }
    
    func test_buttonTap_shouldDeliverEffect() {
        
        assert(makeState(), event: .buttonTap, delivers: .processButtonTap)
    }
    
    // MARK: - dismissDestination
    
    func test_dismissDestination_shouldSetDestinationToNil() {
        
        assert(makeState(destination: makeDestination()), event: .dismissDestination) {
            
            $0.destination = nil
        }
    }
    
    func test_dismissDestination_shouldNotDeliverEffect() {
        
        assert(makeState(), event: .dismissDestination, delivers: nil)
    }
    
    // MARK: - setDestination
    
    func test_setDestination_shouldSetDestination() {
        
        let destination = makeDestination()
        
        assert(makeState(), event: .setDestination(destination)) {
            
            $0.destination = destination
        }
    }
    
    func test_setDestination_shouldNotDeliverEffect() {
        
        assert(makeState(), event: .setDestination(makeDestination()), delivers: nil)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = FlowButtonReducer<Destination>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func makeState(
        destination: Destination? = nil
    ) -> SUT.State {
        
        return .init(destination: destination)
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
