//
//  PreviewContent.swift
//  CardGuardianPreview
//
//  Created by Andryusina Nataly on 06.02.2024.
//

import Foundation
import CardGuardianModule
import ProductProfile
import RxViewModel

extension ProductProfileViewModel {
    
    static func preview(
        initialState: ProductProfileNavigation.State = .init(),
        buttons: [CardGuardianState._Button],
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) -> ProductProfileViewModel {
                
        let cardGuardianReduce = CardGuardianReducer().reduce(_:_:)

        let productProfileNavigationReduce = ProductProfileNavigationReducer().reduce(_:_:)

        
        typealias MakeCardGuardianViewModel = (AnySchedulerOfDispatchQueue) -> CardGuardianViewModel
        
        let makeCardGuardianViewModel: MakeCardGuardianViewModel =  {
            
                .init(
                    initialState: .init(buttons: buttons),
                    reduce: cardGuardianReduce,
                    handleEffect: { _,_ in },
                    scheduler: $0
                )
        }

        let blockCard: ProductProfileNavigationEffectHandler.CardGuardianAction = {
            print("block card \($0.status)")
        }
        
        let unblockCard: ProductProfileNavigationEffectHandler.CardGuardianAction = {
            print("unblock card \($0.status)")
        }

        let showOnMain: ProductProfileNavigationEffectHandler.ShowOnMainAction = {
            print("showOnMain product \($0.productID)")
        }

        let hideFormMain: ProductProfileNavigationEffectHandler.ShowOnMainAction = {
            print("hide from main product \($0.productID)")
        }

        let changePin: ProductProfileNavigationEffectHandler.CardGuardianAction = {
            print("change pin \($0)")
        }

        let showContacts: ProductProfileNavigationEffectHandler.EmptyAction = {
            print("show contacts")
        }
        
        let handleEffect = ProductProfileNavigationEffectHandler(
            makeCardGuardianViewModel: makeCardGuardianViewModel,
            blockCard: blockCard,
            unblockCard: unblockCard,
            showOnMain: showOnMain,
            hideFromMain: hideFormMain,
            showContacts: showContacts,
            changePin: changePin,
            scheduler: scheduler
        )
            .handleEffect(_:_:)
        
        let navigationStateManager: ProductProfileNavigationStateManager = .init(
            reduce: productProfileNavigationReduce,
            handleEffect: handleEffect)
        
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
