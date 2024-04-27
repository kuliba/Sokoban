//
//  PaymentsViewModel.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 24.04.2024.
//

import Combine
import CombineSchedulers
import Foundation

// named `Action` to preserve consistency with the App
enum RootAction {
    
    case spinner(SpinnerEvent)
    case tab(TabEvent)
}

extension RootAction {
    
    enum SpinnerEvent {
        
        case hide, show
    }
    
    enum TabEvent {
        
        case chat, main
    }
}

final class PaymentsViewModel: ObservableObject {
    
    @Published private(set) var state: State
    
    private let stateSubject = PassthroughSubject<State, Never>()
    
    private let paymentsManager: PaymentsManager
    private let rootActions: (RootAction) -> Void
    
    init(
        initialState: State,
        paymentsManager: PaymentsManager,
        rootActions: @escaping (RootAction) -> Void,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.state = initialState
        self.paymentsManager = paymentsManager
        self.rootActions = rootActions
        
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
        
        handle(state)
        rootActions(.spinner(effect == nil ? .hide: .show))
        
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

private extension PaymentsViewModel {
    
    // handle non-reducible states with side effects
    func handle(
        _ state: State
    ) {
        switch state.destination {
        case let .utilityService(.prepayment(prepayment)):
            if let complete = prepayment.complete {
                handle(complete)
            }
            
        default:
            break
        }
    }
    
    private func handle(
        _ complete: UtilityServicePrepaymentState.Complete
    ) {
        switch complete {
        case .addingCompany:
            event(.dismissDestination)
            rootAction(.tab(.chat))
            
        case .payingByInstructions:
            fatalError()
            
        case let .selected(selected):
            fatalError(String(describing: selected))
        }
    }
    
    private func rootAction(
        _ action: RootAction
    ) {
        DispatchQueue.main.asyncAfter(
            deadline: .now() + 0.1,
            execute: { [weak self] in self?.rootActions(action) }
        )
    }
}
