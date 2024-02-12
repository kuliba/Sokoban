//
//  SberQRConfirmPaymentStateFixedAmountReducerTests.swift
//
//
//  Created by Igor Malyarov on 06.12.2023.
//

import PaymentComponents
import SberQR
import XCTest

final class SberQRConfirmPaymentStateFixedAmountReducerTests: XCTestCase {
    
    func test_init_shouldNotCallProductSelect() {
        
        let (_, spy) = makeSUT()
        
        XCTAssertNoDiff(spy.callCount, 0)
    }
    
    func test_reduce_productSelect_shouldCallProductSelectReduce() {
        
        let current = ProductSelect.Product.test2
        let selectedProduct = ProductSelect.Product.test
        let event: ProductSelectReducer.Event = .select(selectedProduct)
        let (sut, spy) = makeSUT()
        
        _ = sut.reduce(
            makeFixedAmount(productSelect: .compact(current)),
            .productSelect(.select(selectedProduct))
        )
        
        XCTAssertNoDiff(spy.states, [.compact(current)])
        XCTAssertNoDiff(spy.events, [event])
    }
    
    func test_reduce_productSelect_shouldDeliverResultOfProductSelectReduce() {
        
        let current = ProductSelect.Product.test2
        let productSelect: ProductSelect = .expanded(.test2, [.test, .test2])
        let selectedProduct = ProductSelect.Product.test
        let event: ProductSelectReducer.Event = .select(selectedProduct)
        let (sut, _) = makeSUT(
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
        spy: ProductSelectSpy
    ) {
        let spy = ProductSelectSpy(stub: productSelectStub)
        let sut = SUT(
            productSelectReduce: spy.reduce
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        
        return (sut, spy)
    }
}
