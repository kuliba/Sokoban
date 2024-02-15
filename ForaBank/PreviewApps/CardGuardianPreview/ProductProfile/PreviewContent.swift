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

        let guardianCard: ProductProfileNavigationEffectHandler.CardGuardianAction = {
            print("block/unblock card \($0.status)")
        }
        
        let visibilityOnMain: ProductProfileNavigationEffectHandler.VisibilityOnMainAction = {
            print("show/hide product \($0.productID)")
        }

        let changePin: ProductProfileNavigationEffectHandler.CardGuardianAction = {
            print("change pin \($0)")
        }

        let showContacts: ProductProfileNavigationEffectHandler.EmptyAction = {
            print("show contacts")
        }
        
        let handleEffect = ProductProfileNavigationEffectHandler(
            makeCardGuardianViewModel: makeCardGuardianViewModel,
            guardianCard: guardianCard,
            visibilityOnMain: visibilityOnMain,
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

extension ControlButtonView {
    
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

extension CvvButtonView {
    
    static let cardUnblokedOnMain: Self = .init(
        viewModel: .preview(buttons: .preview)
    )
}
