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
        notify: @escaping (OpenCardDomain.OrderCardResult) -> Void
    ) -> OpenProduct {
        
        switch type {
        case .account:        return .unknown
        case .card:           return .card(openCardProduct(notify: notify))
        case .deposit:        return .unknown
        case .insurance:      return .unknown
        case .loan:           return .unknown
        case .mortgage:       return .unknown
        case .savingsAccount: return .unknown
        case .sticker:        return .unknown
        }
    }
}
