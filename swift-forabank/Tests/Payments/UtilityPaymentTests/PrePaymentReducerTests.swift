//
//  PrePaymentReducerTests.swift
//
//
//  Created by Igor Malyarov on 03.03.2024.
//

import XCTest

final class PrePaymentReducerTests: XCTestCase {
    
    // MARK: - scan
    
    func test_scan_shouldChangeSelectingStateToScanning() {
        
        assertState(.scan, on: .selecting) {
            
            $0 = .scanning
        }
    }
    
    func test_scan_shouldNotChangeSelectedState_last() {
        
        assertState(.scan, on: .selected(.last(makeLastPayment())))
    }
    
    func test_scan_shouldNotChangeSelectedState_operator() {
        
        assertState(.scan, on: .selected(.operator(makeOperator())))
    }
    
    // MARK: - select
    
    func test_select_shouldChangeSelectingStateToSelected_last() {
        
        let lastPayment = makeLastPayment()
        
        assertState(.select(.last(lastPayment)), on: .selecting) {
            
            $0 = .selected(.last(lastPayment))
        }
    }
    
    func test_select_shouldChangeSelectingStateToSelected_operator() {
        
        let `operator` = makeOperator()
        
        assertState(.select(.operator(`operator`)), on: .selecting) {
            
            $0 = .selected(.operator(`operator`))
        }
    }
    
    func test_select_shouldNotChangeScanningState_last() {
        
        assertState(
            .select(.last(makeLastPayment())),
            on: .scanning
        )
    }
    
    func test_select_shouldNotChangeScanningState_operator() {
        
        assertState(
            .select(.operator(makeOperator())),
            on: .scanning
        )
    }
    
    func test_select_shouldNotChangeSelectedState_last_last() {
        
        assertState(
            .select(.last(makeLastPayment())),
            on: .selected(.last(makeLastPayment()))
        )
    }
    
    func test_select_shouldNotChangeSelectedState_last_operator() {
        
        assertState(
            .select(.last(makeLastPayment())),
            on: .selected(.operator(makeOperator()))
        )
    }
    
    func test_select_shouldNotChangeSelectedState_operator_operator() {
        
        assertState(
            .select(.operator(makeOperator())),
            on: .selected(.operator(makeOperator()))
        )
    }
    
    func test_select_shouldNotChangeSelectedState_operator_last() {
        
        assertState(
            .select(.operator(makeOperator())),
            on: .selected(.last(makeLastPayment()))
        )
    }
    
    // MARK: - Helpers
    
    private typealias SUT = PrePaymentReducer
    
    private typealias State = SUT.State
    private typealias Event = SUT.Event
    private typealias Effect = SUT.Effect
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func makeLastPayment(
        _ id: String = UUID().uuidString
    ) -> LastPayment {
        
        .init(id: id)
    }
    
    private func makeOperator(
        _ id: String = UUID().uuidString
    ) -> Operator {
        
        .init(id: id)
    }
    
    private typealias UpdateStateToExpected<State> = (_ state: inout State) -> Void
    
    private func assertState(
        sut: SUT? = nil,
        _ event: Event,
        on state: State,
        updateStateToExpected: UpdateStateToExpected<State>? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let sut = sut ?? makeSUT(file: file, line: line)

        var expectedState = state
        updateStateToExpected?(&expectedState)
        
        let (receivedState, _) = sut.reduce(state, event)
        
        XCTAssertNoDiff(
            receivedState,
            expectedState,
            "\nExpected \(expectedState), but got \(receivedState) instead.",
            file: file, line: line
        )
    }
    
    private func assert(
        sut: SUT? = nil,
        _ event: Event,
        on state: State,
        effect expectedEffect: Effect?,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let sut = sut ?? makeSUT(file: file, line: line)
        let (_, receivedEffect) = sut.reduce(state, event)
        
        XCTAssertNoDiff(
            receivedEffect,
            expectedEffect,
            "\nExpected \(String(describing: expectedEffect)), but got \(String(describing: receivedEffect)) instead.",
            file: file, line: line
        )
    }
}
