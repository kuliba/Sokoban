//
//  PaymentsViewModel.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 24.04.2024.
//

import Combine
import CombineSchedulers
import Foundation

final class PaymentsViewModel: ObservableObject {
    
    @Published private(set) var state: State
    
    private let stateSubject = PassthroughSubject<State, Never>()
    
    private let paymentsManager: PaymentsManager
    private let rootEvent: (RootEvent) -> Void
    
    init(
        initialState: State,
        paymentsManager: PaymentsManager,
        rootEvent: @escaping (RootEvent) -> Void,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.state = initialState
        self.paymentsManager = paymentsManager
        self.rootEvent = rootEvent
        
        #warning("simplified case, real state is more complex")
        stateSubject
            .removeDuplicates()
            .receive(on: scheduler)
            .assign(to: &$state)
    }
}

extension PaymentsViewModel {
    
    func event(_ event: Event) {
        
        let (state, effect) = paymentsManager.reduce(state, event)
        stateSubject.send(state)
        
        rootEvent(.spinner(effect == nil ? .hide: .show))
        
        if let effect {
            
            paymentsManager.handleEffect(effect) { [weak self] event in
                
                self?.event(event)
            }
        }
    }
}

extension PaymentsViewModel {
    
    typealias Dispatch = (Event) -> Void
    
    #warning("actually more complex state here, PaymentsState is just a part of it (substate) | extract reduce & effectHandler but mind the substate case here! - see commented extension below")
    typealias State = PaymentsState
    typealias Event = PaymentsEvent
    typealias Effect = PaymentsEffect
}
