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
import RxViewModel


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
    let handleEffect: HandleEffect
    
    public init(
        reduce: @escaping Reduce,
        handleEffect: @escaping HandleEffect
    ) {
        self.reduce = reduce
        self.handleEffect = handleEffect
    }
}

public extension ProductProfileNavigationStateManager {
    
    typealias State = ProductProfileNavigation.State
    typealias Event = ProductProfileNavigation.Event
    typealias Effect = ProductProfileNavigation.Effect
    typealias Dispatch = (Event) -> Void

    
    typealias Reduce = (State, Event) -> (State, Effect?)
    typealias HandleEffect = (Effect, @escaping Dispatch) -> Void
}

// MARK: - CardGuardian

public extension ProductProfileViewModel {
    
    func openCardGuardian(){
        
        self.event(.create)
    }
}

// MARK: - CVV

public extension ProductProfileViewModel {
    
    func showCvvAlert(){
        
        self.event(.showAlert(Alerts.alertCVV()))
    }
    
    func showAlertIfCardBlocked(){
        
        self.event(.showAlert(Alerts.alertCardBlocked()))
    }
}

// MARK: - Activate card

public extension ProductProfileViewModel {

    func showAlertIfCardNotActivate(
        _ card: Card
    ){
        
        self.event(.showAlert(Alerts.alertCardNotActivate(card: card)))
    }
}

// MARK: - Types

public extension ProductProfileNavigationStateManager {
    
    typealias MakeCardGuardianViewModel = CardGuardianFactory.MakeCardGuardianViewModel
}

extension ProductProfileViewModel {
    
    public func event(
        _ event: ProductProfileNavigation.Event
    ) {
        
        let (state, effect) = navigationStateManager.reduce(state, event)
        stateSubject.send(state)
        
        if let effect {
            
            navigationStateManager.handleEffect(effect) { [weak self] in
                    self?.event($0)
            }
        }
    }
}
