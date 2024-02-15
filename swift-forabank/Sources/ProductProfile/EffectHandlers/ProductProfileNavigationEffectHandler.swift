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
    private let guardianCard: CardGuardianAction
    private let visibilityOnMain: VisibilityOnMainAction
    private let showContacts: EmptyAction
    private let changePin: CardGuardianAction
    
    private let alertLifespan: TimeInterval
    private let scheduler: AnySchedulerOfDispatchQueue
    
    public init(
        makeCardGuardianViewModel: @escaping MakeCardGuardianViewModel,
        guardianCard: @escaping CardGuardianAction,
        visibilityOnMain: @escaping VisibilityOnMainAction,
        showContacts: @escaping EmptyAction,
        changePin: @escaping CardGuardianAction,
        alertLifespan: TimeInterval = 1,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
        self.makeCardGuardianViewModel = makeCardGuardianViewModel
        self.guardianCard = guardianCard
        self.visibilityOnMain = visibilityOnMain
        self.showContacts = showContacts
        self.changePin = changePin
        self.alertLifespan = alertLifespan
        self.scheduler = scheduler
    }
}

public extension ProductProfileNavigationEffectHandler {
    
    func handleEffect(
        _ effect: ProductProfileNavigation.Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case let .delayAlert(alert):
            DispatchQueue.main.asyncAfter(deadline: .now() + alertLifespan) {
                
                dispatch(.showAlert(alert))
            }
        case .create:
            dispatch(makeDestination(dispatch))
        case let .sendRequest(alertEvent):
            // fire and forget
            handleEffect(alertEvent)
        }
    }
    
    private func handleEffect(
        _ alertEvent: ProductProfileEvent
    ) {
        switch alertEvent {
        case let .cardGuardian(card):
            guardianCard(card)
        case let .visibilityOnMain(product):
            visibilityOnMain(product)
        case let .changePin(card):
            changePin(card)
        case .showContacts:
            showContacts()
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
    typealias VisibilityOnMainAction = (Product) -> Void
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
