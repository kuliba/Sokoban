//
//  RootViewModelFactory+openProduct.swift
//  Vortex
//
//  Created by Igor Malyarov on 06.02.2025.
//

extension RootViewModelFactory {
    
    @inlinable
    func openProduct(
        type: OpenProductType,
        notify: @escaping RootViewDomain.Notify
    ) -> OpenProduct {
        
        switch type {
        case .account:        return .unknown
            
        case .card:
            return .card(openCardProduct(notify: { notify(.select(.orderCardResponse($0))) }))
            
        case .creditCardMVP:
            return .creditCardMVP
            
        case .deposit:        return .unknown
        case .insurance:      return .unknown
        case .loan:           return .unknown
        case .mortgage:       return .unknown
            
        case .savingsAccount:
            return .savingsAccount(makeSavingsNodes({ notify(.dismiss) }, { notify(.select(.savingsAccount($0))) }))
            
        case .sticker:        return .unknown
        }
    }
}
