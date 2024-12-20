//
//  PrepaymentSuccessPickerReducerTests.swift
//
//
//  Created by Igor Malyarov on 11.05.2024.
//

import UtilityServicePrepaymentCore
import XCTest

final class PrepaymentSuccessPickerReducerTests: XCTestCase {
    
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
    
    func test_didScrollTo_shouldNotChangeStateOnNotObserved() {
        
        let observeLast = 1
        let notObserved = makeOperator()
        let state = makeState(operators: [notObserved, makeOperator()])
        let sut = makeSUT(observeLast: observeLast)
        
        assertState(sut: sut, .didScrollTo(notObserved.id), on: state)
        assertNotObserving(notObserved.id, state, observeLast: observeLast)
    }
    
    func test_didScrollTo_shouldNotDeliverEffectOnNotObserved() {
        
        let observeLast = 1
        let notObserved = makeOperator()
        let state = makeState(operators: [notObserved, makeOperator()])
        let sut = makeSUT(observeLast: observeLast)
        
        assert(sut: sut, .didScrollTo(notObserved.id), on: state, effect: nil)
        assertNotObserving(notObserved.id, state, observeLast: observeLast)
    }
    
    func test_didScrollTo_shouldNotChangeState() {
        
        let observeLast = 2
        let oneOf = makeOperator()
        let state = makeState(operators: [oneOf, makeOperator()])
        let sut = makeSUT(observeLast: observeLast)
        
        assertState(sut: sut, .didScrollTo(oneOf.id), on: state)
    }
    
    func test_didScrollTo_shouldDeliverEffectWithLastOperatorID() {
        
        let observeLast = 2
        let (first, last) = (makeOperator(), makeOperator())
        let state = makeState(operators: [first, last])
        let sut = makeSUT(observeLast: observeLast)
        
        assert(sut: sut, .didScrollTo(first.id), on: state, effect: makePaginateEffect(operatorID: last.id, searchText: ""))
    }
    
    func test_didScrollTo_shouldNotChangeNonEmptySearchTextState() {
        
        let observeLast = 2
        let oneOf = makeOperator()
        let state = makeState(operators: [oneOf, makeOperator()], searchText: anyMessage())
        let sut = makeSUT(observeLast: observeLast)
        
        assertState(sut: sut, .didScrollTo(oneOf.id), on: state)
    }
    
    func test_didScrollTo_shouldDeliverEffectWithLastOperatorIDOnNonEmptySearchText() {
        
        let observeLast = 2
        let (first, last) = (makeOperator(), makeOperator())
        let searchText = anyMessage()
        let state = makeState(operators: [first, last], searchText: searchText)
        let sut = makeSUT(observeLast: observeLast)
        
        assert(sut: sut, .didScrollTo(first.id), on: state, effect: makePaginateEffect(operatorID: last.id, searchText: searchText))
    }
    
    // MARK: - load
    
    func test_load_shouldReplaceOperatorsWithEmptyOnEmpty() {
        
        assertState(.load([]), on: makeState()) {
            
            $0.operators = []
        }
    }
    
    func test_load_shouldNotDeliverEffectOnEmpty() {
        
        assert(.load([]), on: makeState(), effect: nil)
    }
    
    func test_load_shouldReplaceOperatorsWithNonEmpty() {
        
        let (oldOperator, newOperator) = (makeOperator(), makeOperator())
        let state = makeState(operators: [oldOperator])
        
        assertState(.load([newOperator]), on: state) {
            
            $0.operators = [newOperator]
        }
    }
    
    func test_load_shouldNotDeliverEffectOnNonEmpty() {
        
        let (oldOperator, newOperator) = (makeOperator(), makeOperator())
        let state = makeState(operators: [oldOperator])
        
        assert(.load([newOperator]), on: state, effect: nil)
    }
    
    // MARK: - page
    
    func test_page_shouldNotChangeStateOnEmptyPage() {
        
        assertState(.page([]), on: makeState())
    }
    
    func test_page_shouldNotDeliverEffectOnEmptyPage() {
        
        assert(.page([]), on: makeState(), effect: nil)
    }
    
