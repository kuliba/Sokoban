//
//  PreviewContent.swift
//  CardGuardianPreview
//
//  Created by Andryusina Nataly on 06.02.2024.
//

import Foundation
import CardGuardianUI
import ProductProfile
import RxViewModel
import ActivateSlider
import TopUpCardUI

extension ProductProfileViewModel {
    
    typealias MakeCardGuardianViewModel = (AnySchedulerOfDispatchQueue) -> CardGuardianViewModel
    typealias MakeTopUpCardViewModel = (AnySchedulerOfDispatchQueue) -> TopUpCardViewModel

    static func preview(
        initialState: ProductProfileNavigation.State = .init(),
        buttons: [CardGuardianState._Button],
        topUpCardButtons: [TopUpCardState.PanelButton],
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) -> ProductProfileViewModel {
        
        let cardGuardianReduce = CardGuardianReducer().reduce(_:_:)

        let productProfileNavigationReduce = ProductProfileNavigationReducer().reduce(_:_:)
        
        let cardGuardianHandleEffect = CardGuardianEffectHandler().handleEffect(_:_:)
        
        let makeCardGuardianViewModel: MakeCardGuardianViewModel =  {
            
            .init(
                initialState: .init(buttons: buttons),
                reduce: cardGuardianReduce,
                handleEffect: cardGuardianHandleEffect,
                scheduler: $0
            )
        }
        
        let topUpCardReduce = TopUpCardReducer().reduce(_:_:)
        
        let topUpCardHandleEffect = TopUpCardEffectHandler().handleEffect(_:_:)

        let makeTopUpCardViewModel: MakeTopUpCardViewModel =  {
            
            .init(
                initialState: .init(buttons: topUpCardButtons),
                reduce: topUpCardReduce,
                handleEffect: topUpCardHandleEffect,
                scheduler: $0
            )
        }
                        
        let guardianCard: ProductProfileNavigationEffectHandler.GuardCard = {
            print("block/unblock card \($0.status)")
        }
        
        let toggleVisibilityOnMain: ProductProfileNavigationEffectHandler.ToggleVisibilityOnMain = {
            print("show/hide product \($0.productID)")
        }
        
        let changePin: ProductProfileNavigationEffectHandler.GuardCard = {
            print("change pin \($0)")
        }
        
        let showContacts: ProductProfileNavigationEffectHandler.ShowContacts = {
            print("show contacts")
        }
        
        let topUpCardFromOtherBank: ProductProfileNavigationEffectHandler.TopUpCardFromOtherBank = {
            print("top up card \($0.status)")
        }

        let topUpCardFromOurBank: ProductProfileNavigationEffectHandler.TopUpCardFromOurBank = {
            print("top up card \($0.status)")
        }

        
        let handleEffect = ProductProfileNavigationEffectHandler(
            makeCardGuardianViewModel: makeCardGuardianViewModel,
            guardianCard: guardianCard,
            toggleVisibilityOnMain: toggleVisibilityOnMain,
            showContacts: showContacts,
            changePin: changePin,
            makeTopUpCardViewModel: makeTopUpCardViewModel,
            topUpCardFromOtherBank: topUpCardFromOtherBank,
            topUpCardFromOurBank: topUpCardFromOurBank,
            scheduler: scheduler
        ).handleEffect(_:_:)
        
        return .init(
            initialState: .init(),
            reduce: productProfileNavigationReduce,
            handleEffect: handleEffect)
    }
}
