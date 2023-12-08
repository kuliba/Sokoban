//
//  SberQRConfirmPaymentStateEditableAmountReducerTests.swift
//
//
//  Created by Igor Malyarov on 06.12.2023.
//

import XCTest

extension SberQRConfirmPaymentEvent {
    
    enum EditableAmountEvent {
        
        case editAmount(Decimal)
        case toggleProductSelect
        case pay
        case select(ProductSelect.Product.ID)
    }
}

final class SberQRConfirmPaymentStateEditableAmountReducer {
    
    typealias State = SberQRConfirmPaymentState.EditableAmount
    typealias Event = SberQRConfirmPaymentEvent.EditableAmountEvent
    
    typealias GetProducts = () -> [ProductSelect.Product]
    typealias Pay = () -> Void
    
    private let getProducts: GetProducts
    private let pay: Pay
    
    init(
        getProducts: @escaping GetProducts,
        pay: @escaping Pay
    ) {
        self.getProducts = getProducts
        self.pay = pay
    }
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> State {
        
        var newState = state
        
        switch event {
        case let .editAmount(amount):
            newState.bottom = .init(
                id: state.bottom.id,
                value: amount,
                title: state.bottom.title,
                validationRules: state.bottom.validationRules,
                button: state.bottom.button
            )
            
        case .pay:
            pay()
            
        case let .select(id):
            guard let product = getProducts().first(where: { $0.id == id })
            else { break }
            
            newState.productSelect = .compact(product)
            
        case .toggleProductSelect:
            switch state.productSelect {
            case let .compact(product):
                newState.productSelect = .expanded(product, getProducts())
                
            case let .expanded(selected, _):
                newState.productSelect = .compact(selected)
            }
        }
        
        return newState
    }
}

final class SberQRConfirmPaymentStateEditableAmountReducerTests: XCTestCase {
    
    func test_init_shouldNotCallPay() {
        
        let (_, spy) = makeSUT()
        
        XCTAssertNoDiff(spy.callCount, 0)
    }
    
    func test_reduce_editAmount_shouldNotCallPayOnEditAmount() {
        
        let (sut, spy) = makeSUT()
        
        _ = sut.reduce(makeEditableAmount(amount: 123.45), .editAmount(3_456.78))
        
        XCTAssertNoDiff(spy.callCount, 0)
    }
    
    func test_reduce_editAmount_shouldChangeStateOnEditAmount() {
        
        let amount: Decimal = 123.45
        let brandName = "Some Brand Name"
        let (sut, _) = makeSUT()
        let state = makeEditableAmount(
            brandName: brandName,
            amount: amount
        )
        
        let newState = sut.reduce(state, .editAmount(3_456.78))
        
        XCTAssertNoDiff(newState, makeEditableAmount(
            brandName: brandName,
            amount: 3_456.78
        ))
    }
    
    func test_reduce_pay_shouldCallPay() {
        
        let (sut, spy) = makeSUT()
        
        _ = sut.reduce(makeEditableAmount(), .pay)
        
        XCTAssertNoDiff(spy.callCount, 1)
    }
    
    func test_reduce_pay_shouldNotChangeState() {
        
        let (sut, _) = makeSUT()
        let state = makeEditableAmount()
        
        let newState = sut.reduce(state, .pay)
        
        XCTAssertNoDiff(newState, state)
    }
    
    func test_reduce_select_shouldNotCallPay() {
        
        let (sut, spy) = makeSUT()
        
        _ = sut.reduce(makeEditableAmount(), .select(.init("abcdef")))
        
        XCTAssertNoDiff(spy.callCount, 0)
    }
    
    func test_reduce_select_shouldNotChangeProductIfProductIsMissing() {
        
        let (sut, _) = makeSUT(products: [.test, .test2])
        let missingProduct: ProductSelect.Product = .missing
        let state = makeEditableAmount(
            brandName: "some brand"
        )
        XCTAssertNoDiff(state.productSelect, .compact(.test))
        
        let newState = sut.reduce(state, .select(missingProduct.id))
        
        XCTAssertNoDiff(newState, state)
    }
    
    func test_reduce_select_shouldChangeProductIfProductExists() {
        
        let (sut, _) = makeSUT(products: [.test, .test2])
        let existingProduct: ProductSelect.Product = .test2
        let state = makeEditableAmount(
            brandName: "some brand"
        )
        XCTAssertNoDiff(state.productSelect, .compact(.test))
        
        let newState = sut.reduce(state, .select(existingProduct.id))
        
        XCTAssertNoDiff(newState, makeEditableAmount(
            brandName: "some brand",
            productSelect: .compact(existingProduct)
        ))
    }
    
    func test_reduce_toggleProductSelect_shouldNotCallPay() {
        
        let (sut, spy) = makeSUT()
        
        _ = sut.reduce(makeEditableAmount(), .toggleProductSelect)
        
        XCTAssertNoDiff(spy.callCount, 0)
    }
    
    func test_reduce_toggleProductSelect_shouldExpandProductSelectWithSameProduct() {
        
        let products: [ProductSelect.Product] = [.test, .test2]
        let (sut, _) = makeSUT(products: products)
        let selectedProduct: ProductSelect.Product = .test2
        let state = makeEditableAmount(
            brandName: "some brand",
            productSelect: .compact(selectedProduct)
        )
        XCTAssertNoDiff(state.productSelect, .compact(selectedProduct))
        
        let newState = sut.reduce(state, .toggleProductSelect)
        
        XCTAssertNoDiff(newState, makeEditableAmount(
            brandName: "some brand",
            productSelect: .expanded(selectedProduct, products)
        ))
    }
    
    func test_reduce_toggleProductSelect_shouldCollapseProductSelectWithSameProduct() {
        
        let products: [ProductSelect.Product] = [.test, .test2]
        let (sut, _) = makeSUT(products: products)
        let selectedProduct: ProductSelect.Product = .test2
        let state = makeEditableAmount(
            brandName: "some brand",
            productSelect: .expanded(selectedProduct, products)
        )
        XCTAssertNoDiff(state.productSelect, .expanded(selectedProduct, products))
        
        let newState = sut.reduce(state, .toggleProductSelect)
        
        XCTAssertNoDiff(newState, makeEditableAmount(
            brandName: "some brand",
            productSelect: .compact(selectedProduct)
        ))
    }
    
    // MARK: - Helpers
    
    private typealias SUT = SberQRConfirmPaymentStateEditableAmountReducer
    
    private func makeSUT(
        products: [ProductSelect.Product] = [.test],
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spy: CallSpy
    ) {
        let spy = CallSpy()
        let sut = SUT(
            getProducts: { products },
            pay: spy.call
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        
        return (sut, spy)
    }
}
