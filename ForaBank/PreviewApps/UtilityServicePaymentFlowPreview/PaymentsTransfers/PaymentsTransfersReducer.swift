//
//  PaymentsTransfersReducer.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 06.05.2024.
//

import Foundation

final class PaymentsTransfersReducer {
    
    private let factory: Factory
    private let notify: Factory.Notify
    
    init(
        factory: Factory,
        notify: @escaping Factory.Notify
    ) {
        self.factory = factory
        self.notify = notify
    }
}

extension PaymentsTransfersReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case .dismissFullScreenCover:
            state.modal = nil
            
        case .goToMain:
            state.outside = .main
            
        case let .paymentButtonTapped(paymentButton):
            (state, effect) = reduce(state, paymentButton)
            
        case let .setModal(to: modal):
            state.modal = modal
            
        case let .utilityFlow(utilityFlow):
            (state, effect) = reduce(state, utilityFlow)
        }
        
        return (state, effect)
    }
}

extension PaymentsTransfersReducer {
    
    typealias Factory = PaymentsTransfersReducerFactory
    
    typealias State = PaymentsTransfersViewModel.Route
    typealias Event = PaymentsTransfersEvent
    typealias Effect = PaymentsTransfersEffect
}

private extension PaymentsTransfersReducer {
    
    private func reduce(
        _ state: State,
        _ button: Event.PaymentButton
    ) -> (State, Effect?) {
        
        var effect: Effect?
        
        switch button {
        case .utilityService:
            effect = .utilityFlow(.prepayment(.initiate))
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
            state.setPaymentModal(to: nil)
            
        case .dismissFullScreenCover:
            state.setFullScreenCover(to: nil)
            
        case .dismissPaymentError:
            state.destination = nil
            
        case let .fraud(fraudEvent):
            (state, effect) = reduce(state, fraudEvent)
            
        case let .notified(projection):
            reduce(&state, with: projection)
        }
        
        return (state, effect)
    }
    
    private func reduce(
        _ state: State,
        _ event: FraudEvent
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        state.setPaymentModal(to: nil)
        
        switch event {
        case .cancel:
            state.destination = nil
            effect = .delayModalSet(to: .paymentCancelled(expired: false))
            
        case .continue:
            break
            
        case .expire:
            state.destination = nil
            effect = .delayModalSet(to: .paymentCancelled(expired: true))
        }
        
        return (state, effect)
    }
    
    private func reduce(
        _ state: inout State,
        with projection: UtilityServicePaymentFlowEvent.PaymentStateProjection
    ) {
        switch projection {
        case .completed:
            state.setFullScreenCover(to: .completed)
            
        case let .errorMessage(errorMessage):
            state.setPaymentAlert(to: .terminalError(errorMessage))
            
        case let .fraud(fraud):
            state.setPaymentModal(to: .fraud(fraud))
        }
    }
    
    private typealias UtilityPrepaymentFlowEvent = UtilityPaymentFlowEvent.UtilityPrepaymentFlowEvent
    private typealias UtilityPrepaymentFlowEffect = UtilityPaymentFlowEffect.UtilityPrepaymentFlowEffect
    
    private func reduce(
        _ state: State,
        _ event: UtilityPrepaymentFlowEvent
    ) -> (State, UtilityPrepaymentFlowEffect?) {
        
        var state = state
        var effect: UtilityPrepaymentFlowEffect?
        
        switch event {
        case .addCompany:
            state.outside = .chat
            
        case .dismissAlert:
            state.setUtilityPrepaymentAlert(to: nil)
            
        case .dismissDestination:
            state.setUtilityPrepaymentDestination(to: nil)
            
        case .dismissOperatorFailureDestination:
            state.setUtilityServiceOperatorFailureDestination(to: nil)
            
        case .dismissServicesDestination:
            state.setUtilityServicePickerDestination(to: nil)
            
        case let .initiated(payload):
            let viewModel = factory.makeUtilityPrepaymentViewModel(payload)
            state.destination = .utilityPayment(.init(viewModel: viewModel))
            
        case .payByInstructions:
            payByInstructions(&state)
            
        case .payByInstructionsFromError:
            state.destination = .payByInstructions
            
        case let .paymentStarted(startPaymentResult):
            reduce(&state, with: startPaymentResult)
            
        case let .select(select):
            effect = .startPayment(with: select)
        }
        
        return (state, effect)
    }
    
