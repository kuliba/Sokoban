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
        
        let guardianReduce = GuardianReducer().reduce(_:_:)
        let showOnMainReduce = ShowOnMainReducer().reduce(_:_:)

        let productProfileReduce = ProductProfileReducer(
            guardianReduce: guardianReduce,
            showOnMainReduce: showOnMainReduce
        ).reduce(_:_:)
        
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

        let handleEffect = ProductProfileEffectHandler(
            makeCardGuardianViewModel: makeCardGuardianViewModel,
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
