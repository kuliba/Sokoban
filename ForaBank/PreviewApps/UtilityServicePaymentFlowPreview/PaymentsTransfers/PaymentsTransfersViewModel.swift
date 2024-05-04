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
            self?.state.route.destination = .utilityPrepayment(.init(viewModel: $0))
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
        case let .prepayment(prepaymentEvent):
            let prepaymentEffect: Effect.UtilityPaymentFlowEffect.UtilityPrepaymentFlowEffect?
            (state, prepaymentEffect) = reduce(state, prepaymentEvent)
            effect = prepaymentEffect.map(Effect.UtilityPaymentFlowEffect.prepayment)
            
        case let .servicePicker(servicePickerEvent):
            reduce(&state, servicePickerEvent)
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
        _ result: PaymentsTransfersEvent.UtilityPaymentFlowEvent.UtilityPrepaymentFlowEvent.StartPaymentResult
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
                switch state.route.utilityPrepaymentDestination {
                case .none:
                    state.route.setUtilityPrepaymentDestination(to: .payment(response))
                    
                case .servicePicker:
                    state.route.setUtilityServicePickerDestination(to: .payment(response))
                    
                default:
                    break
                }
            }
        }
    }
    
    func reduce(
        _ state: inout State,
        _ event: Event.UtilityPaymentFlowEvent.ServicePickerFlowEvent
    ) {
        switch event {
        case .dismissAlert:
            state.route.setUtilityServicePickerAlert(to: nil)
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
        var destination: Destination?
        var alert: Alert?
        
        init(
            viewModel: UtilityPrepaymentViewModel,
            destination: Destination? = nil,
            alert: Alert? = nil
        ) {
            self.viewModel = viewModel
            self.destination = destination
            self.alert = alert
        }
    }
}

extension PaymentsTransfersViewModel.State.Route.Destination.UtilityPrepayment {
    
    enum Alert {
        
        case serviceFailure(ServiceFailure)
    }
    
    enum Destination {
        
        case operatorFailure(OperatorFailure)
        case payByInstructions
        case payment(StartPaymentResponse)
        case servicePicker(ServicePickerState)
    }
}

extension PaymentsTransfersViewModel.State.Route.Destination.UtilityPrepayment.Destination {
    
    struct OperatorFailure {
        
        let `operator`: Operator
        var destination: Destination?
        
        init(
            `operator`: Operator,
            destination: Destination? = nil
        ) {
            self.operator = `operator`
            self.destination = destination
        }
    }
    
    struct ServicePickerState {
        
        let services: MultiElementArray<UtilityService>
        let `operator`: Operator
        var destination: Destination?
        var alert: Alert?
        
        init(
            services: MultiElementArray<UtilityService>,
            `operator`: Operator,
            destination: Destination? = nil,
            alert: Alert? = nil
        ) {
            self.services = services
            self.operator = `operator`
            self.destination = destination
            self.alert = alert
        }
    }
    
    typealias StartPaymentResponse = PaymentsTransfersEvent.UtilityPaymentFlowEvent.UtilityPrepaymentFlowEvent.StartPaymentSuccess.StartPaymentResponse
}

extension PaymentsTransfersViewModel.State.Route.Destination.UtilityPrepayment.Destination.OperatorFailure {
    
    enum Destination {
        
        case payByInstructions
    }
}

extension PaymentsTransfersViewModel.State.Route.Destination.UtilityPrepayment.Destination.ServicePickerState {
    
    enum Alert {
        
        case serviceFailure(ServiceFailure)
    }
    
    enum Destination {
        
        case payment(StartPaymentResponse)
    }
}

extension PaymentsTransfersViewModel.State.Route.Destination.UtilityPrepayment.Destination.ServicePickerState.Destination {
    
    typealias StartPaymentResponse = PaymentsTransfersEvent.UtilityPaymentFlowEvent.UtilityPrepaymentFlowEvent.StartPaymentSuccess.StartPaymentResponse
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
        guard var utilityPrepayment else { return }
        
        utilityPrepayment[keyPath: \.destination] = destination
        self.destination = .utilityPrepayment(utilityPrepayment)
    }
    
    mutating func setUtilityPrepaymentAlert(
        to alert: Destination.UtilityPrepayment.Alert?
    ) {
        guard var utilityPrepayment else { return }
        
        utilityPrepayment[keyPath: \.alert] = alert
        self.destination = .utilityPrepayment(utilityPrepayment)
    }
    
    private var operatorFailure: Destination.UtilityPrepayment.Destination.OperatorFailure? {
        
        guard case let .operatorFailure(operatorFailure) = utilityPrepaymentDestination
        else { return nil }
        
        return operatorFailure
    }
    
    mutating func setUtilityServiceOperatorFailureDestination(
        to destination: Destination.UtilityPrepayment.Destination.OperatorFailure.Destination?
    ) {
        guard var operatorFailure else { return }
        
        operatorFailure[keyPath: \.destination] = destination
        self.setUtilityPrepaymentDestination(to: .operatorFailure(operatorFailure))
    }
    
    typealias ServicePickerState = Destination.UtilityPrepayment.Destination.ServicePickerState
    
    private var servicePicker: ServicePickerState? {
        
        guard case let .servicePicker(servicePicker) = utilityPrepaymentDestination
        else { return nil }
        
        return servicePicker
    }
    
    mutating func setUtilityServicePickerDestination(
        to destination: ServicePickerState.Destination?
    ) {
        guard var servicePicker else { return }
        
        servicePicker[keyPath: \.destination] = destination
        self.setUtilityPrepaymentDestination(to: .servicePicker(servicePicker))
    }
    
    mutating func setUtilityServicePickerAlert(
        to alert: ServicePickerState.Alert?
    ) {
        guard var servicePicker else { return }
        
        servicePicker[keyPath: \.alert] = alert
        self.setUtilityPrepaymentDestination(to: .servicePicker(servicePicker))
    }
}
