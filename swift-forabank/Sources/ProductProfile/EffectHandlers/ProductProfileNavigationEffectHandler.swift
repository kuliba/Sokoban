//
//  ProductProfileNavigationEffectHandler.swift
//
//
//  Created by Andryusina Nataly on 07.02.2024.
//

import Foundation
import CardGuardianModule
import RxViewModel

public final class ProductProfileNavigationEffectHandler {
    
    public typealias MakeCardGuardianViewModel = CardGuardianFactory.MakeCardGuardianViewModel

    private let makeCardGuardianViewModel: MakeCardGuardianViewModel
    private let blockCard: CardGuardianAction
    private let unblockCard: CardGuardianAction
    private let showOnMain: ShowOnMainAction
    private let hideFromMain: ShowOnMainAction
    private let showContacts: EmptyAction
    private let changePin: CardGuardianAction

    private let scheduler: AnySchedulerOfDispatchQueue

    public init(
        makeCardGuardianViewModel: @escaping MakeCardGuardianViewModel,
        blockCard: @escaping CardGuardianAction,
        unblockCard: @escaping CardGuardianAction,
        showOnMain: @escaping ShowOnMainAction,
        hideFromMain: @escaping ShowOnMainAction,
        showContacts: @escaping EmptyAction,
        changePin: @escaping CardGuardianAction,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
        self.makeCardGuardianViewModel = makeCardGuardianViewModel
        self.blockCard = blockCard
        self.unblockCard = unblockCard
        self.showOnMain = showOnMain
        self.hideFromMain = hideFromMain
        self.showContacts = showContacts
        self.changePin = changePin
        
        self.scheduler = scheduler
    }
}

public extension ProductProfileNavigationEffectHandler {
    
#warning("add tests")
    func handleEffect(
        _ effect: ProductProfileNavigation.Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case let .delayAlert(alert):
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                
                dispatch(.showAlert(alert))
            }
        case .create:
            dispatch(makeDestination(dispatch))
        case let .sendRequest(alertEvent):
            
            switch alertEvent {
                
            case .appear:
                break
            case let .cardGuardian(guardian):
                switch guardian {
                    
                case let .blockCard(card):
                    blockCard(card)
                case let .unblockCard(card):
                    unblockCard(card)
                }
            case let .showOnMain(event):
                switch event {
                    
                case let .showOnMain(product):
                    showOnMain(product)
                case let .hideFromMain(product):
                    hideFromMain(product)
                }
            case let .changePin(card):
                changePin(card)
            case .showContacts:
                showContacts()
            }
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

        return .open(.init(cardGuardianViewModel, cancellable))
    }
}

public extension ProductProfileNavigationEffectHandler {
    
    typealias Event = ProductProfileNavigation.Event
    typealias Effect = ProductProfileNavigation.Effect
    
    typealias Dispatch = (Event) -> Void
    
    typealias CardGuardianAction = (Card) -> Void
    typealias ShowOnMainAction = (Product) -> Void
    typealias EmptyAction = () -> Void
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
