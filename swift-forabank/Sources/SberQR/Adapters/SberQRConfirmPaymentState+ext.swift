//
//  SberQRConfirmPaymentState+ext.swift
//
//
//  Created by Igor Malyarov on 06.12.2023.
//

import Foundation

public extension SberQRConfirmPaymentState {
    
    func makePayload(
        with url: URL
    ) -> CreateSberQRPaymentPayload {
        
        .init(qrLink: url, product: product, amount: amount)
    }
    
    private var productSelect: ProductSelect {
        
        switch self {
        case let .fixedAmount(fixedAmount):
            return fixedAmount.productSelect
            
        case let .editableAmount(editableAmount):
            return editableAmount.productSelect
        }
    }
    
    private var selectedProduct: ProductSelect.Product {
        
        switch productSelect {
        case let .compact(product):
            return product
            
        case let .expanded(product, _):
            return product
        }
    }
    
    private var product: CreateSberQRPaymentPayload.Product {
        
        switch (selectedProduct.type, selectedProduct.id.rawValue) {
        case let (.account, id):
            return .account(.init(id))
            
        case let (.card, id):
            return .card(.init(id))
        }
    }
    
    private var amount: CreateSberQRPaymentPayload.Amount? {
        
        guard case let .editableAmount(editableAmount) = self
        else { return nil }
        
        return .init(
            amount: editableAmount.amount.value,
            currency: .init(editableAmount.currency.value)
        )
    }
}
