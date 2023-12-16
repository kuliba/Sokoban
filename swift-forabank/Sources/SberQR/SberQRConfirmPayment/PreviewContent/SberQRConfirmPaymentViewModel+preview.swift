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
        
        return .`default`(
            initialState: initialState,
            getProducts: { .allProducts },
            pay: pay,
            scheduler: .main
        )
    }
}
