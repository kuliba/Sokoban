//
//  SberQRConfirmPaymentViewModel+default.swift
//
//
//  Created by Igor Malyarov on 09.12.2023.
//

import PaymentComponents

public extension SberQRConfirmPaymentViewModel {
    
    typealias GetProducts = () -> [ProductSelect.Product]
    typealias Pay = (State) -> Void
    
    static func `default`(
        initialState: State,
        getProducts: @escaping GetProducts,
        pay: @escaping Pay,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) -> SberQRConfirmPaymentViewModel {
        
        let reducer = SberQRConfirmPaymentStateReducer.default(
            getProducts: getProducts,
            pay: pay
        )
        
        return .init(
            initialState: initialState,
            reduce: reducer.reduce(_:_:),
            scheduler: scheduler
        )
    }
}
