//
//  RootViewModelFactory+makeCardPromoLanding.swift
//  Vortex
//
//  Created by Дмитрий Савушкин on 07.03.2025.
//

import Foundation

extension RootViewModelFactory {
    
    @inlinable
    func makeCardPromoLanding(
        flag: OrderCardFlag,
        dismiss: @escaping () -> Void
    ) -> AuthProductsLandingDomain.Binder {
        
        let flow: AuthProductsLandingDomain.Flow = composeFlow(
            initialState: .init(),
            delayProvider: { _ in .zero },
            getNavigation: getNavigation
        )
        
        let content = makeContent(
            flag: flag,
            action: { flow.event(.select(.productID($0))) },
            dismiss: dismiss
        )
        
        return .init(
            content: content,
            flow: flow,
            bind: { _,_ in .init() }
        )
    }
    
    @inlinable
    func getNavigation(
        select: AuthProductsLandingDomain.Select,
        notify: @escaping AuthProductsLandingDomain.Notify,
        completion: @escaping (AuthProductsLandingDomain.Navigation) -> Void
    ) {
        switch select {
        case let .productID(productID):
            completion(.productID(productID))
        }
    }
    
    @inlinable
    func makeContent(
        flag: OrderCardFlag,
        action: @escaping (Int) -> Void,
        dismiss: @escaping () -> Void
    ) -> AuthProductsLandingDomain.Content {
        
        switch flag.rawValue {
        case .inactive:
            return .init(
                self.model,
                products: self.model.catalogProducts.value,
                dismissAction: dismiss
            )
        case .active:
            return .init(
                self.model,
                products: self.model.catalogProducts.value,
                action: action,
                dismissAction: dismiss
            )
        }
    }
}
