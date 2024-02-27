//
//  ProductProfileNavigationEffectHandler.swift
//
//
//  Created by Andryusina Nataly on 07.02.2024.
//

import Foundation
import CardGuardianModule
import RxViewModel
import ActivateSlider

public final class ProductProfileNavigationEffectHandler {
    
    public typealias MakeCardGuardianViewModel = CardGuardianFactory.MakeCardGuardianViewModel
    
    public typealias MakeCardViewModel = CardViewFactory.MakeCardViewModel
    
    private let makeCardGuardianViewModel: MakeCardGuardianViewModel
    private let makeCardViewModel: MakeCardViewModel

    private let guardCard: GuardCard
    private let toggleVisibilityOnMain: ToggleVisibilityOnMain
    private let showContacts: ShowContacts
    private let changePin: ChangePin
    
    private let scheduler: AnySchedulerOfDispatchQueue
    
    public init(
        makeCardGuardianViewModel: @escaping MakeCardGuardianViewModel,
        makeCardViewModel: @escaping MakeCardViewModel,
        guardianCard: @escaping GuardCard,
        toggleVisibilityOnMain: @escaping ToggleVisibilityOnMain,
        showContacts: @escaping ShowContacts,
        changePin: @escaping ChangePin,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
        self.makeCardGuardianViewModel = makeCardGuardianViewModel
        self.makeCardViewModel = makeCardViewModel
        self.guardCard = guardianCard
        self.toggleVisibilityOnMain = toggleVisibilityOnMain
        self.showContacts = showContacts
        self.changePin = changePin
        self.scheduler = scheduler
    }
}

public extension ProductProfileNavigationEffectHandler {
    
    func handleEffect(
        _ effect: ProductProfileNavigation.Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case let .delayAlert(alert, timeInterval):
            DispatchQueue.main.asyncAfter(deadline: .now() + timeInterval) {
                
                dispatch(.showAlert(alert))
            }
        case .create:
            dispatch(makeDestination(dispatch))
        case let .productProfile(effect):
            // fire and forget
            handleEffect(effect)
        case let .card(effect):
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
        }
    }
    
    private func handleEffect(
        _ effect: CardEffect
    ) {
        /*switch effect {
      
        case .activate:
            <#code#>
        case let .dismiss(interval):
            <#code#>
        }*/
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

private extension ProductProfileNavigationEffectHandler {
    
    func makeCardDestination(
        _ dispatch: @escaping Dispatch
    ) -> Event {
        
        let cardViewModel = makeCardViewModel(scheduler)
        let cancellable = cardViewModel.$state
            .dropFirst()
            /*.compactMap(\.projection)
            .removeDuplicates()
            .map(Event.cardGuardianInput)*/
            .receive(on: scheduler)
            .sink { _ in /*dispatch($0)*/ }
        
        return .show(.init(cardViewModel, cancellable))
    }
}

public extension ProductProfileNavigationEffectHandler {
    
    typealias Event = ProductProfileNavigation.Event
    typealias Effect = ProductProfileNavigation.Effect
    
    typealias Dispatch = (Event) -> Void
    
    // fire and forget
    typealias GuardCard = (Card) -> Void
    typealias ChangePin = (Card) -> Void
    typealias ToggleVisibilityOnMain = (Product) -> Void
    typealias ShowContacts = () -> Void
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
