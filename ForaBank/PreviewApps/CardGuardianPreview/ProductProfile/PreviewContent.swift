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
import ActivateSlider

extension ProductProfileViewModel {
    
    typealias MakeCardGuardianViewModel = (AnySchedulerOfDispatchQueue) -> CardGuardianViewModel
    
    typealias MakeCardViewModel = (AnySchedulerOfDispatchQueue) -> CardViewModel
    
    static func preview(
        initialState: ProductProfileNavigation.State = .init(),
        buttons: [CardGuardianState._Button],
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) -> ProductProfileViewModel {
        
        let cardGuardianReduce = CardGuardianReducer().reduce(_:_:)
        
        let productProfileNavigationReduce = ProductProfileNavigationReducer().reduce(_:_:)
        
        let makeCardGuardianViewModel: MakeCardGuardianViewModel =  {
            
            .init(
                initialState: .init(buttons: buttons),
                reduce: cardGuardianReduce,
                handleEffect: { _,_ in },
                scheduler: $0
            )
        }
        
        let cardReduce = CardReducer().reduce(_:_:)
        
        let makeCardViewModel: MakeCardViewModel =  {
            
            .init(
                initialState: .status(nil),
                reduce: cardReduce,
                handleEffect: { _,_ in },
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
        
        let handleEffect = ProductProfileNavigationEffectHandler(
            makeCardGuardianViewModel: makeCardGuardianViewModel,
            makeCardViewModel: makeCardViewModel,
            guardianCard: guardianCard,
            toggleVisibilityOnMain: toggleVisibilityOnMain,
            showContacts: showContacts,
            changePin: changePin,
            scheduler: scheduler
        ).handleEffect(_:_:)
        
        return .init(
            initialState: .init(),
            reduce: productProfileNavigationReduce,
            handleEffect: handleEffect)
    }
}
