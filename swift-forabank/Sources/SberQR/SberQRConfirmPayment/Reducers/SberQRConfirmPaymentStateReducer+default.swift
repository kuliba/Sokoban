//
//  SberQRConfirmPaymentStateReducer+default.swift
//  
//
//  Created by Igor Malyarov on 08.12.2023.
//

extension SberQRConfirmPaymentStateReducer {
    
    public typealias GetProducts = () -> [ProductSelect.Product]
    public typealias Pay = (State) -> Void
    
    public static func `default`(
        getProducts: @escaping GetProducts,
        pay: @escaping Pay
    ) -> SberQRConfirmPaymentStateReducer {
        
        let productSelectReducer = ProductSelectReducer(
            getProducts: getProducts
        )
        let editableReducer = SberQRConfirmPaymentStateEditableAmountReducer(
            productSelectReduce: productSelectReducer.reduce(_:_:),
            pay: { pay(.editableAmount($0)) }
        )
        let fixedReducer = SberQRConfirmPaymentStateFixedAmountReducer(
            productSelectReduce: productSelectReducer.reduce(_:_:),
            pay: { pay(.fixedAmount($0)) }
        )
        
        return .init(
            editableReduce: editableReducer.reduce(_:_:),
            fixedReduce: fixedReducer.reduce(_:_:)
        )
    }
}
