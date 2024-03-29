//
//  SberQRConfirmPaymentState+makePayloadTests.swift
//
//
//  Created by Igor Malyarov on 07.12.2023.
//

import SberQR
import PaymentComponents
import XCTest

final class SberQRConfirmPaymentState_makePayloadTests: XCTestCase {
    
    func test_editableAmount_card() {
        
        let id = 987654321
        let amount: Decimal = 564.21
        let state = makeEditable(anyCard(id: id), amount: amount)
        let url = anyURL()
        
        let payload = state.makePayload(with: url)
        
        XCTAssertNoDiff(payload, .init(
            qrLink: url,
            product: .card(.init(id)),
            amount: .init(
                amount: amount,
                currency: "RUB"
            )
        ))
    }
    
    func test_editableAmount_account() {
        
        let id = 7654321
        let amount: Decimal = 678.65
        let state = makeEditable(anyAccount(id: id), amount: amount)
        let url = anyURL()
        
        let payload = state.makePayload(with: url)
        
        XCTAssertNoDiff(payload, .init(
            qrLink: url,
            product: .account(.init(id)),
            amount: .init(
                amount: amount,
                currency: "RUB"
            )
        ))
    }
    
    func test_fixedAmount_card() {
        
        let id = 987654321
        let state = makeFixed(anyCard(id: id))
        let url = anyURL()
        
        let payload = state.makePayload(with: url)
        
        XCTAssertNoDiff(payload, .init(
            qrLink: url,
            product: .card(.init(id)),
            amount: nil
        ))
    }
    
    func test_fixedAmount_account() {
        
        let id = 7654321
        let state = makeFixed(anyAccount(id: id))
        let url = anyURL()
        
        let payload = state.makePayload(with: url)
        
        XCTAssertNoDiff(payload, .init(
            qrLink: url,
            product: .account(.init(id)),
            amount: nil
        ))
    }
    
    // MARK: - Helpers
    
    private func makeEditable(
        _ product: ProductSelect.Product,
        amount: Decimal
    ) -> SberQRConfirmPaymentState {
        
        .init(confirm: .editableAmount(
            makeEditableAmount(
                productSelect: .compact(product),
                amount: amount
            )
        ))
    }
    
    private func makeFixed(
        _ product: ProductSelect.Product
    ) -> SberQRConfirmPaymentState {
        
        .init(confirm: .fixedAmount(
            makeFixedAmount(
                productSelect: .compact(product)
            )
        ))
    }
    
    private func anyCard(
        id: Int = 1234567890
    ) -> ProductSelect.Product {
        
        anyProduct(id: id, type: .card)
    }
    
    private func anyAccount(
        id: Int = 1234567890
    ) -> ProductSelect.Product {
        
        anyProduct(id: id, type: .account)
    }
    
    private func anyProduct(
        id: Int,
        type: ProductSelect.Product.ProductType,
        isAdditional: Bool = false,
        balance: Decimal = 99,
        color: String = "red"
    ) -> ProductSelect.Product {
        
        .init(
            id: .init(id),
            type: type, 
            isAdditional: isAdditional,
            header: "Счет списания",
            title: "",
            footer: "",
            amountFormatted: "",
            balance: balance,
            look: .test(color: color)
        )
    }
}
