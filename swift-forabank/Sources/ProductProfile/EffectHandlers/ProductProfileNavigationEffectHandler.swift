//
//  ProductProfileNavigationEffectHandler.swift
//
//
//  Created by Andryusina Nataly on 07.02.2024.
//

import Foundation
import ProductProfileComponents
import RxViewModel

public final class ProductProfileNavigationEffectHandler {
            
    private let makeCardGuardianViewModel: MakeCardGuardianViewModel
    private let cardGuardianActions: CardGuardianActions

    private let makeTopUpCardViewModel: MakeTopUpCardViewModel
    private let topUpCardActions: TopUpCardActions
    
    private let makeAccountInfoPanelViewModel: MakeAccountInfoPanelViewModel
    private let accountInfoPanelActions: AccountInfoPanelActions

    private let makeProductDetailsViewModel: MakeProductDetailsViewModel

    private let scheduler: AnySchedulerOfDispatchQueue
    
    public init(
        makeCardGuardianViewModel: @escaping MakeCardGuardianViewModel,
        cardGuardianActions: CardGuardianActions,
        makeTopUpCardViewModel: @escaping MakeTopUpCardViewModel,
        topUpCardActions: TopUpCardActions,
        makeAccountInfoPanelViewModel: @escaping MakeAccountInfoPanelViewModel,
        accountInfoPanelActions: AccountInfoPanelActions,
        makeProductDetailsViewModel: @escaping MakeProductDetailsViewModel,
        scheduler: AnySchedulerOfDispatchQueue
    ) {
        self.makeCardGuardianViewModel = makeCardGuardianViewModel
        self.cardGuardianActions = cardGuardianActions
        self.makeTopUpCardViewModel = makeTopUpCardViewModel
        self.topUpCardActions = topUpCardActions
        self.makeAccountInfoPanelViewModel = makeAccountInfoPanelViewModel
        self.accountInfoPanelActions = accountInfoPanelActions
        self.makeProductDetailsViewModel = makeProductDetailsViewModel
        self.scheduler = scheduler
    }
}

public extension ProductProfileNavigationEffectHandler {
    
    struct CardGuardianActions {
        
        let guardCard: GuardCard
        let toggleVisibilityOnMain: ToggleVisibilityOnMain
        let showContacts: ShowContacts
        let changePin: ChangePin
        
        public init(
            guardCard: @escaping GuardCard,
            toggleVisibilityOnMain: @escaping ToggleVisibilityOnMain,
            showContacts: @escaping ShowContacts,
            changePin: @escaping ChangePin
        ) {
            self.guardCard = guardCard
            self.toggleVisibilityOnMain = toggleVisibilityOnMain
            self.showContacts = showContacts
            self.changePin = changePin
        }
    }
    
    struct TopUpCardActions {
        
        let topUpCardFromOtherBank: TopUpCardFromOtherBank
        let topUpCardFromOurBank: TopUpCardFromOurBank
        
        public init(
            topUpCardFromOtherBank: @escaping TopUpCardFromOtherBank,
            topUpCardFromOurBank: @escaping TopUpCardFromOurBank
        ) {
            self.topUpCardFromOtherBank = topUpCardFromOtherBank
            self.topUpCardFromOurBank = topUpCardFromOurBank
        }
    }
    
    struct AccountInfoPanelActions {
        
        let accountDetails: AccountDetails
        let accountStatement: AccountStatement
        
        public init(
            accountDetails: @escaping AccountDetails,
            accountStatement: @escaping AccountStatement
        ) {
            self.accountDetails = accountDetails
            self.accountStatement = accountStatement
        }
    }
}

public extension ProductProfileNavigationEffectHandler {
    
    func handleEffect(
        _ effect: ProductProfileNavigation.Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case let .delayAlert(alert, dispatchTimeInterval):
            DispatchQueue.main.asyncAfter(deadline: .now() + dispatchTimeInterval) {
                
                dispatch(.showAlert(alert))
            }
        case let .create(panelKind):
            switch panelKind {
            case .accountInfo:
                dispatch(makeDestinationAccountInfoPanel(dispatch))
            case .cardGuardian:
                dispatch(makeDestination(dispatch))
            case .productDetails:
                dispatch(makeDestinationDetails(dispatch))
            case .topUpCard:
                dispatch(makeDestinationTopUpCard(dispatch))
            }
        case let .productProfile(effect):
            // fire and forget
            handleEffect(effect, dispatch)
        }
    }
    
    private func handleEffect(
        _ effect: ProductProfileEffect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case let .guardCard(card):
            cardGuardianActions.guardCard(card)
        case let .toggleVisibilityOnMain(product):
            cardGuardianActions.toggleVisibilityOnMain(product)
        case let .changePin(card):
            cardGuardianActions.changePin(card)
        case .showContacts:
            cardGuardianActions.showContacts()
        case let .accountOurBank(card):
            topUpCardActions.topUpCardFromOurBank(card)
        case let .accountAnotherBank(card):
            topUpCardActions.topUpCardFromOtherBank(card)
        case let .accountDetails(card):
            dispatch(makeDestinationDetails(dispatch))

           // accountInfoPanelActions.accountDetails(card)
        case let .accountStatement(card):
            accountInfoPanelActions.accountStatement(card)
            // TODO: add actions
        case let .productDetailsItemlongPress(valueForCopy, textForInformer):
            print("copy: \(valueForCopy) - informer: \(textForInformer)")
        case let .productDetailsIconTap(documentId):
            print("documentId - \(documentId)")
        }
    }
}

