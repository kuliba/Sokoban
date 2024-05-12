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
    
    func test_didScrollTo_shouldDeliverEffectWithLastOperatorID() {
        
        let (observeLast, pageSize) = (2, 33)
        let (first, last) = (makeOperator(), makeOperator())
        let state = makeState(operators: [first, last])
        let sut = makeSUT(
            observeLast: observeLast,
            pageSize: pageSize
        )
        
        assert(sut: sut, .didScrollTo(first.id), on: state, effect: makePaginateEffect(operatorID: last.id, pageSize: pageSize, searchText: ""))
    }
    
    func test_didScrollTo_shouldNotChangeNonEmptySearchTextState() {
        
        let observeLast = 2
        let oneOf = makeOperator()
        let state = makeState(operators: [oneOf, makeOperator()], searchText: "abc")
        let sut = makeSUT(observeLast: observeLast)
        
        assertState(sut: sut, .didScrollTo(oneOf.id), on: state)
    }
    
    func test_didScrollTo_shouldDeliverEffectWithLastOperatorIDOnNonEmptySearchText() {
        
        let (observeLast, pageSize) = (2, 33)
        let (first, last) = (makeOperator(), makeOperator())
        let searchText = anyMessage()
        let state = makeState(operators: [first, last], searchText: searchText)
        let sut = makeSUT(
            observeLast: observeLast,
            pageSize: pageSize
        )
        
        assert(sut: sut, .didScrollTo(first.id), on: state, effect: makePaginateEffect(operatorID: last.id, pageSize: pageSize, searchText: searchText))
    }
    
    // MARK: - page
    
    func test_page_shouldNotChangeStateOnEmpty() {
        
        assertState(.page([]), on: makeState())
    }
    
    func test_page_shouldNotDeliverEffectOnEmpty() {
        
        assert(.page([]), on: makeState(), effect: nil)
    }
    
    func test_page_shouldToggleIsSearchingAndReplaceOperatorsOnIsSearching() {
        
        let (oldOperator, newOperator) = (makeOperator(), makeOperator())
        let state = makeState(operators: [oldOperator], isSearching: true)
        
        assertState(.page([newOperator]), on: state) {
            
            $0.isSearching = false
            $0.operators = [newOperator]
        }
    }
    
    func test_page_shouldNotDeliverEffectOnIsSearching() {
        
        let newOperators = [makeOperator()]
        let state = makeState(isSearching: true)

        assert(.page(newOperators), on: state, effect: nil)
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
    
    // MARK: - search
    
    func test_search_shouldNotChangeEmptyState() {
        
        assertState(.search(anyMessage()), on: makeEmptyState())
    }
    
    func test_search_shouldNotDeliverEffectOnEmptyState() {
        
        assert(.search(anyMessage()), on: makeEmptyState(), effect: nil)
    }
    
    func test_search_shouldChangeEmptySearchTextState() {
        
        let emptySearchTextState = makeState(searchText: "")
        let searchText = anyMessage()
        
        assertState(.search(searchText), on: emptySearchTextState) {
            
            $0.isSearching = true
            $0.searchText = searchText
        }
    }
    
    func test_search_shouldDeliverEffectOnEmptySearchText() {
        
        let pageSize = makePageSize()
        let sut = makeSUT(pageSize: pageSize)
        let emptySearchTextState = makeState(searchText: "")
        let searchText = anyMessage()

        let effect = makePaginateEffect(
            operatorID: nil, 
            pageSize: pageSize,
            searchText: searchText
        )
        
        assert(sut: sut, .search(searchText), on: emptySearchTextState, effect: effect)
    }
    
    func test_search_shouldChangeNonEmptySearchTextState() {
        
        let nonEmptySearchTextState = makeState(searchText: "abc")
        let searchText = anyMessage()
        
        assertState(.search(searchText), on: nonEmptySearchTextState) {
            
            $0.isSearching = true
            $0.searchText = searchText
        }
    }
    
    func test_search_shouldDeliverEffect() {
        
        let pageSize = makePageSize()
        let sut = makeSUT(pageSize: pageSize)
        let nonEmptySearchTextState = makeState(searchText: "abc")
        let searchText = anyMessage()
        
        let effect = makePaginateEffect(
            operatorID: nil,
            pageSize: pageSize,
            searchText: searchText
        )
        
        assert(sut: sut, .search(searchText), on: nonEmptySearchTextState, effect: effect)
    }
    
    func test_search_shouldChangeNonEmptySearchTextStateWithEmptySearch() {
        
        let nonEmptySearchTextState = makeState(searchText: "abc")
        
        assertState(.search(""), on: nonEmptySearchTextState) {
            
            $0.isSearching = true
            $0.searchText = ""
        }
    }
    
    func test_search_shouldDeliverEffectWithEmptySearch() {
        
        let pageSize = makePageSize()
        let sut = makeSUT(pageSize: pageSize)
        let nonEmptySearchTextState = makeState(searchText: "abc")
        
        let effect = makePaginateEffect(
            operatorID: nil,
            pageSize: pageSize,
            searchText: ""
        )
        
        assert(sut: sut, .search(""), on: nonEmptySearchTextState, effect: effect)
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
