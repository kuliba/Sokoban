//
//  PreviewContent.swift
//  CardGuardianPreview
//
//  Created by Andryusina Nataly on 06.02.2024.
//

import Foundation
import ProductProfileComponents
import ProductProfile
import RxViewModel

extension ProductProfileViewModel {
    
    typealias MakeCardGuardianViewModel = (AnySchedulerOfDispatchQueue) -> CardGuardianViewModel
    typealias MakeTopUpCardViewModel = (AnySchedulerOfDispatchQueue) -> TopUpCardViewModel
    typealias MakeAccountInfoPanelViewModel = (AnySchedulerOfDispatchQueue) -> AccountInfoPanelViewModel
    typealias MakeProductDetailsViewModel = (AnySchedulerOfDispatchQueue) -> ProductDetailsViewModel

    static func preview(
        initialState: ProductProfileNavigation.State = .init(),
        buttons: [CardGuardianState._Button],
        topUpCardButtons: [TopUpCardState.PanelButton],
        accountInfoPanelButtons: [AccountInfoPanelState.PanelButton],
        details: [ProductDetailsUI.ListItem],
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
        
        let accountInfoPanelReduce = AccountInfoPanelReducer().reduce(_:_:)
        
        let accountInfoPanelHandleEffect = AccountInfoPanelEffectHandler().handleEffect(_:_:)
        
        let makeAccountInfoPanelViewModel: MakeAccountInfoPanelViewModel =  {
            
            .init(
                initialState: .init(buttons: accountInfoPanelButtons),
                reduce: accountInfoPanelReduce,
                handleEffect: accountInfoPanelHandleEffect,
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
        
        let accountDetails: ProductProfileNavigationEffectHandler.AccountDetails = {
            print("account details: card \($0.status)")
        }
        
        let accountStatement: ProductProfileNavigationEffectHandler.AccountStatement = {
            print("account statement: card \($0.status)")
        }
        
        let detailsReduce = ProductDetailsReducer().reduce(_:_:)
        
        let detailsHandleEffect = ProductDetailsEffectHandler().handleEffect(_:_:)
        
        let makeDetailsViewModel: MakeProductDetailsViewModel =  {
            
            .init(
                initialState: .init(items: details),
                reduce: detailsReduce,
                handleEffect: detailsHandleEffect,
                scheduler: $0
            )
        }
        
        let handleEffect = ProductProfileNavigationEffectHandler(
            makeCardGuardianViewModel: makeCardGuardianViewModel,
            cardGuardianActions: .init(
                guardCard: guardianCard,
                toggleVisibilityOnMain: toggleVisibilityOnMain,
                showContacts: showContacts,
                changePin: changePin),
            makeTopUpCardViewModel: makeTopUpCardViewModel,
            topUpCardActions: .init(
                topUpCardFromOtherBank: topUpCardFromOtherBank,
                topUpCardFromOurBank: topUpCardFromOurBank),
            makeAccountInfoPanelViewModel: makeAccountInfoPanelViewModel,
            accountInfoPanelActions: .init(
                accountDetails: accountDetails,
                accountStatement: accountStatement),
            makeProductDetailsViewModel: makeDetailsViewModel,
            scheduler: scheduler
        ).handleEffect(_:_:)
        
        return .init(
            initialState: .init(),
            reduce: productProfileNavigationReduce,
            handleEffect: handleEffect)
    }
}
