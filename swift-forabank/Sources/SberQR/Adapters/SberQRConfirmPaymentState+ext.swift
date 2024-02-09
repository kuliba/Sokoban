//
//  SberQRConfirmPaymentState+ext.swift
//
//
//  Created by Igor Malyarov on 06.12.2023.
//

import Foundation
import PaymentComponents

public extension SberQRConfirmPaymentState {
    
    func makePayload(
        with url: URL
    ) -> CreateSberQRPaymentPayload? {
        
        guard let product else { return nil }
        
        return .init(qrLink: url, product: product, amount: amount)
    }
    
    var productSelect: ProductSelect {
        
        switch confirm {
        case let .fixedAmount(fixedAmount):
            return fixedAmount.productSelect
            
        case let .editableAmount(editableAmount):
            return editableAmount.productSelect
        }
    }
    
    private var product: CreateSberQRPaymentPayload.Product? {
        
        guard let selected = productSelect.selected
        else { return nil }
        
        switch (selected.type, selected.id.rawValue) {
        case let (.account, id):
            return .account(.init(id))
            
        case let (.card, id):
            return .card(.init(id))
        }
    }
    
    private var amount: CreateSberQRPaymentPayload.Amount? {
        
        guard case let .editableAmount(editableAmount) = confirm
        else { return nil }
        
        return .init(
            amount: editableAmount.amount.value,
            currency: .init(editableAmount.currency.value)
        )
    }
}