private extension ProductProfileNavigationEffectHandler {
    
    func makeDestination(
        _ dispatch: @escaping Dispatch
    ) -> Event {
        
        let cardGuardianViewModel = makeCardGuardianViewModel(scheduler)
        let cancellable = cardGuardianViewModel.$state
            .dropFirst()
            .compactMap(\.projection)
            .removeDuplicates()
            .map(Event.cardGuardianInput)
            .receive(on: scheduler)
            .sink { dispatch($0) }
        
        return .open(.cardGuardianRoute(.init(cardGuardianViewModel, cancellable)))
    }
}

private extension ProductProfileNavigationEffectHandler {
    
    func makeDestinationTopUpCard(
        _ dispatch: @escaping Dispatch
    ) -> Event {
        
        let topUpCardViewModel = makeTopUpCardViewModel(scheduler)
        let cancellable = topUpCardViewModel.$state
            .dropFirst()
            .compactMap(\.projection)
            .removeDuplicates()
            .map(Event.topUpCardInput)
            .receive(on: scheduler)
            .sink { dispatch($0) }
        
        return .open(.topUpCardRoute(.init(topUpCardViewModel, cancellable)))
    }
}

private extension ProductProfileNavigationEffectHandler {
    
    func makeDestinationAccountInfoPanel(
        _ dispatch: @escaping Dispatch
    ) -> Event {
        
        let accountInfoPanelViewModel = makeAccountInfoPanelViewModel(scheduler)
        let cancellable = accountInfoPanelViewModel.$state
            .dropFirst()
            .compactMap(\.projection)
            .removeDuplicates()
            .map(Event.accountInfoPanelInput)
            .receive(on: scheduler)
            .sink { dispatch($0) }
        
        return .open(.accountInfoPanelRoute(.init(accountInfoPanelViewModel, cancellable)))
    }
}

private extension ProductProfileNavigationEffectHandler {
    
    func makeDestinationDetails(
        _ dispatch: @escaping Dispatch
    ) -> Event {
        
        let productDetailsViewModel = makeProductDetailsViewModel(scheduler)
        let cancellable = productDetailsViewModel.$state
            .dropFirst()
            .compactMap(\.projection)
            .removeDuplicates()
            .map(Event.productDetailsInput)
            .receive(on: scheduler)
            .sink { dispatch($0) }
        
        return .open(.productDetailsRoute(.init(productDetailsViewModel, cancellable)))
    }
}

public extension ProductProfileNavigationEffectHandler {
    
    typealias Event = ProductProfileNavigation.Event
    typealias Effect = ProductProfileNavigation.Effect
    
    typealias Dispatch = (Event) -> Void
    
    // fire and forget
    typealias GuardCard = (CardGuardianUI.Card) -> Void
    typealias ChangePin = (CardGuardianUI.Card) -> Void
    typealias ToggleVisibilityOnMain = (Product) -> Void
    typealias ShowContacts = () -> Void
    
    typealias TopUpCardFromOtherBank = (TopUpCardUI.Card) -> Void
    typealias TopUpCardFromOurBank = (TopUpCardUI.Card) -> Void
    
    typealias AccountDetails = (AccountInfoPanel.Card) -> Void
    typealias AccountStatement = (AccountInfoPanel.Card) -> Void
    
    typealias MakeCardGuardianViewModel = (AnySchedulerOfDispatchQueue) -> CardGuardianViewModel
    typealias MakeTopUpCardViewModel = (AnySchedulerOfDispatchQueue) -> TopUpCardViewModel
    typealias MakeAccountInfoPanelViewModel = (AnySchedulerOfDispatchQueue) -> AccountInfoPanelViewModel
    typealias MakeProductDetailsViewModel = (AnySchedulerOfDispatchQueue) -> ProductDetailsViewModel
}

// MARK: - CardGuardian
private extension CardGuardianState {
    
    var projection: CardGuardianStateProjection? {
        
        switch self.event {
            
        case .none:
            return .none
        case let .buttonTapped(tap):
            return .buttonTapped(tap)
        case .appear:
            return .appear
        }
    }
}

public enum CardGuardianStateProjection: Equatable {
    case appear
    case buttonTapped(CardGuardian.ButtonEvent)
}

// MARK: - TopUpCard
private extension TopUpCardState {
    
    var projection: TopUpCardStateProjection? {
        
        switch self.event {
            
        case .none:
            return .none
        case let .buttonTapped(tap):
            return .buttonTapped(tap)
        case .appear:
            return .appear
        }
    }
}

public enum TopUpCardStateProjection: Equatable {
    case appear
    case buttonTapped(TopUpCardUI.ButtonEvent)
}

// MARK: - AccountInfoPanel

private extension AccountInfoPanelState {
    
    var projection: AccountInfoPanelStateProjection? {
        
        switch self.event {
            
        case .none:
            return .none
        case let .buttonTapped(tap):
            return .buttonTapped(tap)
        case .appear:
            return .appear
        }
    }
}

public enum AccountInfoPanelStateProjection: Equatable {
    case appear
    case buttonTapped(AccountInfoPanel.ButtonEvent)
}

// MARK: - Details

private extension ProductDetailsState {
    
    var projection: ProductDetailsStateProjection? {
        
        switch self.event {
            
        case .none:
            return .none
        case let .itemTapped(tap):
            return .itemTapped(tap)
        case .appear:
            return .appear
        }
    }
}

public enum ProductDetailsStateProjection: Equatable {
    case appear
    case itemTapped(ProductDetailEvent)
}
