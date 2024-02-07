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
        
        let productProfileReduce = ProductProfileReducer().reduce(_:_:)
        let handleEffect = ProductProfileEffectHandler().handleEffect(_:_:)
        
        let cardGuardianReduce = CardGuardianReducer().reduce(_:_:)
        
        typealias MakeCardGuardianViewModel = (AnySchedulerOfDispatchQueue) -> CardGuardianViewModel
        
        let makeCardGuardianViewModel: MakeCardGuardianViewModel =  { _ in
            
                .init(
                    initialState: .init(buttons: buttons),
                    reduce: cardGuardianReduce,
                    handleEffect: { _,_ in }
                )
        }
        
        let navigationStateManager: ProductProfileNavigationStateManager = .init(
            reduce: productProfileReduce,
            handleEffect: handleEffect,
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
