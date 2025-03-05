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
        case let .card(type):
            switch type {
            case .form:
                return .card(.form(openCardProduct(notify: { notify(.select(.orderCardResponse($0))) })))
            case .landing:
                return .card(.landing(makeOrderCardLanding()))
            }
        case .deposit:        return .unknown
        case .insurance:      return .unknown
        case .collateralLoan: return .unknown
        case .mortgage:       return .unknown
        case .savingsAccount: return .savingsAccount(makeSavingsNodes(notify: notify))
        case .sticker:        return .unknown
        }
    }
}
