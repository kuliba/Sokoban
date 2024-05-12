//
//  PrepaymentPickerReducerTests.swift
//
//
//  Created by Igor Malyarov on 11.05.2024.
//

import UtilityServicePrepaymentCore
import XCTest

final class PrepaymentPickerReducerTests: XCTestCase {
    
    // MARK: - didScrollTo
    
    func test_didScrollTo_shouldNotChangeEmptyState() {
        
        assertState(.didScrollTo(makeOperatorID()), on: makeEmptyState())
    }
    
    func test_didScrollTo_shouldNotDeliverEffectOnEmptyState() {
        
        assert(.didScrollTo(makeOperatorID()), on: makeEmptyState(), effect: nil)
    }
    
    func test_didScrollTo_shouldNotChangeStateOnMissingID() {
        
        let state = makeState(operators: [makeOperator(), makeOperator()])
        let missingID = makeOperatorID()
        
        assertState(.didScrollTo(missingID), on: state)
        assertMissingID(state, missingID)
    }
    
    func test_didScrollTo_shouldNotDeliverEffectOnMissingID() {
        
        let state = makeState(operators: [makeOperator(), makeOperator()])
        let missingID = makeOperatorID()
        
        assert(.didScrollTo(missingID), on: state, effect: nil)
        assertMissingID(state, missingID)
    }
    
    func test_didScrollTo_shouldNotChangeStateOnMissingFromObservation() {
        
        let observeLast = 1
        let oneOf = makeOperator()
        let state = makeState(operators: [oneOf, makeOperator()])
        let sut = makeSUT(observeLast: observeLast)
        
        assertState(sut: sut, .didScrollTo(oneOf.id), on: state)
        assertNotObserving(oneOf.id, state, observeLast: observeLast)
    }
    
    func test_didScrollTo_shouldNotDeliverEffectOnMissingFromObservation() {
        
        let observeLast = 1
        let oneOf = makeOperator()
        let state = makeState(operators: [oneOf, makeOperator()])
        let sut = makeSUT(observeLast: observeLast)
        
        assert(sut: sut, .didScrollTo(oneOf.id), on: state, effect: nil)
        assertNotObserving(oneOf.id, state, observeLast: observeLast)
    }
    
    func test_didScrollTo_shouldNotChangeState() {
        
        let observeLast = 2
        let oneOf = makeOperator()
        let state = makeState(operators: [oneOf, makeOperator()])
        let sut = makeSUT(observeLast: observeLast)
        
        assertState(sut: sut, .didScrollTo(oneOf.id), on: state)
    }
    
    func test_didScrollTo_shouldDeliverEffect() {
        
        let (observeLast, pageSize) = (2, 33)
        let oneOf = makeOperator()
        let state = makeState(operators: [oneOf, makeOperator()])
        let sut = makeSUT(
            observeLast: observeLast,
            pageSize: pageSize
        )
        
        assert(sut: sut, .didScrollTo(oneOf.id), on: state, effect: .paginate(oneOf.id, pageSize))
    }
    
    // MARK: - page
    
    func test_page_shouldNotChangeStateOnEmpty() {
        
        assertState(.page([]), on: makeState())
    }
    
    func test_page_shouldNotDeliverEffectOnEmpty() {
        
        assert(.page([]), on: makeState(), effect: nil)
    }
    
    func test_page_shouldAppendOperators() {
        
        let (oldOperator, newOperator) = (makeOperator(), makeOperator())
        let state = makeState(operators: [oldOperator])
        
        assertState(.page([newOperator]), on: state) {
            
            $0.operators = [oldOperator, newOperator]
        }
    }
    
    func test_page_shouldNotDeliverEffect() {
        
        let newOperators = [makeOperator()]
        
        assert(.page(newOperators), on: makeState(), effect: nil)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = PrepaymentPickerReducer<LastPayment, Operator>
    
    private func makeSUT(
        observeLast: Int = 3,
        pageSize: Int = 9,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT(observeLast: observeLast, pageSize: pageSize)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
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
    
    private func assertMissingID(
        _ state: State,
        _ missingID: Operator.ID,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let operatorIDs = Set(state.operators.map(\.id))
        
        XCTAssertFalse(operatorIDs.contains(missingID), "Expected id \(missingID) to be missing but was found in state \(state).", file: file, line: line)
    }
    
    private func assertNotObserving(
        _ operatorID: Operator.ID,
        _ state: State,
        observeLast: Int,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let operatorIDs = Set(state.operators.map(\.id).suffix(observeLast))
        
        XCTAssertFalse(operatorIDs.contains(operatorID), "Expected id \(operatorID) to be not observing but was found in last \(observeLast) in state \(state).", file: file, line: line)
    }
}
