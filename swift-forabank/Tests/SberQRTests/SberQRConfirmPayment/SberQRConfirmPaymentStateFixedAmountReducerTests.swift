//
//  SberQRConfirmPaymentStateFixedAmountReducerTests.swift
//  
//
//  Created by Igor Malyarov on 06.12.2023.
//

import SberQR
import XCTest

final class SberQRConfirmPaymentStateFixedAmountReducerTests: XCTestCase {
    
    func test_init_shouldNotCallPay() {
        
        let (_, spy, _) = makeSUT()
        
        XCTAssertNoDiff(spy.callCount, 0)
    }
    
    func test_init_shouldNotCallProductSelect() {
        
        let (_,_, productSelectSpy) = makeSUT()
        
        XCTAssertNoDiff(productSelectSpy.callCount, 0)
    }
    
    func test_reduce_pay_shouldCallPay() {
        
        let state = makeFixedAmount()
        let (sut, spy, _) = makeSUT()
        
        _ = sut.reduce(state, .pay)
        
        XCTAssertNoDiff(spy.payloads, [state])
    }
    
    func test_reduce_pay_shouldNotChangeState() {
        
        let (sut, _, _) = makeSUT()
        let state = makeFixedAmount()
        
        let newState = sut.reduce(state, .pay)
        
        XCTAssertNoDiff(newState, state)
    }
    
    func test_reduce_select_shouldNotCallPay() {
        
        let (sut, spy, _) = makeSUT()
        
        _ = sut.reduce(makeFixedAmount(), .productSelect(.select(.init(100000))))
        
        XCTAssertNoDiff(spy.callCount, 0)
    }
    
    func test_reduce_productSelect_shouldCallProductSelectReduce() {
        
        let current = ProductSelect.Product.test2
        let selectedProduct = ProductSelect.Product.test
        let event: ProductSelectReducer.Event = .select(selectedProduct.id)
        let (sut, _, productSelectSpy) = makeSUT()
        
        _ = sut.reduce(
            makeFixedAmount(productSelect: .compact(current)),
            .productSelect(.select(selectedProduct.id))
        )
        
        XCTAssertNoDiff(productSelectSpy.states, [.compact(current)])
        XCTAssertNoDiff(productSelectSpy.events, [event])
    }
    
    func test_reduce_productSelect_shouldDeliverResultOfProductSelectReduce() {
        
        let current = ProductSelect.Product.test2
        let productSelect: ProductSelect = .expanded(.test2, [.test, .test2])
        let selectedProduct = ProductSelect.Product.test
        let event: ProductSelectReducer.Event = .select(selectedProduct.id)
        let (sut, _,_) = makeSUT(
            productSelectStub: productSelect
        )
        
        let newState = sut.reduce(
            makeFixedAmount(productSelect: .compact(current)),
            .productSelect(event)
        )
        
        XCTAssertNoDiff(newState.productSelect, productSelect)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = SberQRConfirmPaymentStateFixedAmountReducer
    private typealias Spy = CallSpy<SUT.State>
    private typealias ProductSelectSpy = ReducerSpy<ProductSelectReducer.State, ProductSelectReducer.Event>

    private func makeSUT(
        productSelectStub: ProductSelectReducer.State = .compact(.test2),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spy: Spy,
        productSelectSpy: ProductSelectSpy
    ) {
        let spy = Spy()
        let productSelectSpy = ProductSelectSpy(stub: productSelectStub)
        let sut = SUT(
            productSelectReduce: productSelectSpy.reduce,
            pay: spy.call
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        trackForMemoryLeaks(productSelectSpy, file: file, line: line)
        
        return (sut, spy, productSelectSpy)
    }
}
