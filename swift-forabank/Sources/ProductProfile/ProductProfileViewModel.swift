//
//  ProductProfileViewModel.swift
//  
//
//  Created by Andryusina Nataly on 06.02.2024.
//

import Foundation
import Combine
import CombineSchedulers
import UIPrimitives
import CardGuardianModule

public final class ProductProfileViewModel: ObservableObject {
    
    @Published public private(set) var state: ProductProfileNavigation.State
    
    private let navigationStateManager: ProductProfileNavigationStateManager
    
    private let stateSubject = PassthroughSubject<ProductProfileNavigation.State, Never>()
    private let scheduler: AnySchedulerOfDispatchQueue
        
    public init(
        initialState: ProductProfileNavigation.State,
        navigationStateManager: ProductProfileNavigationStateManager,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
        self.state = initialState
        self.navigationStateManager = navigationStateManager
        self.scheduler = scheduler
        
        stateSubject
            .removeDuplicates()
            .receive(on: scheduler)
            .assign(to: &$state)
    }
}

public extension ProductProfileViewModel {
    
    enum State: Equatable {
        
        case initial
        case openPanel
        case toggleLock
        case changePin
        case showOnMain
    }
}

public struct ProductProfileNavigationStateManager {
    
    let reduce: Reduce
   ///let handlerEffect: ....
    let makeCardGuardianViewModel: MakeCardGuardianViewModel
    
    public init(
        reduce: @escaping Reduce,
        makeCardGuardianViewModel: @escaping MakeCardGuardianViewModel
    ) {
        self.reduce = reduce
        self.makeCardGuardianViewModel = makeCardGuardianViewModel
    }
}

public extension ProductProfileNavigationStateManager {
    
    typealias State = ProductProfileNavigation.State
    typealias Event = ProductProfileNavigation.Event
    typealias Effect = ProductProfileNavigation.Effect
    
    typealias Reduce = (State, Event) -> (State, Effect?)
}

// MARK: - CardGuardian

public extension ProductProfileViewModel {
    
    func openCardGuardian(){
        
        let cardGuardianViewModel = navigationStateManager.makeCardGuardianViewModel(scheduler)
        let cancellable = cardGuardianViewModel.$state
            .map(\.event)
            .removeDuplicates()
            .receive(on: scheduler)
            .sink { [weak self] event in
                // self?.event(.cardCuardian(event))
                switch event { // убрать
                    
                case .none:
                    self?.event(.dismissDestination)
                    
                case .appear:
                    self?.event(.openCardGuardianPanel)
                    
                case let .buttonTapped(tap):
                    switch tap {
                        
                    case let .toggleLock(status):
                        self?.event(.showAlertCardGuardian(status))
                        
                    case .changePin:
                        self?.event(.showAlertChangePin)
                        
                    case .showOnMain:
                        self?.event(.dismissDestination)
                    }
                }
            }
        
        state.modal = .init(cardGuardianViewModel, cancellable)
        cardGuardianViewModel.event(.appear)
    }
}

// MARK: - Types

public extension ProductProfileNavigationStateManager {
    
    typealias MakeCardGuardianViewModel = (AnySchedulerOfDispatchQueue) -> CardGuardianViewModel
}

extension ProductProfileViewModel {
    
    public func event(
        _ event: ProductProfileNavigation.Event
    ) {
        
        let (state, effect) = navigationStateManager.reduce(state, event)
        stateSubject.send(state)
        
        if let effect {
            
            handleEffect(effect) { [weak self] in
                self?.event($0)
            }
        }
    }
    
    private func handleEffect(
        _ effect: ProductProfileNavigation.Effect,
        _ dispact: @escaping (ProductProfileNavigation.Event) -> Void
    ) {
        
        switch effect {
        case let .delayAlert(alert):
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                
                dispact(.showAlert(alert))
            }
        }
    }
}
