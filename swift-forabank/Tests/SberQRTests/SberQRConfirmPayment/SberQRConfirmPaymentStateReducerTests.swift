//
//  SberQRConfirmPaymentStateReducerTests.swift
//
//
//  Created by Igor Malyarov on 06.12.2023.
//

import PaymentComponents
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
    
    func test_reduce_editableAmount_editAmount_shouldChangeStateOnEditAmount() throws {
        
        let amount: Decimal = 11.11
        let brandName = "Some Brand Name"
        let (sut, _) = makeSUT()
        let state = makeEditableAmount(
            brandName: brandName,
            amount: 123.45
        )
        
        let newState = sut._reduce(state, .editAmount(amount))
        
        XCTAssertNoDiff(newState.confirm, .editableAmount(makeEditableAmount(
            brandName: brandName,
            amount: amount,
            isEnabled: true
        )))
        
        let balance = try XCTUnwrap(newState.productSelect.selected?.balance)
        XCTAssertGreaterThan(balance, amount)
        XCTAssertGreaterThan(balance, amount)
    }
    
    func test_reduce_editableAmount_editAmount_shouldChangeStateToDisabledOnEditAmount() throws {
        
        let amount: Decimal = 3_456.78
        let brandName = "Some Brand Name"
        let (sut, _) = makeSUT()
        let state = makeEditableAmount(
            brandName: brandName,
            amount: 123.45
        )
        
        let newState = sut._reduce(state, .editAmount(amount))
        
        XCTAssertNoDiff(newState.confirm, .editableAmount(makeEditableAmount(
            brandName: brandName,
            amount: amount,
            isEnabled: false
        )))

        let balance = try XCTUnwrap(newState.productSelect.selected?.balance)
        XCTAssertGreaterThan(amount, balance)
    }
    
    func test_reduce_editableAmount_pay_shouldCallPayWithState() {
        
        let state = makeEditableAmount()
        let (sut, spy) = makeSUT()
        
        _ = sut.reduce(.editableAmount(state), .pay)
        
        XCTAssertNoDiff(spy.payloads.map(\.confirm), [.editableAmount(state)])
    }
    
    func test_reduce_editableAmount_pay_shouldChangeStatusToInflight() {
        
        let state: SUT.State = .init(
            confirm: .editableAmount(makeEditableAmount())
        )
        let (sut, _) = makeSUT()
        
        let newState = sut.reduce(state, .pay)
        
        XCTAssertNoDiff(newState.confirm, state.confirm)
        XCTAssertNoDiff(newState.isInflight, true)
    }
    
    func test_reduce_editableAmount_pay_shouldNotCallPayWithState_inflight() {
        
        let state: SUT.State = .init(
            confirm: .editableAmount(makeEditableAmount()),
            isInflight: true
        )
        let (sut, spy) = makeSUT()
        
        _ = sut.reduce(state, .pay)
        
        XCTAssertNoDiff(spy.payloads.map(\.confirm), [])
    }
    
    func test_reduce_editableAmount_pay_shouldNotChangeState_inflight() {
        
        let state: SUT.State = .init(
            confirm: .editableAmount(makeEditableAmount()),
            isInflight: true
        )
        let (sut, _) = makeSUT()
        
        let newState = sut.reduce(state, .pay)
        
        XCTAssertNoDiff(newState, state)
    }
    
    func test_reduce_editableAmount_select_shouldNotCallPay() {
        
        let (sut, spy) = makeSUT()
        
        _ = sut._reduce(makeEditableAmount(), .productSelect(.select(.test)))
        
        XCTAssertNoDiff(spy.callCount, 0)
    }
    
    func test_reduce_editableAmount_select_shouldNotChangeProductIfProductIsMissing() {
        
        let (sut, _) = makeSUT(products: [.test, .test2])
        let missingProduct: ProductSelect.Product = .missing
        let state = makeEditableAmount(
            brandName: "some brand"
        )
        XCTAssertNoDiff(state.productSelect, .compact(.test))
        
        let newState = sut._reduce(state, .productSelect(.select(missingProduct)))
        
        XCTAssertNoDiff(newState.confirm, .editableAmount(state))
    }
    
    func test_reduce_editableAmount_select_shouldChangeProductIfProductExists() {
        
        let (sut, _) = makeSUT(products: [.test, .test2])
        let existingProduct: ProductSelect.Product = .test2
        let state = makeEditableAmount(
            brandName: "some brand"
        )
        XCTAssertNoDiff(state.productSelect, .compact(.test))
        
        let newState = sut._reduce(state, .productSelect(.select(existingProduct)))
        
        XCTAssertNoDiff(newState.confirm, .editableAmount(makeEditableAmount(
            brandName: "some brand",
            productSelect: .compact(existingProduct)
        )))
    }
    
    func test_reduce_editableAmount_toggleProductSelect_shouldNotCallPay() {
        
        let (sut, spy) = makeSUT()
        
        _ = sut._reduce(makeEditableAmount(), .productSelect(.toggleProductSelect))
        
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
        
        let newState = sut._reduce(state, .productSelect(.toggleProductSelect))
        
        XCTAssertNoDiff(newState.confirm, .editableAmount(makeEditableAmount(
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
        
        let newState = sut._reduce(state, .productSelect(.toggleProductSelect))
        
        XCTAssertNoDiff(newState.confirm, .editableAmount(makeEditableAmount(
            brandName: "some brand",
            productSelect: .compact(selectedProduct)
        )))
    }
    
    //    // MARK: - FixedAmount
    
    func test_reduce_fixedAmount_pay_shouldCallPayWithState() {
        
        let state = makeFixedAmount()
        let (sut, spy) = makeSUT()
        
        _ = sut.reduce(.fixedAmount(state), .pay)
        
        XCTAssertNoDiff(spy.payloads.map(\.confirm), [.fixedAmount(state)])
    }
    
    func test_reduce_fixedAmount_pay_shouldChangeStateToInflight() {
        
        let state: SUT.State = .init(
            confirm: .fixedAmount(makeFixedAmount())
        )
        let (sut, _) = makeSUT()
        
        let newState = sut.reduce(state, .pay)
        
        XCTAssertNoDiff(newState.confirm, state.confirm)
        XCTAssertNoDiff(newState.isInflight, true)
    }
    
    func test_reduce_fixedAmount_pay_shouldNotCallPayWithState_inflight() {
        
        let state: SUT.State = .init(
            confirm: .fixedAmount(makeFixedAmount()),
            isInflight: true
        )
        let (sut, spy) = makeSUT()
        
        _ = sut.reduce(state, .pay)
        
        XCTAssertNoDiff(spy.payloads.map(\.confirm), [])
    }
    
    func test_reduce_fixedAmount_pay_shouldNotChangeState_inflight() {
        
        let state: SUT.State = .init(
            confirm: .fixedAmount(makeFixedAmount()),
            isInflight: true
        )
        let (sut, _) = makeSUT()
        
        let newState = sut.reduce(state, .pay)
        
        XCTAssertNoDiff(newState, state)
    }
    
    func test_reduce_fixedAmount_select_shouldNotCallPay() {
        
        let (sut, spy) = makeSUT()
        
        _ = sut._reduce(makeFixedAmount(), .productSelect(.select(.test)))
        
        XCTAssertNoDiff(spy.callCount, 0)
    }
    
    func test_reduce_fixedAmount_select_shouldNotChangeProductIfProductIsMissing() {
        
        let (sut, _) = makeSUT(products: [.test, .test2])
        let missingProduct: ProductSelect.Product = .missing
        let state = makeFixedAmount(
            brandName: "some brand"
        )
        XCTAssertNoDiff(state.productSelect, .compact(.test))
        
        let newState = sut._reduce(state, .productSelect(.select(missingProduct)))
        
        XCTAssertNoDiff(newState.confirm, .fixedAmount(state))
    }
    
    func test_reduce_fixedAmount_select_shouldChangeProductIfProductExists() {
        
        let (sut, _) = makeSUT(products: [.test, .test2])
        let existingProduct: ProductSelect.Product = .test2
        let state = makeFixedAmount(
            brandName: "some brand"
        )
        XCTAssertNoDiff(state.productSelect, .compact(.test))
        
        let newState = sut._reduce(state, .productSelect(.select(existingProduct)))
        
        XCTAssertNoDiff(newState.confirm, .fixedAmount(makeFixedAmount(
            brandName: "some brand",
            productSelect: .compact(existingProduct)
        )))
    }
    
    func test_reduce_fixedAmount_toggleProductSelect_shouldNotCallPay() {
        
        let (sut, spy) = makeSUT()
        
        _ = sut._reduce(makeFixedAmount(), .productSelect(.toggleProductSelect))
        
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
        
        let newState = sut._reduce(state, .productSelect(.toggleProductSelect))
        
        XCTAssertNoDiff(newState.confirm, .fixedAmount(makeFixedAmount(
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
        
        let newState = sut._reduce(state, .productSelect(.toggleProductSelect))
        
        XCTAssertNoDiff(newState.confirm, .fixedAmount(makeFixedAmount(
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
        let sut = SUT.default(
            getProducts: { products },
            pay: spy.call
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        
        return (sut, spy)
    }
}

private extension SberQRConfirmPaymentStateReducer {
    
    func _reduce(
        _ editableAmount: EditableAmount<GetSberQRDataResponse.Parameter.Info>,
        _ editableEvent: SberQRConfirmPaymentEvent.EditableAmount
    ) -> State {
        
        reduce(
            .editableAmount(editableAmount),
            .editable(editableEvent)
        )
    }
    
    func _reduce(
        _ fixedAmount: FixedAmount<GetSberQRDataResponse.Parameter.Info>,
        _ fixedEvent: SberQRConfirmPaymentEvent.FixedAmount
    ) -> State {
        
        reduce(
            .fixedAmount(fixedAmount),
            .fixed(fixedEvent)
        )
    }
}

// MARK: - DSL

private extension SberQRConfirmPaymentStateReducer {
    
    func reduce(
        _ confirm: SberQRConfirmPaymentStateOf<GetSberQRDataResponse.Parameter.Info>,
        _ event: Event
    ) -> State {
        
        reduce(.init(confirm: confirm), event)
    }
}
