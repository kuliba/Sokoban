//
//  SberQRConfirmPaymentStateTests.swift
//
//
//  Created by Igor Malyarov on 06.12.2023.
//

import SberQR
import XCTest

final class SberQRConfirmPaymentStateTests: GetSberQRDataResponseTests {
    
    // MARK: - init
    
    func test_init_fixedAmount_fromResponseWithFixedAmount() throws {
        
        let response = responseWithFixedAmount()
        
        let state = try SberQRConfirmPaymentState(product: .test2, response: response)
        
        XCTAssertNoDiff(state, .init(
            confirm: .fixedAmount(.init(
                header: .payQR,
                productSelect: .compact(.test2),
                brandName: .brandName(value: "сббол енот_QR"),
                amount: .amount,
                recipientBank: .recipientBank,
                button: .preview
            )),
            isInflight: false
        ))
    }
    
    func test_init_editableAmount_fromResponseWithEditableAmount_zero() throws {
        
        let amount: Decimal = 0
        let response = responseWithEditableAmount(amount: amount)
        
        let state = try SberQRConfirmPaymentState(product: .test2, response: response)
        
        XCTAssertNoDiff(state, .init(
            confirm: .editableAmount(.init(
                header: .payQR,
                productSelect: .compact(.test2),
                brandName: .brandName(value: "Тест Макусов. Кутуза_QR"),
                recipientBank: .recipientBank,
                currency: .rub,
                amount: .paymentAmount(
                    value: amount,
                    isEnabled: false
                )
            )),
            isInflight: false
        ))
    }
    
    func test_init_editableAmount_fromResponseWithEditableAmount() throws {
        
        let amount: Decimal = 123.45
        let response = responseWithEditableAmount(amount: amount)
        
        let state = try SberQRConfirmPaymentState(product: .test2, response: response)
        
        XCTAssertNoDiff(state, .init(
            confirm: .editableAmount(.init(
                header: .payQR,
                productSelect: .compact(.test2),
                brandName: .brandName(value: "Тест Макусов. Кутуза_QR"),
                recipientBank: .recipientBank,
                currency: .rub,
                amount: .paymentAmount(
                    value: amount,
                    isEnabled: true
                )
            )),
            isInflight: false
        ))
    }
}
