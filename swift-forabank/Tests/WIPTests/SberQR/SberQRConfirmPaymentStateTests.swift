//
//  SberQRConfirmPaymentStateTests.swift
//
//
//  Created by Igor Malyarov on 06.12.2023.
//

import XCTest

final class SberQRConfirmPaymentStateTests: GetSberQRDataResponseTests {
    
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
}
