//
//  PreviewContent.swift
//  CardGuardianPreview
//
//  Created by Andryusina Nataly on 06.02.2024.
//

import Foundation
import CardGuardianModule
import ProductProfile

extension ProductProfileViewModel {
    
    static func preview(
        initialState: ProductProfileNavigation.State = .init(),
        buttons: [CardGuardianState._Button],
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) -> ProductProfileViewModel {
        
        let productProfileReducer = ProductProfileReducer().reduce(_:_:)
        let productProfileEffectHandler = ProductProfileEffectHandler().handleEffect(_:_:)
        
        let cardGuardianReducer = CardGuardianReducer().reduce(_:_:)
        
        typealias MakeCardGuardianViewModel = (AnySchedulerOfDispatchQueue) -> CardGuardianViewModel
        
        let makeCardGuardianViewModel: MakeCardGuardianViewModel =  { _ in
            
                .init(
                    initialState: .init(buttons: buttons),
                    reduce: cardGuardianReducer,
                    handleEffect: { _,_ in }
                )
        }
        
        let navigationStateManager: ProductProfileNavigationStateManager = .init(
            reduce: productProfileReducer,
            handleEffect: productProfileEffectHandler,
            makeCardGuardianViewModel: makeCardGuardianViewModel)
        
        return .init(
            initialState: initialState,
            navigationStateManager: navigationStateManager,
            scheduler: scheduler)
    }
}

extension ProductProfileView {
    
    static let cardUnblokedOnMain: Self = .init(
        viewModel: .preview(buttons: .preview)
    )
    
    static let cardBlockedHideOnMain : Self = .init(
        viewModel: .preview(buttons: .previewBlockHide)
    )
    
    static let cardBlockedUnlockNotAvailable : Self = .init(
        viewModel: .preview(buttons: .previewBlockUnlockNotAvailable)
    )
}
