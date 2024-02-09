//
//  ProductProfileEffectHandler.swift
//  
//
//  Created by Andryusina Nataly on 07.02.2024.
//

import Foundation
import CardGuardianModule

public final class ProductProfileEffectHandler {
    
    public typealias MakeCardGuardianViewModel = CardGuardianFactory.MakeCardGuardianViewModel

    private let makeCardGuardianViewModel: MakeCardGuardianViewModel
    private let scheduler: AnySchedulerOfDispatchQueue

    public init(
        makeCardGuardianViewModel: @escaping MakeCardGuardianViewModel,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
        self.makeCardGuardianViewModel = makeCardGuardianViewModel
        self.scheduler = scheduler
    }
}

public extension ProductProfileEffectHandler {
    
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
        }
    }
}

private extension ProductProfileEffectHandler {
    
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

public extension ProductProfileEffectHandler {
    
    typealias Event = ProductProfileNavigation.Event
    typealias Effect = ProductProfileNavigation.Effect
    
    typealias Dispatch = (Event) -> Void
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