    private func payByInstructions(
        _ state: inout State
    ) {
        switch state.utilityPrepaymentDestination {
        case .none:
            state.setUtilityPrepaymentDestination(to: .payByInstructions)
            
        case .operatorFailure:
            state.setUtilityServiceOperatorFailureDestination(to: .payByInstructions)
            
        default:
            break
        }
    }
    
    private func reduce(
        _ state: inout State,
        with result: UtilityPrepaymentFlowEvent.StartPaymentResult
    ) {
        switch result {
        case let .failure(failure):
            reduce(&state, with: failure)
            
        case let .success(success):
            reduce(&state, with: success)
        }
    }
    
    private func reduce(
        _ state: inout State,
        with failure: UtilityPrepaymentFlowEvent.StartPaymentFailure
    ) {
        switch failure {
        case let .operatorFailure(`operator`):
            state.setUtilityPrepaymentDestination(to: .operatorFailure(.init(content: `operator`)))
            
        case let .serviceFailure(serviceFailure):
            switch state.utilityPrepaymentDestination {
            case .none:
                state.setUtilityPrepaymentAlert(to: .serviceFailure(serviceFailure))
                
            case .servicePicker:
                state.setUtilityServicePickerAlert(to: .serviceFailure(serviceFailure))
                
            default:
                break
            }
        }
    }
    
    private func reduce(
        _ state: inout State,
        with success: UtilityPrepaymentFlowEvent.StartPaymentSuccess
    ) {
        switch success {
        case let .services(services, `operator`):
            state.setUtilityPrepaymentDestination(to: .servicePicker(.init(
                content: .init(services: services, operator: `operator`),
                destination: nil
            )))
            
        case let .startPayment(response):
            reduce(&state, with: response)
        }
    }
    
    private typealias StartPaymentResponse = UtilityPrepaymentFlowEvent.StartPaymentSuccess.StartPaymentResponse
    
    private func reduce(
        _ state: inout State,
        with response: StartPaymentResponse
    ) {
        let paymentViewModel = factory.makePaymentViewModel(response, notify)
        
        switch state.utilityPrepaymentDestination {
        case .none:
            state.setUtilityPrepaymentDestination(to: .payment(.init(viewModel: paymentViewModel)))
            
        case .servicePicker:
            state.setUtilityServicePickerDestination(to: .payment(.init(viewModel: paymentViewModel)))
            
        default:
            break
        }
    }
    
