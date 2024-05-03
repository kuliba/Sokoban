//
//  PaymentsTransfersViewModel.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 03.05.2024.
//

import Foundation

final class PaymentsTransfersViewModel: ObservableObject {
    
    @Published private(set) var state: State
    
    private let factory: Factory
    private let navigationStateManager: NavigationStateManager
    private let rootActions: RootActions
    
    init(
        state: State,
        factory: Factory,
        navigationStateManager: NavigationStateManager,
        rootActions: RootActions
    ) {
        self.state = state
        self.factory = factory
        self.navigationStateManager = navigationStateManager
        self.rootActions = rootActions
    }
}

extension PaymentsTransfersViewModel {
    
    func openUtilityPayment() {
        
        rootActions.spinner.show()
        
        factory.makeUtilityPrepaymentViewModel { [weak self] in
            
            self?.rootActions.spinner.hide()
            self?.state.route.destination = .utilityFlow(.init(viewModel: $0, destination: nil))
        }
    }
    
    func resetDestination() {
        
        state.route.destination = nil
    }
    
    func event(_ event: Event) {
        
        let (state, effect) = reduce(state, event)
        // routeSubject.send(state)
        DispatchQueue.main.async { [weak self] in self?.state = state }
        
        if let effect {
            
            rootActions.spinner.show()
            
            navigationStateManager.handleEffect(effect) { [weak self] in
                
                self?.rootActions.spinner.hide()
                self?.event($0)
            }
        }
    }
}

private extension PaymentsTransfersViewModel {
    
    // reduce is not injected due to complexity of existing PaymentsTransfersViewModel
    private func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .utilityFlow(utilityFlow):
            (state, effect) = reduce(state, utilityFlow)
        }
        
        return (state, effect)
    }
    
    private func reduce(
        _ state: State,
        _ event: Event.UtilityPaymentFlowEvent
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .prepayment(prepayment):
            (state, effect) = reduce(state, prepayment)
        }
        
        return (state, effect)
    }
    
    private func reduce(
        _ state: State,
        _ event: Event.UtilityPaymentFlowEvent.UtilityPrepaymentFlowEvent
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case .addCompany:
            state.route.destination = nil
            rootActions.switchTab("chat")
            
        case .dismissDestination:
            #warning("add helper to set prepayment destination")
            guard case let .utilityFlow(utilityFlow) = state.route.destination
            else { break }
            state.route.destination = .utilityFlow(.init(viewModel: utilityFlow.viewModel, destination: nil))
            
        case let .loaded(loaded):
            #warning("FIXME")
            print(loaded)
            
        case .payByInstructions:
            #warning("add helper to set prepayment destination")
            guard case let .utilityFlow(utilityFlow) = state.route.destination
            else { break }
            state.route.destination = .utilityFlow(.init(viewModel: utilityFlow.viewModel, destination: .payByInstructions))
            
        case .payByInstructionsFromError:
            state.route.destination = .payByInstructions
            
        case let .select(select):
            effect = .utilityFlow(.prepayment(.select(select)))
        }
        
        return (state, effect)
    }
}

// MARK: - Types

extension PaymentsTransfersViewModel {
    
    typealias Event = PaymentsTransfersEvent
    typealias Effect = PaymentsTransfersEffect
    typealias Factory = PaymentsTransfersViewModelFactory
    typealias NavigationStateManager = PaymentsTransfersFlowManager
    
    struct State {
        
        var route: Route
    }
}

extension PaymentsTransfersViewModel.State {
    
    struct Route {
        
        var destination: Destination?
        var modal: Modal?
    }
}

extension PaymentsTransfersViewModel.State.Route {
    
    enum Destination {
        
        case payByInstructions
        case utilityFlow(UtilityFlow)
    }
    
    enum Modal {}
}

extension PaymentsTransfersViewModel.State.Route.Destination {
    
    struct UtilityFlow {
        
        let viewModel: UtilityPrepaymentViewModel
        let destination: Destination?
    }
}

extension PaymentsTransfersViewModel.State.Route.Destination.UtilityFlow {
    
    enum Destination {
        
        case payByInstructions
    }
}