    func test_page_shouldAppendNewOperators() {
        
        let (oldOperator, newOperator) = (makeOperator(), makeOperator())
        let state = makeState(operators: [oldOperator])
        
        assertState(.page([newOperator]), on: state) {
            
            $0.operators = [oldOperator, newOperator]
        }
    }
    
    func test_page_shouldNotAppendExistingOperators() {
        
        let oldOperator = makeOperator()
        let newOperator = oldOperator
        let state = makeState(operators: [oldOperator])
        
        assertState(.page([newOperator]), on: state) {
            
            $0.operators = [oldOperator]
        }
    }
    
    func test_page_shouldNotDeliverEffect() {
        
        let newOperators = [makeOperator()]
        
        assert(.page(newOperators), on: makeState(), effect: nil)
    }
    
    // MARK: - search
    
    func test_search_shouldChangeEmptyState() {
        
        let searchText = anyMessage()
        
        assertState(.search(searchText), on: makeEmptyState()) {
            
            $0.searchText = searchText
        }
    }
    
    func test_search_shouldDeliverEffectOnEmptyState() {
        
        let sut = makeSUT()
        let searchText = anyMessage()
        
        assert(sut: sut, .search(searchText), on: makeEmptyState(), effect: makeSearchEffect(searchText: searchText))
    }
    
    func test_search_shouldChangeEmptySearchTextState() {
        
        let emptySearchTextState = makeState(searchText: "")
        let searchText = anyMessage()
        
        assertState(.search(searchText), on: emptySearchTextState) {
            
            $0.searchText = searchText
        }
    }
    
    func test_search_shouldDeliverEffectOnEmptySearchText() {
        
        let sut = makeSUT()
        let emptySearchTextState = makeState(searchText: "")
        let searchText = anyMessage()
        
        assert(sut: sut, .search(searchText), on: emptySearchTextState, effect: makeSearchEffect(searchText: searchText))
    }
    
    func test_search_shouldChangeNonEmptySearchTextState() {
        
        let nonEmptySearchTextState = makeState(searchText: anyMessage())
        let searchText = anyMessage()
        
        assertState(.search(searchText), on: nonEmptySearchTextState) {
            
            $0.searchText = searchText
        }
    }
    
    func test_search_shouldDeliverEffect() {
        
        let sut = makeSUT()
        let nonEmptySearchTextState = makeState(searchText: anyMessage())
        let searchText = anyMessage()
        
        assert(sut: sut, .search(searchText), on: nonEmptySearchTextState, effect: makeSearchEffect(searchText: searchText))
    }
    
    func test_search_shouldChangeNonEmptySearchTextStateWithEmptySearch() {
        
        let nonEmptySearchTextState = makeState(searchText: anyMessage())
        
        assertState(.search(""), on: nonEmptySearchTextState) {
            
            $0.searchText = ""
        }
    }
    
    func test_search_shouldDeliverEffectWithEmptySearch() {
        
        let sut = makeSUT()
        let nonEmptySearchTextState = makeState(searchText: anyMessage())
        
        assert(sut: sut, .search(""), on: nonEmptySearchTextState, effect: makeSearchEffect(searchText: ""))
    }
    
    // MARK: - Helpers
    
    private typealias SUT = PrepaymentSuccessPickerReducer<LastPayment, Operator>
    
    private func makeSUT(
        observeLast: Int = 3,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT(observeLast: observeLast)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private typealias UpdateStateToExpected<State> = (_ state: inout State) -> Void
    
    private func assertState(
        sut: SUT? = nil,
        _ event: Event,
        on state: SUT.State,
        updateStateToExpected: UpdateStateToExpected<SUT.State>? = nil,
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
        on state: SUT.State,
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
        _ state: SUT.State,
        _ missingID: Operator.ID,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let operatorIDs = Set(state.operators.map(\.id))
        
        XCTAssertFalse(operatorIDs.contains(missingID), "Expected id \(missingID) to be missing but was found in state \(state).", file: file, line: line)
    }
    
    private func assertNotObserving(
        _ operatorID: Operator.ID,
        _ state: SUT.State,
        observeLast: Int,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let operatorIDs = Set(state.operators.map(\.id).suffix(observeLast))
        
        XCTAssertFalse(operatorIDs.contains(operatorID), "Expected id \(operatorID) to be not observing but was found in last \(observeLast) in state \(state).", file: file, line: line)
    }
}
