//
//  SberQRConfirmPaymentStateReducerTests.swift
//
//
//  Created by Igor Malyarov on 06.12.2023.
//

import XCTest

enum SberQRConfirmPaymentEvent {
    
    case editable(EditableAmountEvent)
    case fixed(FixedAmountEvent)
}

final class SberQRConfirmPaymentStateReducer {
    
    typealias State = SberQRConfirmPaymentState
    typealias Event = SberQRConfirmPaymentEvent
    
    typealias EditableState = State.EditableAmount
    typealias EditableEvent = Event.EditableAmountEvent
    
    typealias FixedState = State.FixedAmount
    typealias FixedEvent = Event.FixedAmountEvent
    
    typealias EditableReduce = (EditableState, EditableEvent) -> EditableState
    typealias FixedReduce = (FixedState, FixedEvent) -> FixedState
    
    let editableReduce: EditableReduce
    let fixedReduce: FixedReduce
    
    init(
        editableReduce: @escaping EditableReduce,
        fixedReduce: @escaping FixedReduce
    ) {
        self.editableReduce = editableReduce
        self.fixedReduce = fixedReduce
    }
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> State {
        
        var newState = state
        
        switch (state, event) {
        case let (.editableAmount(state), .editable(event)):
            newState = .editableAmount(editableReduce(state, event))
            
        case let (.fixedAmount(state), .fixed(event)):
            newState = .fixedAmount(fixedReduce(state, event))
            
        default:
            break
        }
        
        return newState
    }
}

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
    
    func test_reduce_editableAmount_pay_shouldCallPay() {
        
        let (sut, spy) = makeSUT()
        
        _ = sut.reduce(makeEditableAmount(), .pay)
        
        XCTAssertNoDiff(spy.callCount, 1)
    }
    
    func test_reduce_editableAmount_pay_shouldNotChangeState() {
        
        let (sut, _) = makeSUT()
        let state = makeEditableAmount()
        
        let newState = sut.reduce(state, .pay)
        
        XCTAssertNoDiff(newState, .editableAmount(state))
    }
    
    func test_reduce_editableAmount_select_shouldNotCallPay() {
        
        let (sut, spy) = makeSUT()
        
        _ = sut.reduce(makeEditableAmount(), .select(.init("abcdef")))
        
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
    
    func test_reduce_fixedAmount_pay_shouldCallPay() {
        
        let (sut, spy) = makeSUT()
        
        _ = sut.reduce(makeFixedAmount(), .pay)
        
        XCTAssertNoDiff(spy.callCount, 1)
    }
    
    func test_reduce_fixedAmount_pay_shouldNotChangeState() {
        
        let (sut, _) = makeSUT()
        let state = makeFixedAmount()
        
        let newState = sut.reduce(state, .pay)
        
        XCTAssertNoDiff(newState, .fixedAmount(state))
    }
    
    func test_reduce_fixedAmount_select_shouldNotCallPay() {
        
        let (sut, spy) = makeSUT()
        
        _ = sut.reduce(makeFixedAmount(), .select(.init("abcdef")))
        
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
    
    private func makeSUT(
        products: [ProductSelect.Product] = [.test],
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spy: CallSpy
    ) {
        let spy = CallSpy()
        let editable = SberQRConfirmPaymentStateEditableAmountReducer(
            getProducts: { products },
            pay: spy.call
        )
        let fixed = SberQRConfirmPaymentStateFixedAmountReducer(
            getProducts: { products },
            pay: spy.call
        )
        let sut = SUT(
            editableReduce: editable.reduce(_:_:),
            fixedReduce: fixed.reduce(_:_:)
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