    private func reduce(
        _ state: inout State,
        _ event: UtilityPaymentFlowEvent.ServicePickerFlowEvent
    ) {
        switch event {
        case .dismissAlert:
            state.setUtilityServicePickerAlert(to: nil)
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
    
    typealias Modal = PaymentsTransfersViewModel.Route.Modal
}

private extension PaymentsTransfersViewModel.Route {
    
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
    
    private var operatorFailure: UtilityPaymentFlowState.Destination.OperatorFailureFlowState? {
        
        guard case let .operatorFailure(operatorFailure) = utilityPrepaymentDestination
        else { return nil }
        
        return operatorFailure
    }
    
    mutating func setUtilityServiceOperatorFailureDestination(
        to destination: UtilityPaymentFlowState.Destination.OperatorFailureFlowState.Destination?
    ) {
        guard var operatorFailure else { return }
        
        operatorFailure.destination = destination
        self.setUtilityPrepaymentDestination(to: .operatorFailure(operatorFailure))
    }
    
    typealias ServicePickerState = UtilityPaymentFlowState.Destination.ServicePickerFlowState
    
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
    
    private var paymentFlowState: UtilityServicePaymentFlowState? {
        
        guard case let .payment(paymentFlowState) = utilityPrepayment?.destination
        else { return nil }
        
        return paymentFlowState
    }
    
    mutating func setPaymentAlert(
        to alert: UtilityServicePaymentFlowState.Alert?
    ) {
        // try to change payment node in the tree if found
        // in prepayment destination
        setPrepaymentPaymentAlert(to: alert)
        // or in servicePicker destination
        setServicePickerPaymentAlert(to: alert)
    }
    
    mutating func setFullScreenCover(
        to fullScreenCover: UtilityServicePaymentFlowState.FullScreenCover?
    ) {
        // try to change payment node in the tree if found
        // in prepayment destination
        setPrepaymentPaymentFullScreenCover(to: fullScreenCover)
        // or in servicePicker destination
        setServicePickerPaymentFullScreenCover(to: fullScreenCover)
    }
    
    mutating func setPaymentModal(
        to modal: UtilityServicePaymentFlowState.Modal?
    ) {
        // try to change payment node in the tree if found
        // in prepayment destination
        setPrepaymentPaymentModal(to: modal)
        // or in servicePicker destination
        setServicePickerPaymentModal(to: modal)
    }
    
    private mutating func setPrepaymentPaymentAlert(
        to alert: UtilityServicePaymentFlowState.Alert?
    ) {
        guard var paymentFlowState else { return }
        
        paymentFlowState.alert = alert
        self.setUtilityPrepaymentDestination(to: .payment(paymentFlowState))
    }
    
    private mutating func setPrepaymentPaymentFullScreenCover(
        to fullScreenCover: UtilityServicePaymentFlowState.FullScreenCover?
    ) {
        guard var paymentFlowState else { return }
        
        paymentFlowState.fullScreenCover = fullScreenCover
        self.setUtilityPrepaymentDestination(to: .payment(paymentFlowState))
    }
    
    private mutating func setPrepaymentPaymentModal(
        to modal: UtilityServicePaymentFlowState.Modal?
    ) {
        guard var paymentFlowState else { return }
        
        paymentFlowState.modal = modal
        self.setUtilityPrepaymentDestination(to: .payment(paymentFlowState))
    }
    
    private mutating func setServicePickerPaymentAlert(
        to alert: UtilityServicePaymentFlowState.Alert?
    ) {
        guard case var .utilityPayment(utilityPrepayment) = destination,
              case var .servicePicker(servicePicker) = utilityPrepayment.destination,
              case var .payment(paymentFlowState) = servicePicker.destination
        else { return }
        
        paymentFlowState.alert = alert
        servicePicker.destination = .payment(paymentFlowState)
        utilityPrepayment.destination = .servicePicker(servicePicker)
        destination = .utilityPayment(utilityPrepayment)
    }
    
    private mutating func setServicePickerPaymentFullScreenCover(
        to fullScreenCover: UtilityServicePaymentFlowState.FullScreenCover?
    ) {
        guard case var .utilityPayment(utilityPrepayment) = destination,
              case var .servicePicker(servicePicker) = utilityPrepayment.destination,
              case var .payment(paymentFlowState) = servicePicker.destination
        else { return }
        
        paymentFlowState.fullScreenCover = fullScreenCover
        servicePicker.destination = .payment(paymentFlowState)
        utilityPrepayment.destination = .servicePicker(servicePicker)
        destination = .utilityPayment(utilityPrepayment)
    }
    
    private mutating func setServicePickerPaymentModal(
        to modal: UtilityServicePaymentFlowState.Modal?
    ) {
        guard case var .utilityPayment(utilityPrepayment) = destination,
              case var .servicePicker(servicePicker) = utilityPrepayment.destination,
              case var .payment(paymentFlowState) = servicePicker.destination
        else { return }
        
        paymentFlowState.modal = modal
        servicePicker.destination = .payment(paymentFlowState)
        utilityPrepayment.destination = .servicePicker(servicePicker)
        destination = .utilityPayment(utilityPrepayment)
    }
}
