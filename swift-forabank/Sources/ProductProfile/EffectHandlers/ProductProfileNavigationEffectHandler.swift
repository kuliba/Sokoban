//
//  ProductProfileNavigationEffectHandler.swift
//
//
//  Created by Andryusina Nataly on 07.02.2024.
//

import Foundation
import CardGuardianUI
import TopUpCardUI
import RxViewModel

public final class ProductProfileNavigationEffectHandler {
            
    private let makeCardGuardianViewModel: MakeCardGuardianViewModel
    private let makeTopUpCardViewModel: MakeTopUpCardViewModel

    private let guardCard: GuardCard
    private let toggleVisibilityOnMain: ToggleVisibilityOnMain
    private let showContacts: ShowContacts
    private let changePin: ChangePin
    
    private let topUpCardFromOtherBank: TopUpCardFromOtherBank
    private let topUpCardFromOurBank: TopUpCardFromOurBank

    private let scheduler: AnySchedulerOfDispatchQueue
    
    public init(
        makeCardGuardianViewModel: @escaping MakeCardGuardianViewModel,
        guardianCard: @escaping GuardCard,
        toggleVisibilityOnMain: @escaping ToggleVisibilityOnMain,
        showContacts: @escaping ShowContacts,
        changePin: @escaping ChangePin,
        makeTopUpCardViewModel: @escaping MakeTopUpCardViewModel,
        topUpCardFromOtherBank: @escaping TopUpCardFromOtherBank,
        topUpCardFromOurBank: @escaping TopUpCardFromOurBank,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
        self.makeCardGuardianViewModel = makeCardGuardianViewModel
        self.guardCard = guardianCard
        self.toggleVisibilityOnMain = toggleVisibilityOnMain
        self.showContacts = showContacts
        self.changePin = changePin
        self.makeTopUpCardViewModel = makeTopUpCardViewModel
        self.topUpCardFromOurBank = topUpCardFromOurBank
        self.topUpCardFromOtherBank = topUpCardFromOtherBank
        self.scheduler = scheduler
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
            case .cardGuardian:
                dispatch(makeDestination(dispatch))
            case .topUpCard:
                dispatch(makeDestinationTopUpCard(dispatch))
            }
        case let .productProfile(effect):
            // fire and forget
            handleEffect(effect)
        }
    }
    
    private func handleEffect(
        _ effect: ProductProfileEffect
    ) {
        switch effect {
        case let .guardCard(card):
            guardCard(card)
        case let .toggleVisibilityOnMain(product):
            toggleVisibilityOnMain(product)
        case let .changePin(card):
            changePin(card)
        case .showContacts:
            showContacts()
        case let .accountOurBank(card):
            topUpCardFromOurBank(card)
        case let .accountAnotherBank(card):
            topUpCardFromOtherBank(card)
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
    
    typealias MakeCardGuardianViewModel = (AnySchedulerOfDispatchQueue) -> CardGuardianViewModel
    typealias MakeTopUpCardViewModel = (AnySchedulerOfDispatchQueue) -> TopUpCardViewModel
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
    case buttonTapped(ButtonEvent)
}

