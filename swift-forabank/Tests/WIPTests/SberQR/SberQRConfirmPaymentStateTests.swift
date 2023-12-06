//
//  SberQRConfirmPaymentStateTests.swift
//
//
//  Created by Igor Malyarov on 06.12.2023.
//

import XCTest

final class SberQRConfirmPaymentStateTests: GetSberQRDataResponseTests {
    
    // MARK: - init
    
    func test_init_fixedAmount_fromResponseWithFixedAmount() throws {
        
        let response = responseWithFixedAmount()
        
        let state = try SberQRConfirmPaymentState(response)
        
        XCTAssertNoDiff(state, .fixedAmount(.init(
            header: .payQR,
            productSelect: .debitAccount,
            brandName: .brandName(value: "сббол енот_QR"),
            amount: .amount,
            recipientBank: .recipientBank,
            bottom: .buttonPay
        )))
    }
    
    func test_init_editableAmount_fromResponseWithEditableAmount() throws {
        
        let response = responseWithEditableAmount()
        
        let state = try SberQRConfirmPaymentState(response)
        
        XCTAssertNoDiff(state, .editableAmount(.init(
            header: .payQR,
            productSelect: .debitAccount,
            brandName: .brandName(value: "Тест Макусов. Кутуза_QR"),
            recipientBank: .recipientBank,
            currency: .rub,
            bottom: .paymentAmount
        )))
    }
    
    // MARK: - FixedAmountReducer
    
    func test_fixedAmountReducer_init_shouldNotCallPay() {
        
        var payCallCount = 0
        _ = FixedAmountReducer { payCallCount += 1 }

        XCTAssertNoDiff(payCallCount, 0)
    }
    
    func test_fixedAmountReducer_reduce_shouldCallPayOnPay() {
        
        var payCallCount = 0
        let reducer = FixedAmountReducer { payCallCount += 1 }
        
        _ = reducer.reduce(makeFixedAmount(), .pay)
        
        XCTAssertNoDiff(payCallCount, 1)
    }
    
    func test_fixedAmountReducer_reduce_shouldNotChangeStateOnPay() {
        
        let reducer = FixedAmountReducer {}
        let state = makeFixedAmount()
        
        let newState = reducer.reduce(state, .pay)
        
        XCTAssertNoDiff(newState, state)
    }
    
    // MARK: - AmountReducer
    
    func test_editableAmountReducer_init_shouldNotCallPay() {
        
        var payCallCount = 0
        _ = EditableAmountReducer { payCallCount += 1 }
        
        XCTAssertNoDiff(payCallCount, 0)
    }
    
    func test_editableAmountReducer_reduce_shouldCallPayOnPay() {
        
        var payCallCount = 0
        let reducer = EditableAmountReducer { payCallCount += 1 }
        
        _ = reducer.reduce(makeEditableAmount(), .pay)
        
        XCTAssertNoDiff(payCallCount, 1)
    }
    
    func test_editableAmountReducer_reduce_shouldNotChangeStateOnPay() {
        
        let reducer = EditableAmountReducer {}
        let state = makeEditableAmount()
        
        let newState = reducer.reduce(state, .pay)
        
        XCTAssertNoDiff(newState, state)
    }
    
    // MARK: - Helpers
    
    private typealias FixedAmountReducer = SberQRConfirmPaymentStateFixedAmountReducer
    private typealias EditableAmountReducer = SberQRConfirmPaymentStateEditableAmountReducer
    
    private func makeFixedAmount(
        brandName: String = UUID().uuidString
    ) -> SberQRConfirmPaymentState.FixedAmount {
        
        .init(
            header: .payQR,
              productSelect: .debitAccount,
              brandName: .brandName(value: brandName),
              amount: .amount,
              recipientBank: .recipientBank,
              bottom: .buttonPay
        )
    }
    
    private func makeEditableAmount(
        brandName: String = UUID().uuidString
    ) -> SberQRConfirmPaymentState.EditableAmount {
        
        .init(
            header: .payQR,
            productSelect: .debitAccount,
            brandName: .brandName(value: brandName),
            recipientBank: .recipientBank,
            currency: .rub,
            bottom: .paymentAmount
        )
    }
}

final class SberQRConfirmPaymentStateFixedAmountReducer {
    
    typealias State = SberQRConfirmPaymentState.FixedAmount
    typealias Event = SberQRConfirmPaymentState.FixedAmountEvent
    typealias Pay = () -> Void
    
    private let pay: Pay
    
    init(pay: @escaping Pay) {
        
        self.pay = pay
    }
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> State {
        
        switch event {
        case .pay:
            pay()
            return state
        }
    }
}

extension SberQRConfirmPaymentState {
    
    enum FixedAmountEvent {
        
        case pay
    }
}

final class SberQRConfirmPaymentStateEditableAmountReducer {
    
    typealias State = SberQRConfirmPaymentState.EditableAmount
    typealias Event = SberQRConfirmPaymentState.EditableAmountEvent
    typealias Pay = () -> Void
    
    private let pay: Pay
    
    init(pay: @escaping Pay) {
        
        self.pay = pay
    }
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> State {
        
        switch event {
        case .pay:
            pay()
            return state
        }
    }
}

extension SberQRConfirmPaymentState {
    
    enum EditableAmountEvent {
        
        case pay
    }
}
