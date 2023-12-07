//
//  SberQRConfirmPaymentStateReducerTests.swift
//
//
//  Created by Igor Malyarov on 06.12.2023.
//

import SberQR
import XCTest

final class SberQRConfirmPaymentStateReducerTests: XCTestCase {
    
    // MARK: - EditableAmount
    
    func test_init_shouldNotCallPay() {
        
        let (_, spy) = makeSUT()
        
        XCTAssertNoDiff(spy.callCount, 0)
    }
    
    func test_reduce_editableAmount_editAmount_shouldNotCallPayOnEditAmount() {
        
        let (sut, spy) = makeSUT()
        
        _ = sut.reduce(.editableAmount(makeEditableAmount(amount: 123.45)), .editable(.editAmount(3_456.78)))
        
        XCTAssertNoDiff(spy.callCount, 0)
    }
    
    func test_reduce_editableAmount_editAmount_shouldChangeStateOnEditAmount() {
        
        let amount: Decimal = 123.45
        let brandName = "Some Brand Name"
        let (sut, _) = makeSUT()
        let state = makeEditableAmount(
            brandName: brandName,
            amount: amount
        )
        
        let newState = sut.reduce(state, .editAmount(3_456.78))
        
        XCTAssertNoDiff(newState, .editableAmount(makeEditableAmount(
            brandName: brandName,
            amount: 3_456.78
        )))
    }
    
    func test_reduce_editableAmount_pay_shouldCallPayWithState() {
        
        let state = makeEditableAmount()
        let (sut, spy) = makeSUT()
        
        _ = sut.reduce(.editableAmount(state), .editable(.pay))
        
        XCTAssertNoDiff(spy.payloads, [.editableAmount(state)])
    }
    
    func test_reduce_editableAmount_pay_shouldNotChangeState() {
        
        let (sut, _) = makeSUT()
        let state = makeEditableAmount()
        
        let newState = sut.reduce(state, .pay)
        
        XCTAssertNoDiff(newState, .editableAmount(state))
    }
    
    func test_reduce_editableAmount_select_shouldNotCallPay() {
        
        let (sut, spy) = makeSUT()
        
        _ = sut.reduce(makeEditableAmount(), .select(.init(100000)))
        
        XCTAssertNoDiff(spy.callCount, 0)
    }
    
    func test_reduce_editableAmount_select_shouldNotChangeProductIfProductIsMissing() {
        
        let (sut, _) = makeSUT(products: [.test, .test2])
        let missingProduct: ProductSelect.Product = .missing
        let state = makeEditableAmount(
            brandName: "some brand"
        )
        XCTAssertNoDiff(state.productSelect, .compact(.test))
        
        let newState = sut.reduce(state, .select(missingProduct.id))
        
        XCTAssertNoDiff(newState, .editableAmount(state))
    }
    
    func test_reduce_editableAmount_select_shouldChangeProductIfProductExists() {
        
        let (sut, _) = makeSUT(products: [.test, .test2])
        let existingProduct: ProductSelect.Product = .test2
        let state = makeEditableAmount(
            brandName: "some brand"
        )
        XCTAssertNoDiff(state.productSelect, .compact(.test))
        
        let newState = sut.reduce(state, .select(existingProduct.id))
        
        XCTAssertNoDiff(newState, .editableAmount(makeEditableAmount(
            brandName: "some brand",
            productSelect: .compact(existingProduct)
        )))
    }
    
    func test_reduce_editableAmount_toggleProductSelect_shouldNotCallPay() {
        
        let (sut, spy) = makeSUT()
        
        _ = sut.reduce(makeEditableAmount(), .toggleProductSelect)
        
        XCTAssertNoDiff(spy.callCount, 0)
    }
    
    func test_reduce_editableAmount_toggleProductSelect_shouldExpandProductSelectWithSameProduct() {
        
        let products: [ProductSelect.Product] = [.test, .test2]
        let (sut, _) = makeSUT(products: products)
        let selectedProduct: ProductSelect.Product = .test2
        let state = makeEditableAmount(
            brandName: "some brand",
            productSelect: .compact(selectedProduct)
        )
        XCTAssertNoDiff(state.productSelect, .compact(selectedProduct))
        
        let newState = sut.reduce(state, .toggleProductSelect)
        
        XCTAssertNoDiff(newState, .editableAmount(makeEditableAmount(
            brandName: "some brand",
            productSelect: .expanded(selectedProduct, products)
        )))
    }
    
    func test_reduce_editableAmount_toggleProductSelect_shouldCollapseProductSelectWithSameProduct() {
        
        let products: [ProductSelect.Product] = [.test, .test2]
        let (sut, _) = makeSUT(products: products)
        let selectedProduct: ProductSelect.Product = .test2
        let state = makeEditableAmount(
            brandName: "some brand",
            productSelect: .expanded(selectedProduct, products)
        )
        XCTAssertNoDiff(state.productSelect, .expanded(selectedProduct, products))
        
        let newState = sut.reduce(state, .toggleProductSelect)
        
        XCTAssertNoDiff(newState, .editableAmount(makeEditableAmount(
            brandName: "some brand",
            productSelect: .compact(selectedProduct)
        )))
    }
    
