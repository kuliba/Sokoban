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
            self?.state.route.destination = .utilityPayment(.init(viewModel: $0))
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

// MARK: - Types

extension PaymentsTransfersViewModel {
    
    struct State {
        
        var route: Route
    }
    
    typealias Event = PaymentsTransfersEvent
    typealias Effect = PaymentsTransfersEffect
    typealias Factory = PaymentsTransfersViewModelFactory
    typealias NavigationStateManager = PaymentsTransfersFlowManager
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
        case utilityPayment(UtilityPaymentFlowState)
    }
    
    enum Modal: Equatable {
        
        case paymentCancelled(expired: Bool)
    }
}

// MARK: -

private extension PaymentsTransfersViewModel {
    
    // reduce is not injected due to
    // - complexity of existing `PaymentsTransfersViewModel`
    // - side effects (changes of outside state, like tab switching)
    private func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case .dismissFullScreenCover:
            state.route.modal = nil
            
        case .goToMain:
            #warning("FIXME")
            state.route = .init()
            print("go to main")
            
        case let .setModal(to: modal):
            state.route.modal = modal
            
        case let .utilityFlow(utilityFlow):
            (state, effect) = reduce(state, utilityFlow)
        }
        
        return (state, effect)
    }
    
    private func reduce(
        _ state: State,
        _ event: UtilityPaymentFlowEvent
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .payment(event):
            (state, effect) = reduce(state, event)
            
        case let .prepayment(prepaymentEvent):
            let prepaymentEffect: UtilityPaymentFlowEffect.UtilityPrepaymentFlowEffect?
            (state, prepaymentEffect) = reduce(state, prepaymentEvent)
           
            if let prepaymentEffect {
                
                effect = .utilityFlow(.prepayment(prepaymentEffect))
            }
            
        case let .servicePicker(servicePickerEvent):
            reduce(&state, servicePickerEvent)
        }
        
        return (state, effect)
    }
    
    private func reduce(
        _ state: State,
        _ event: UtilityServicePaymentFlowEvent
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case .dismissFraud:
            state.route.setPaymentModal(to: nil)
            
        case let .fraud(fraud):
            state.route.setPaymentModal(to: nil)
            
            switch fraud {
            case .cancel:
                state.route.destination = nil
                effect = .delayModalSet(to: .paymentCancelled(expired: false))
                
            case .continue:
                break
                
            case .expire:
                state.route.destination = nil
                effect = .delayModalSet(to: .paymentCancelled(expired: true))
            }
            
        case let .fraudDetected(fraud):
#warning("depends on state - payment could be in 2 places - as a destination of prepayment and as a destination of service picker")
            state.route.setPaymentModal(to: .fraud(fraud))
        }
        
        return (state, effect)
    }
    
    private func reduce(
        _ state: State,
        _ event: UtilityPaymentFlowEvent.UtilityPrepaymentFlowEvent
    ) -> (State, UtilityPaymentFlowEffect.UtilityPrepaymentFlowEffect?) {
        
        var state = state
        var effect: UtilityPaymentFlowEffect.UtilityPrepaymentFlowEffect?
        
        switch event {
        case .addCompany:
            state.route.destination = nil
            rootActions.switchTab("chat")
            
        case .dismissAlert:
            state.route.setUtilityPrepaymentAlert(to: nil)
            
        case .dismissDestination:
            state.route.setUtilityPrepaymentDestination(to: nil)
            
        case .dismissOperatorFailureDestination:
            state.route.setUtilityServiceOperatorFailureDestination(to: nil)
            
        case .dismissServicesDestination:
            state.route.setUtilityServicePickerDestination(to: nil)
            
        case .payByInstructions:
            payByInstructions(&state)
            
        case .payByInstructionsFromError:
            state.route.destination = .payByInstructions
            
        case let .paymentStarted(startPaymentResult):
            reduce(&state, startPaymentResult)
            
        case let .select(select):
            effect = .startPayment(with: select)
        }
        
        return (state, effect)
    }
    
    func payByInstructions(
        _ state: inout State
    ) {
        switch state.route.utilityPrepaymentDestination {
        case .none:
            state.route.setUtilityPrepaymentDestination(to: .payByInstructions)
            
        case .operatorFailure:
            state.route.setUtilityServiceOperatorFailureDestination(to: .payByInstructions)
            
        default:
            break
        }
    }
    
    func reduce(
        _ state: inout State,
        _ result: UtilityPaymentFlowEvent.UtilityPrepaymentFlowEvent.StartPaymentResult
    ) {
        switch result {
        case let .failure(failure):
            switch failure {
            case let .operatorFailure(`operator`):
                state.route.setUtilityPrepaymentDestination(to: .operatorFailure(.init(operator: `operator`)))
                
            case let .serviceFailure(serviceFailure):
                switch state.route.utilityPrepaymentDestination {
                case .none:
                    state.route.setUtilityPrepaymentAlert(to: .serviceFailure(serviceFailure))
                    
                case .servicePicker:
                    state.route.setUtilityServicePickerAlert(to: .serviceFailure(serviceFailure))
                    
                default:
                    break
                }
            }
            
        case let .success(success):
            switch success {
            case let .services(services, `operator`):
                state.route.setUtilityPrepaymentDestination(to: .servicePicker(.init(
                    services: services,
                    operator: `operator`,
                    destination: nil
                )))
                
            case let .startPayment(response):
                let paymentViewModel = factory.makePaymentViewModel(response) { [weak self] in
                    
                    self?.event(.utilityFlow(.payment(.fraudDetected($0))))
                }
        
                switch state.route.utilityPrepaymentDestination {
                case .none:
                    state.route.setUtilityPrepaymentDestination(to: .payment(.init(viewModel: paymentViewModel)))
                    
                case .servicePicker:
                    state.route.setUtilityServicePickerDestination(to: .payment(.init(viewModel: paymentViewModel)))
                    
                default:
                    break
                }
            }
        }
    }
    
    func reduce(
        _ state: inout State,
        _ event: UtilityPaymentFlowEvent.ServicePickerFlowEvent
    ) {
        switch event {
        case .dismissAlert:
            state.route.setUtilityServicePickerAlert(to: nil)
        }
    }
}

