//
//  SberQRConfirmPaymentViewModel+preview.swift
//
//
//  Created by Igor Malyarov on 08.12.2023.
//

import Foundation

extension SberQRConfirmPaymentViewModel {
    
    static func preview(
        initialState: State,
        pay: @escaping (State) -> Void = { _ in }
    ) -> SberQRConfirmPaymentViewModel {
        
        let reducer = SberQRConfirmPaymentStateReducer.default(
            getProducts: { [.cardPreview, .accountPreview] },
            pay: pay
        )
        
        return .init(
            initialState: initialState,
            reduce: reducer.reduce(_:_:),
            scheduler: .immediate
        )
    }
}