    // MARK: - FixedAmount
    
    func test_reduce_fixedAmount_pay_shouldCallPayWithState() {
        
        let state = makeFixedAmount()
        let (sut, spy) = makeSUT()
        
        _ = sut.reduce(.fixedAmount(state), .fixed(.pay))
        
        XCTAssertNoDiff(spy.payloads, [.fixedAmount(state)])
    }
    
    func test_reduce_fixedAmount_pay_shouldNotChangeState() {
        
        let (sut, _) = makeSUT()
        let state = makeFixedAmount()
        
        let newState = sut.reduce(state, .pay)
        
        XCTAssertNoDiff(newState, .fixedAmount(state))
    }
    
    func test_reduce_fixedAmount_select_shouldNotCallPay() {
        
        let (sut, spy) = makeSUT()
        
        _ = sut.reduce(makeFixedAmount(), .select(.init(100000)))
        
        XCTAssertNoDiff(spy.callCount, 0)
    }
    
    func test_reduce_fixedAmount_select_shouldNotChangeProductIfProductIsMissing() {
        
        let (sut, _) = makeSUT(products: [.test, .test2])
        let missingProduct: ProductSelect.Product = .missing
        let state = makeFixedAmount(
            brandName: "some brand"
        )
        XCTAssertNoDiff(state.productSelect, .compact(.test))
        
        let newState = sut.reduce(state, .select(missingProduct.id))
        
        XCTAssertNoDiff(newState, .fixedAmount(state))
    }
    
    func test_reduce_fixedAmount_select_shouldChangeProductIfProductExists() {
        
        let (sut, _) = makeSUT(products: [.test, .test2])
        let existingProduct: ProductSelect.Product = .test2
        let state = makeFixedAmount(
            brandName: "some brand"
        )
        XCTAssertNoDiff(state.productSelect, .compact(.test))
        
        let newState = sut.reduce(state, .select(existingProduct.id))
        
        XCTAssertNoDiff(newState, .fixedAmount(makeFixedAmount(
            brandName: "some brand",
            productSelect: .compact(existingProduct)
        )))
    }
    
    func test_reduce_fixedAmount_toggleProductSelect_shouldNotCallPay() {
        
        let (sut, spy) = makeSUT()
        
        _ = sut.reduce(makeFixedAmount(), .toggleProductSelect)
        
        XCTAssertNoDiff(spy.callCount, 0)
    }
    
    func test_reduce_fixedAmount_toggleProductSelect_shouldExpandProductSelectWithSameProduct() {
        
        let products: [ProductSelect.Product] = [.test, .test2]
        let (sut, _) = makeSUT(products: products)
        let selectedProduct: ProductSelect.Product = .test2
        let state = makeFixedAmount(
            brandName: "some brand",
            productSelect: .compact(selectedProduct)
        )
        XCTAssertNoDiff(state.productSelect, .compact(selectedProduct))
        
        let newState = sut.reduce(state, .toggleProductSelect)
        
        XCTAssertNoDiff(newState, .fixedAmount(makeFixedAmount(
            brandName: "some brand",
            productSelect: .expanded(selectedProduct, products)
        )))
    }
    
    func test_reduce_fixedAmount_toggleProductSelect_shouldCollapseProductSelectWithSameProduct() {
        
        let products: [ProductSelect.Product] = [.test, .test2]
        let (sut, _) = makeSUT(products: products)
        let selectedProduct: ProductSelect.Product = .test2
        let state = makeFixedAmount(
            brandName: "some brand",
            productSelect: .expanded(selectedProduct, products)
        )
        XCTAssertNoDiff(state.productSelect, .expanded(selectedProduct, products))
        
        let newState = sut.reduce(state, .toggleProductSelect)
        
        XCTAssertNoDiff(newState, .fixedAmount(makeFixedAmount(
            brandName: "some brand",
            productSelect: .compact(selectedProduct)
        )))
    }
    
    // MARK: - Helpers
    
    typealias SUT = SberQRConfirmPaymentStateReducer
    private typealias Spy = CallSpy<SUT.State>

    private func makeSUT(
        products: [ProductSelect.Product] = [.test],
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spy: Spy
    ) {
        let spy = Spy()
        let sut = SUT(
            getProducts: { products },
            pay: spy.call
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        
        return (sut, spy)
    }
}

private extension SberQRConfirmPaymentStateReducer {
    
    func reduce(
        _ editableAmount: SberQRConfirmPaymentState.EditableAmount,
        _ editableEvent: SberQRConfirmPaymentEvent.EditableAmountEvent
    ) -> State {
        
        reduce(
            .editableAmount(editableAmount),
            .editable(editableEvent)
        )
    }
    
    func reduce(
        _ fixedAmount: SberQRConfirmPaymentState.FixedAmount,
        _ fixedEvent: SberQRConfirmPaymentEvent.FixedAmountEvent
    ) -> State {
        
        reduce(
            .fixedAmount(fixedAmount),
            .fixed(fixedEvent)
        )
    }
}
