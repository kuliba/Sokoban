//
//  SberQRConfirmPaymentStateEditableAmountReducerTests.swift
//
//
//  Created by Igor Malyarov on 06.12.2023.
//

import PaymentComponents
import SberQR
import XCTest

final class SberQRConfirmPaymentStateEditableAmountReducerTests: XCTestCase {
    
    func test_init_shouldNotCallProductSelect() {
        
        let (_,spy) = makeSUT()
        
        XCTAssertNoDiff(spy.callCount, 0)
    }
    
    func test_reduce_editAmount_shouldChangeAmountOnEditAmount() throws {
        
        let amount: Decimal = 12.66
        let brandName = "Some Brand Name"
        let (sut, _) = makeSUT()
        let state = makeEditableAmount(
            brandName: brandName,
            amount: 0
        )
        
        let newState = sut.reduce(state, .editAmount(amount))
        
        XCTAssertNoDiff(newState, makeEditableAmount(
            brandName: brandName,
            amount: amount,
            isEnabled: true
        ))
        
        let balance = try XCTUnwrap(newState.productSelect.selected?.balance)
        XCTAssertGreaterThan(balance, amount)
    }
    
    func test_reduce_editAmount_shouldChangeAmountStateToDisabledOnEditAmount() throws {
        
        let amount: Decimal = 123.45
        let brandName = "Some Brand Name"
        let (sut, _) = makeSUT()
        let state = makeEditableAmount(
            brandName: brandName,
            amount: 0
        )
        
        let newState = sut.reduce(state, .editAmount(amount))
        
        XCTAssertNoDiff(newState, makeEditableAmount(
            brandName: brandName,
            amount: amount,
            isEnabled: false
        ))
        let balance = try XCTUnwrap(newState.productSelect.selected?.balance)
        XCTAssertGreaterThan(amount, balance)
    }
    
    func test_reduce_editAmount_shouldChangeStateOnEditAmount() {
        
        let brandName = "Some Brand Name"
        let (sut, _) = makeSUT()
        let state = makeEditableAmount(
            brandName: brandName,
            isEnabled: false
        )
        
        let newState = sut.reduce(state, .editAmount(4.20))
        
        XCTAssertNoDiff(newState, makeEditableAmount(
            brandName: brandName,
            amount: 4.20,
            isEnabled: true
        ))
    }
    
    func test_reduce_editAmount_shouldChangeStateToDisabledOnAmountGreaterThanProductBalance() throws {
        
        let amount: Decimal = 123_457
        let brandName = "Some Brand Name"
        let (sut, _) = makeSUT(
            productSelectStub: .compact(.accountPreview)
        )
        let state = makeEditableAmount(
            brandName: brandName,
            amount: 0,
            isEnabled: false
        )
        
        let newState = sut.reduce(state, .editAmount(amount))
        
        XCTAssertNoDiff(newState, makeEditableAmount(
            brandName: brandName,
            amount: amount,
            isEnabled: false
        ))
        let balance = try XCTUnwrap(newState.productSelect.selected?.balance)
        XCTAssertGreaterThan(amount, balance)
    }
    
    func test_reduce_productSelect_shouldCallProductSelectReduce() {
        
        let current = ProductSelect.Product.test2
        let selectedProduct = ProductSelect.Product.test
        let event: ProductSelectReducer.Event = .select(selectedProduct)
        let (sut, spy) = makeSUT()
        
        _ = sut.reduce(
            makeEditableAmount(productSelect: .compact(current)),
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
            makeEditableAmount(productSelect: .compact(current)),
            .productSelect(event)
        )
        
        XCTAssertNoDiff(newState.productSelect, productSelect)
    }
    
    func test_reduce_productSelect_shouldSetAmountToDisabledOnAmountGreaterThanBalanceOfSelectedProduct() throws {
        
        let amount: Decimal = 4.22
        let current = ProductSelect.Product.test2
        let selectedProduct = ProductSelect.Product.test
        let event: ProductSelectReducer.Event = .select(selectedProduct)
        let (sut, _) = makeSUT()
        
        let newState = sut.reduce(
            makeEditableAmount(
                productSelect: .compact(current),
                amount: amount
            ),
            .productSelect(event)
        )
        
        XCTAssertFalse(newState.amount.button.isEnabled)
        let balance = try XCTUnwrap(newState.productSelect.selected?.balance)
        XCTAssertGreaterThan(amount, balance)
    }
    
    func test_reduce_productSelect_shouldSetAmountToEnabledOnAmountLesserThanBalanceOfSelectedProduct() throws {
        
        let amount: Decimal = 4.21
        let current = ProductSelect.Product.test2
        let selectedProduct = ProductSelect.Product.test
        let event: ProductSelectReducer.Event = .select(selectedProduct)
        let (sut, _) = makeSUT()
        
        let newState = sut.reduce(
            makeEditableAmount(
                productSelect: .compact(current),
                amount: amount
            ),
            .productSelect(event)
        )
        
        XCTAssert(newState.amount.button.isEnabled)
        let balance = try XCTUnwrap(newState.productSelect.selected?.balance)
        XCTAssertGreaterThanOrEqual(balance, amount)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = SberQRConfirmPaymentStateEditableAmountReducer
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
