//
//  ProductProfileViewModel.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 02.02.2024.
//

import Foundation
import Combine
import CombineSchedulers
import UIPrimitives
import CardGuardianModule
import ProductProfile

final class ProductProfileViewModel: ObservableObject {
    
    @Published private(set) var state: ProductProfileNavigation.State
    
    private let navigationStateManager: ProductProfileNavigationStateManager
    
    private let stateSubject = PassthroughSubject<ProductProfileNavigation.State, Never>()
    private let scheduler: AnySchedulerOfDispatchQueue
    
    init(
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

extension ProductProfileViewModel {
    
    enum State: Equatable {
        
        case initial
        case openPanel
        case toggleLock
        case changePin
        case showOnMain
    }
}

struct ProductProfileNavigationStateManager {
    
    typealias Dispatch = (ProductProfileNavigation.Event) -> Void

    typealias Reduce = (ProductProfileNavigation.State, ProductProfileNavigation.Event, @escaping Dispatch) -> (ProductProfileNavigation.State, ProductProfileNavigation.Effect?)

    let reduce: Reduce
    let makeCardGuardianViewModel: MakeCardGuardianViewModel
    
    init(
        reduce: @escaping Reduce,
        makeCardGuardianViewModel: @escaping MakeCardGuardianViewModel
    ) {
        self.reduce = reduce
        self.makeCardGuardianViewModel = makeCardGuardianViewModel
    }
}

// MARK: - CardGuardian

extension ProductProfileViewModel {
    
    func openCardGuardian(){
        
        let cardGuardianViewModel = navigationStateManager.makeCardGuardianViewModel(scheduler)
        let cancellable = cardGuardianViewModel.$state
            .removeDuplicates()
            .receive(on: scheduler)
            .sink { [weak self] _ in self?.event(.openCardGuardianPanel) }
        
            state.destination = .init(cardGuardianViewModel, cancellable)
        cardGuardianViewModel.event(.appear)
    }
}

// MARK: - Types

extension ProductProfileNavigationStateManager {
    
    typealias MakeCardGuardianViewModel = (AnySchedulerOfDispatchQueue) -> CardGuardianViewModel
}

// MARK: - Types

extension ProductProfileViewModel {
    
    func event(_ event: ProductProfileNavigation.Event) {
        
        let (state, effect) = navigationStateManager.reduce(state, event, self.event(_:))
        stateSubject.send(state)
        
        if let effect {
            
            handleEffect(effect)
        }
    }
    
    private func handleEffect(_ effect: ProductProfileNavigation.Effect) {
        
        switch effect {
        case let .cardGuardian(event):
            cardGardianDispatch?(event)
        }
    }
    
    private var cardGardianDispatch: ((CardGuardianEvent) -> Void)? {
        
        cardGardianViewModel?.event(_:)
    }
    
    private var cardGardianViewModel: CardGuardianViewModel? {
        
        guard let route = state.destination
        else { return nil }
        
        return route.viewModel
    }
}

