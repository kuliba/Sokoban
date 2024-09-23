//
//  FailedPaymentProviderPickerFlowReducerTests.swift
//
//
//  Created by Igor Malyarov on 23.09.2024.
//

import PayHub
import XCTest

final class FailedPaymentProviderPickerFlowReducerTests: FailedPaymentProviderPickerFlowTests {
    
    func test_destination_shouldChangeState_nilDestination() {
        
        let destination = makeDestination()
        assert(makeState(destination: nil), event: .destination(destination)) {
            
            $0.destination = destination
        }
    }
    
    func test_destination_shouldNotDeliverEffect_nilDestination() {
        
        assert(makeState(destination: nil), event: .destination(makeDestination()), delivers: nil)
    }
    
    func test_destination_shouldChangeState() {
        
        let destination = makeDestination()
        assert(makeState(destination: makeDestination()), event: .destination(destination)) {
            
            $0.destination = destination
        }
    }
    
    func test_destination_shouldNotDeliverEffect() {
        
        assert(makeState(destination: makeDestination()), event: .destination(makeDestination()), delivers: nil)
    }
    
    func test_resetDestination_shouldChangeState() {
        
        assert(makeState(destination: makeDestination()), event: .resetDestination) {
            
            $0.destination = nil
        }
    }
    
    func test_resetDestination_shouldNotDeliverEffect() {
        
        assert(makeState(destination: makeDestination()), event: .resetDestination, delivers: nil)
    }
    
    func test_select_detailPay_shouldNotChangeState() {
        
        assert(makeState(), event: .select(.detailPay))
    }
    
    func test_select_detailPay_shouldDeliverEffect() {
        
        assert(makeState(), event: .select(.detailPay), delivers: .select(.detailPay))
    }
    
    // MARK: - Helpers
    
    private typealias SUT = FailedPaymentProviderPickerFlowReducer<Destination>
    
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
