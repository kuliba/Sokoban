//
//  FailedPaymentProviderPickerContentReducerTests.swift
//
//
//  Created by Igor Malyarov on 23.09.2024.
//

import PayHub
import XCTest

final class FailedPaymentProviderPickerContentReducerTests: XCTestCase {
    
    func test_resetSelection_shouldSetSelectionToNil() {
        
        assert(makeState(selection: .detailPay), event: .resetSelection) {
            
            $0.selection = nil
        }
    }
    
    func test_resetSelection_shouldNotDeliverEffect() {
        
        assert(makeState(selection: .detailPay), event: .resetSelection, delivers: nil)
    }
    
    func test_detailPay_shouldSetSelectionToDetailPay() {
        
        assert(makeState(selection: nil), event: .detailPay) {
            
            $0.selection = .detailPay
        }
    }
    
    func test_detailPay_shouldNotDeliverEffect() {
        
        assert(makeState(selection: nil), event: .detailPay, delivers: nil)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = FailedPaymentProviderPickerContentReducer
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func makeState(
        selection: SUT.State.Selection? = nil
    ) -> SUT.State {
        
        return .init(selection: selection)
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
