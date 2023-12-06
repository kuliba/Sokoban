////
////  SberQRConfirmPaymentStateEditableAmountReducerTests.swift
////  
////
////  Created by Igor Malyarov on 06.12.2023.
////
//
//import XCTest
//
//final class SberQRConfirmPaymentStateEditableAmountReducer {
//    
//    typealias State = SberQRConfirmPaymentState.EditableAmount
//    typealias Event = SberQRConfirmPaymentState.EditableAmountEvent
//    typealias Pay = () -> Void
//    
//    private let pay: Pay
//    
//    init(pay: @escaping Pay) {
//        
//        self.pay = pay
//    }
//    
//    func reduce(
//        _ state: State,
//        _ event: Event
//    ) -> State {
//        
//        switch event {
//        case let .editAmount(amount):
//            return .init(
//                header: state.header,
//                productSelect: state.productSelect,
//                brandName: state.brandName,
//                recipientBank: state.recipientBank,
//                currency: state.currency,
//                bottom: .init(
//                    id: state.bottom.id,
//                    value: amount,
//                    title: state.bottom.title,
//                    validationRules: state.bottom.validationRules,
//                    button: state.bottom.button
//                )
//            )
//            
//        case .pay:
//            pay()
//            return state
//        }
//    }
//}
//
//extension SberQRConfirmPaymentState {
//    
//    enum EditableAmountEvent {
//        
//        case editAmount(Decimal)
//        case pay
//    }
//}
//
//final class SberQRConfirmPaymentStateEditableAmountReducerTests: XCTestCase {
//    
//    func test_editableAmountReducer_init_shouldNotCallPay() {
//        
//        var payCallCount = 0
//        _ = EditableAmountReducer { payCallCount += 1 }
//        
//        XCTAssertNoDiff(payCallCount, 0)
//    }
//    
//    func test_editableAmountReducer_reduce_shouldCallPayOnPay() {
//        
//        var payCallCount = 0
//        let reducer = EditableAmountReducer { payCallCount += 1 }
//        
//        _ = reducer.reduce(makeEditableAmount(amount: 123.45), .pay)
//        
//        XCTAssertNoDiff(payCallCount, 1)
//    }
//    
//    func test_editableAmountReducer_reduce_shouldNotChangeStateOnPay() {
//        
//        let reducer = EditableAmountReducer {}
//        let state = makeEditableAmount(amount: 123.45)
//        
//        let newState = reducer.reduce(state, .pay)
//        
//        XCTAssertNoDiff(newState, state)
//    }
//    
//    func test_editableAmountReducer_reduce_shouldNotCallPayOnEditAmount() {
//        
//        var payCallCount = 0
//        let reducer = EditableAmountReducer { payCallCount += 1 }
//        
//        _ = reducer.reduce(makeEditableAmount(amount: 123.45), .editAmount(3_456.78))
//        
//        XCTAssertNoDiff(payCallCount, 0)
//    }
//    
//    func test_editableAmountReducer_reduce_shouldChangeStateOnEditAmount() {
//        
//        let amount: Decimal = 123.45
//        let brandName = "Some Brand Name"
//        let reducer = EditableAmountReducer {}
//        let state = makeEditableAmount(
//            brandName: brandName,
//            amount: amount
//        )
//        
//        let newState = reducer.reduce(state, .editAmount(3_456.78))
//        
//        XCTAssertNoDiff(newState, makeEditableAmount(
//            brandName: brandName,
//            amount: 3_456.78
//        ))
//    }
//        // MARK: - Helpers
//
//    private typealias EditableAmountReducer = SberQRConfirmPaymentStateEditableAmountReducer
//    
//    private func makeEditableAmount(
//        brandName: String = UUID().uuidString,
//        amount: Decimal
//    ) -> SberQRConfirmPaymentState.EditableAmount {
//        
//        .init(
//            header: .payQR,
//            productSelect: .debitAccount,
//            brandName: .brandName(value: brandName),
//            recipientBank: .recipientBank,
//            currency: .rub,
//            bottom: .paymentAmount(value: amount)
//        )
//    }
//}