// MARK: - Helpers

private extension PaymentsTransfersEffect {
    
    static func delayModalSet(
        to modal: Modal,
        delayFor interval: DispatchTimeInterval = .seconds(1)
    ) -> Self {
        
        .delay(.setModal(to: modal), for: interval)
    }
    
    typealias Modal = PaymentsTransfersViewModel.State.Route.Modal
}

private extension PaymentsTransfersViewModel.State.Route {
    
    var utilityPrepayment: UtilityPaymentFlowState? {
        
        guard case let .utilityPayment(utilityPrepayment) = destination
        else { return nil }
        
        return utilityPrepayment
    }
    
    var utilityPrepaymentDestination: UtilityPaymentFlowState.Destination? {
        
        return utilityPrepayment?.destination
    }
    
    mutating func setUtilityPrepaymentDestination(
        to destination: UtilityPaymentFlowState.Destination?
    ) {
        guard var utilityPrepayment else { return }
        
        utilityPrepayment.destination = destination
        self.destination = .utilityPayment(utilityPrepayment)
    }
    
    mutating func setUtilityPrepaymentAlert(
        to alert: UtilityPaymentFlowState.Alert?
    ) {
        guard var utilityPrepayment else { return }
        
        utilityPrepayment.alert = alert
        self.destination = .utilityPayment(utilityPrepayment)
    }
    
    private var operatorFailure: UtilityPaymentFlowState.Destination.OperatorFailure? {
        
        guard case let .operatorFailure(operatorFailure) = utilityPrepaymentDestination
        else { return nil }
        
        return operatorFailure
    }
    
    mutating func setUtilityServiceOperatorFailureDestination(
        to destination: UtilityPaymentFlowState.Destination.OperatorFailure.Destination?
    ) {
        guard var operatorFailure else { return }
        
        operatorFailure.destination = destination
        self.setUtilityPrepaymentDestination(to: .operatorFailure(operatorFailure))
    }
    
    typealias ServicePickerState = UtilityPaymentFlowState.Destination.ServicePickerState
    
    private var servicePicker: ServicePickerState? {
        
        guard case let .servicePicker(servicePicker) = utilityPrepaymentDestination
        else { return nil }
        
        return servicePicker
    }
    
    mutating func setUtilityServicePickerDestination(
        to destination: ServicePickerState.Destination?
    ) {
        guard var servicePicker else { return }
        
        servicePicker.destination = destination
        self.setUtilityPrepaymentDestination(to: .servicePicker(servicePicker))
    }
    
    mutating func setUtilityServicePickerAlert(
        to alert: ServicePickerState.Alert?
    ) {
        guard var servicePicker else { return }
        
        servicePicker.alert = alert
        self.setUtilityPrepaymentDestination(to: .servicePicker(servicePicker))
    }
    
    private var paymentFlowState: PaymentFlowState? {
        
        guard case let .payment(paymentFlowState) = utilityPrepayment?.destination
        else { return nil }
        
        return paymentFlowState
    }
    
    mutating func setPaymentModal(
        to modal: PaymentFlowState.Modal?
    ) {
        guard var paymentFlowState else { return }
        
        paymentFlowState.modal = modal
        self.setUtilityPrepaymentDestination(to: .payment(paymentFlowState))
    }
}
