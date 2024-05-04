//
//  PaymentsTransfersViewModel.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 03.05.2024.
//

import ForaTools
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
            self?.state.route.destination = .utilityPrepayment(.init(viewModel: $0, destination: nil))
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
    
    // reduce is not injected due to
    // - complexity of existing `PaymentsTransfersViewModel`
    // - side effects (changes of outside state, like `tab`)
    private func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .utilityFlow(utilityFlow):
            let utilityFlowEffect: Effect.UtilityPaymentFlowEffect?
            (state, utilityFlowEffect) = reduce(state, utilityFlow)
            effect = utilityFlowEffect.map(Effect.utilityFlow)
        }
        
        return (state, effect)
    }
    
    private func reduce(
        _ state: State,
        _ event: Event.UtilityPaymentFlowEvent
    ) -> (State, Effect.UtilityPaymentFlowEffect?) {
        
        var state = state
        var effect: Effect.UtilityPaymentFlowEffect?
        
        switch event {
        case let .prepayment(prepayment):
            let prepaymentEffect: Effect.UtilityPaymentFlowEffect.UtilityPrepaymentFlowEffect?
            (state, prepaymentEffect) = reduce(state, prepayment)
            effect = prepaymentEffect.map(Effect.UtilityPaymentFlowEffect.prepayment)
        }
        
        return (state, effect)
    }
    
    private func reduce(
        _ state: State,
        _ event: Event.UtilityPaymentFlowEvent.UtilityPrepaymentFlowEvent
    ) -> (State, Effect.UtilityPaymentFlowEffect.UtilityPrepaymentFlowEffect?) {
        
        var state = state
        var effect: Effect.UtilityPaymentFlowEffect.UtilityPrepaymentFlowEffect?
        
        switch event {
        case .addCompany:
            state.route.destination = nil
            rootActions.switchTab("chat")
            
        case .dismissDestination:
            state.route.setUtilityPrepaymentDestination(to: nil)
            
        case .payByInstructions:
            state.route.setUtilityPrepaymentDestination(to: .payByInstructions)
            
        case .payByInstructionsFromError:
            state.route.destination = .payByInstructions
            
        case let .paymentStarted(startPaymentResult):
            reduce(&state, startPaymentResult)
            
        case let .select(select):
            effect = .startPayment(with: select)
        }
        
        return (state, effect)
    }
    
    func reduce(
        _ state: inout State,
        _ result: PaymentsTransfersEvent.UtilityPaymentFlowEvent.UtilityPrepaymentFlowEvent.StartPaymentResult
    ) {
        switch result {
        case let .failure(failure):
            switch failure {
            case let .operatorFailure(`operator`):
                state.route.setUtilityPrepaymentDestination(to: .operatorFailure(`operator`))
                
            case let .serviceFailure(serviceFailure):
                state.route.setUtilityPrepaymentDestination(to: .serviceFailure(serviceFailure))
            }
            
        case let .success(success):
            switch success {
            case let .services(services, `operator`):
#warning("set destination of destination!!!")
                state.route.setUtilityPrepaymentDestination(to: .services(services, for: `operator`))
                
            case let .startPayment(response):
                state.route.setUtilityPrepaymentDestination(to: .payment)
            }
        }
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
        case utilityPrepayment(UtilityPrepayment)
    }
    
    enum Modal {}
}

extension PaymentsTransfersViewModel.State.Route.Destination {
    
    struct UtilityPrepayment {
        
        let viewModel: UtilityPrepaymentViewModel
        let destination: Destination?
    }
}

extension PaymentsTransfersViewModel.State.Route.Destination.UtilityPrepayment {
    
    enum Destination {
        
        case operatorFailure(Operator)
        case payByInstructions
        case payment
        case serviceFailure(ServiceFailure)
        case services(MultiElementArray<UtilityService>, for: Operator)
    }
}

// MARK: - Helpers

private extension PaymentsTransfersViewModel.State.Route {
    
    var utilityPrepayment: Destination.UtilityPrepayment? {
        
        guard case let .utilityPrepayment(utilityPrepayment) = destination
        else { return nil }
        
        return utilityPrepayment
    }
    
    var utilityPrepaymentDestination: Destination.UtilityPrepayment.Destination? {
        
        return utilityPrepayment?.destination
    }
    
    mutating func setUtilityPrepaymentDestination(
        to destination: Destination.UtilityPrepayment.Destination?
    ) {
        
        guard let utilityPrepayment else { return }
        
        self.destination = .utilityPrepayment(.init(
            viewModel: utilityPrepayment.viewModel,
            destination: destination
        ))
    }
}
