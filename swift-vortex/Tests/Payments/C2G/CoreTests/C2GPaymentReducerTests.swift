//
//  C2GPaymentReducerTests.swift
//
//
//  Created by Igor Malyarov on 16.02.2025.
//

import C2GCore
import PaymentComponents
import XCTest

final class C2GPaymentReducerTests: C2GPaymentTests {
    
    func test_termsToggle_shouldNotChangeState_onMissingTermsCheck() {
        
        let state = makeState(termsCheck: nil)
        let sut = makeSUT().sut
        
        assert(sut: sut, state, event: .termsToggle)
    }

    func test_termsToggle_shouldSetTermsCheckToTrue_onTermsCheckFalse() {
        
        let state = makeState(termsCheck: false)
        let sut = makeSUT().sut
        
        assert(sut: sut, state, event: .termsToggle) {
            
            $0.termsCheck = true
        }
    }
    
    func test_termsToggle_shouldSetTermsCheckToFalse_onTermsCheckTrue() {
        
        let state = makeState(termsCheck: true)
        let sut = makeSUT().sut
        
        assert(sut: sut, state, event: .termsToggle) {
            
            $0.termsCheck = false
        }
    }
    
    func test_productSelect_toggleProductSelect_shouldCallProductSelectReduce() {
        
        let state = makeState()
        let (sut, spy) = makeSUT()
        
        _ = sut.reduce(state, .productSelect(.toggleProductSelect))
        
        XCTAssertNoDiff(spy.payloads.map(\.0), [state.productSelect])
        XCTAssertNoDiff(spy.payloads.map(\.1), [.toggleProductSelect])
    }
    
    func test_productSelect_select_shouldCallProductSelectReduce() {
        
        let state = makeState()
        let select = makeProduct()
        let (sut, spy) = makeSUT()
        
        _ = sut.reduce(state, .productSelect(.select(select)))
        
        XCTAssertNoDiff(spy.payloads.map(\.0), [state.productSelect])
        XCTAssertNoDiff(spy.payloads.map(\.1), [.select(select)])
    }
    
    func test_productSelect_toggleProductSelect_shouldDeliverProductSelectReduced() {
        
        let productSelect = makeProductSelect(
            selected: makeProduct(),
            products: [makeProduct()]
        )
        let state = makeState()
        let (sut, _) = makeSUT(productSelect: productSelect)
        
        assert(sut: sut, state, event: .productSelect(.toggleProductSelect)) {
            
            $0.productSelect = productSelect
        }
    }
    
    func test_productSelect_select_shouldDeliverProductSelectReduced() {
        
        let productSelect = makeProductSelect(
            selected: makeProduct(),
            products: [makeProduct()]
        )
        let state = makeState()
        let (sut, _) = makeSUT(productSelect: productSelect)
        
        assert(sut: sut, state, event: .productSelect(.select(makeProduct()))) {
            
            $0.productSelect = productSelect
        }
    }
    
    // MARK: - Helpers
    
    private typealias SUT = C2GPaymentReducer<URL>
    private typealias Event = SUT.Event
    private typealias ProductSelectReduceSpy = CallSpy<(ProductSelect, ProductSelectEvent), ProductSelect>
    
    private func makeSUT(
        productSelect: ProductSelect? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spy: ProductSelectReduceSpy
    ) {
        let spy = ProductSelectReduceSpy(stubs: [productSelect ?? makeProductSelect()])
        let sut = SUT(productSelectReduce: spy.call)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        
        return (sut, spy)
    }
    
    @discardableResult
    private func assert(
        sut: SUT,
        _ state: SUT.State,
        event: SUT.Event,
        updateStateToExpected: ((inout SUT.State) -> Void)? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT.State {
        
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
}
