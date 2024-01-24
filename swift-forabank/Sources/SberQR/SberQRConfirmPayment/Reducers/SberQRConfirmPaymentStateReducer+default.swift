//
//  SberQRConfirmPaymentStateReducer+default.swift
//  
//
//  Created by Igor Malyarov on 08.12.2023.
//

import PaymentComponents

extension SberQRConfirmPaymentStateReducer {
    
    public typealias GetProducts = () -> [ProductSelect.Product]
    
    public static func `default`(
        getProducts: @escaping GetProducts,
        pay: @escaping Pay
    ) -> SberQRConfirmPaymentStateReducer {
        
        let productSelectReducer = ProductSelectReducer(
            getProducts: getProducts
        )
        let editableReducer = SberQRConfirmPaymentStateEditableAmountReducer(
            productSelectReduce: productSelectReducer.reduce(_:_:)
        )
        let fixedReducer = SberQRConfirmPaymentStateFixedAmountReducer(
            productSelectReduce: productSelectReducer.reduce(_:_:)
        )
        
        return .init(
            editableReduce: editableReducer.reduce(_:_:),
            fixedReduce: fixedReducer.reduce(_:_:), 
            pay: pay
        )
    }
}
