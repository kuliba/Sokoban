//
//  PaymentsTransfersFlowReducer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 08.05.2024.
//

import Foundation

final class PaymentsTransfersFlowReducer<LastPayment, Operator, UtilityService, Content, PaymentViewModel> {
    
    private let factory: Factory
    private let notify: Factory.Notify
    private let closeAction: () -> Void
    
    init(
        factory: Factory,
        closeAction: @escaping () -> Void,
        notify: @escaping Factory.Notify
    ) {
        self.factory = factory
        self.closeAction = closeAction
        self.notify = notify
    }
    
    typealias Factory = PaymentsTransfersFlowReducerFactory<LastPayment, Operator, UtilityService, Content, PaymentViewModel>
}

extension PaymentsTransfersFlowReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .dismiss(dismiss):
            reduce(&state, with: dismiss)
            
        case let .outside(outside):
            reduce(&state, with: outside)
            
        case let .paymentButtonTapped(paymentButton):
            (state, effect) = reduce(state, paymentButton)
            
        case let .setModal(to: modal):
            state.modal = modal
            
        case let .utilityFlow(utilityFlow):
            (state, effect) = reduce(state, utilityFlow)
        }
        
        return (state, effect)
    }
    
    typealias State = PaymentsTransfersViewModel._Route<LastPayment, Operator, UtilityService, Content, PaymentViewModel>
    typealias Event = PaymentsTransfersFlowEvent<LastPayment, Operator, UtilityService>
    typealias Effect = PaymentsTransfersFlowEffect<LastPayment, Operator, UtilityService>
}

private extension PaymentsTransfersFlowReducer {
    
    func reduce(
        _ state: inout State,
        with dismiss: Event.Dismiss
    ) {
        switch dismiss {
        case .destination:
            state.destination = nil
            
        case .fullScreenCover:
            state.modal = nil
            
        case .modal:
            state.modal = nil
        }
    }
    
    func reduce(
        _ state: inout State,
        with outside: Event.Outside
    ) {
        switch outside {
        case .addCompany:
            state.outside = .chat
            
        case .goToMain:
            state.outside = .main
        }
    }
    
    private func reduce(
        _ state: State,
        _ button: Event.PaymentButton
    ) -> (State, Effect?) {
        
        var effect: Effect?
        
        switch button {
        case let .utilityService(legacyPayload):
            effect = .utilityFlow(.prepayment(.initiate(legacyPayload)))
        }
        
        return (state, effect)
    }
    
    private typealias UtilityPaymentEvent = UtilityPaymentFlowEvent<LastPayment, Operator, UtilityService>
    private typealias UtilityPaymentEffect = UtilityPaymentFlowEffect<LastPayment, Operator, UtilityService>
    private typealias UtilityPrepaymentEffect = UtilityPaymentEffect.UtilityPrepaymentFlowEffect
    
    private func reduce(
        _ state: State,
        _ event: UtilityPaymentEvent
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .payment(event):
            (state, effect) = reduce(state, event)
            
        case let .prepayment(prepaymentEvent):
            let prepaymentEffect: UtilityPrepaymentEffect?
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
        case .dismiss(.fraud):
            state.setPaymentModal(to: nil)
            
        case .dismiss(.fullScreenCover):
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
        with projection: PaymentStateProjection
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
    
    private typealias UtilityPrepaymentFlowEvent = UtilityPaymentFlowEvent<LastPayment, Operator, UtilityService>.UtilityPrepaymentFlowEvent
    private typealias UtilityPrepaymentFlowEffect = UtilityPaymentFlowEffect<LastPayment, Operator, UtilityService>.UtilityPrepaymentFlowEffect
    
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
            
        case let .initiated(initiated):
            reduce(&state, with: initiated)
            
        case .payByInstructions:
            payByInstructions(&state)
            
        case .payByInstructionsFromError:
            state.destination = .payments(factory.makePaymentsViewModel(closeAction))
            
        case let .paymentStarted(paymentStarted):
            reduce(&state, with: paymentStarted)
            
        case let .select(select):
            effect = .startPayment(with: select)
        }
        
        return (state, effect)
    }
    
    private func reduce(
        _ state: inout State,
        with initiated: UtilityPrepaymentFlowEvent.Initiated
    ) {
        switch initiated {
        case let .legacy(paymentsServicesViewModel):
            state.destination = .paymentsServices(paymentsServicesViewModel)
            
        case let .v1(payload):
            let utilityPrepaymentState = factory.makeUtilityPrepaymentState(payload)
            state.destination = .utilityPayment(utilityPrepaymentState)
        }
    }
    
    private func payByInstructions(
        _ state: inout State
    ) {
        let viewModel = factory.makePaymentsViewModel(closeAction)
        
        switch state.utilityPrepaymentDestination {
        case .none:
            state.setUtilityPrepaymentDestination(to: .payByInstructions(viewModel))
            
        case .operatorFailure:
            state.setUtilityServiceOperatorFailureDestination(to: .payByInstructions(viewModel))
            
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
#warning("extract helper")
            let alert: ServiceFailureAlert = {
                switch serviceFailure {
                case .connectivityError:
                    return .init(serviceFailure: .connectivityError)
                    
                case let .serverError(message):
                    return .init(serviceFailure: .serverError(message))
                }
            }()
            
            switch state.utilityPrepaymentDestination {
            case .none:
                state.setUtilityPrepaymentAlert(to: alert)
                
            case .servicePicker:
                state.setUtilityServicePickerAlert(to: alert)
                
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
            
        case let .startPayment(transactionState):
            reduce(&state, with: transactionState)
        }
    }
    
    private func reduce(
        _ state: inout State,
        with transactionState: AnywayTransactionState
    ) {
        let utilityPaymentState = factory.makeUtilityPaymentState(transactionState, notify)
        
        switch state.utilityPrepaymentDestination {
        case .none:
            state.setUtilityPrepaymentDestination(to: .payment(utilityPaymentState))
            
        case .servicePicker:
            state.setUtilityServicePickerDestination(to: .payment(utilityPaymentState))
            
        default:
            break
        }
    }
    
    private func reduce(
        _ state: inout State,
        _ event: UtilityPaymentEvent.ServicePickerFlowEvent
    ) {
        switch event {
        case .dismissAlert:
            state.setUtilityServicePickerAlert(to: nil)
        }
    }
}

// MARK: - Helpers

private extension PaymentsTransfersViewModel.Modal {
    
    static func paymentCancelled(
        expired: Bool
    ) -> Self {
        
        .fullScreenSheet(.init(
            type: .paymentCancelled(expired: expired)
        ))
    }
}

private extension PaymentsTransfersFlowEffect {
    
    static func delayModalSet(
        to modal: Modal,
        delayFor interval: DispatchTimeInterval = .seconds(1)
    ) -> Self {
        
        .delay(.setModal(to: modal), for: interval)
    }
    
    typealias Modal = PaymentsTransfersViewModel.Modal
}

private extension PaymentsTransfersViewModel._Route {
    
    typealias UtilityFlowState = UtilityPaymentFlowState<Operator, UtilityService, Content, PaymentViewModel>
    
    var utilityPrepayment: UtilityFlowState? {
        
        guard case let .utilityPayment(utilityPrepayment) = destination
        else { return nil }
        
        return utilityPrepayment
    }
    
    var utilityPrepaymentDestination: UtilityFlowState.Destination? {
        
        return utilityPrepayment?.destination
    }
    
    mutating func setUtilityPrepaymentDestination(
        to destination: UtilityFlowState.Destination?
    ) {
        guard var utilityPrepayment else { return }
        
        utilityPrepayment.destination = destination
        self.destination = .utilityPayment(utilityPrepayment)
    }
    
    mutating func setUtilityPrepaymentAlert(
        to alert: UtilityFlowState.Alert?
    ) {
        guard var utilityPrepayment else { return }
        
        utilityPrepayment.alert = alert
        self.destination = .utilityPayment(utilityPrepayment)
    }
    
    typealias OperatorFailure = SberOperatorFailureFlowState<Operator>
    
    private var operatorFailure: OperatorFailure? {
        
        guard case let .operatorFailure(operatorFailure) = utilityPrepaymentDestination
        else { return nil }
        
        return operatorFailure
    }
    
    mutating func setUtilityServiceOperatorFailureDestination(
        to destination: OperatorFailure.Destination?
    ) {
        guard var operatorFailure else { return }
        
        operatorFailure.destination = destination
        self.setUtilityPrepaymentDestination(to: .operatorFailure(operatorFailure))
    }
    
    typealias ServicePickerState = UtilityServicePickerFlowState<Operator, UtilityService, PaymentViewModel>
    
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
    
    typealias UtilityServiceFlowState = UtilityServicePaymentFlowState<PaymentViewModel>
    
    private var paymentFlowState: UtilityServiceFlowState? {
        
        guard case let .payment(paymentFlowState) = utilityPrepayment?.destination
        else { return nil }
        
        return paymentFlowState
    }
    
    mutating func setPaymentAlert(
        to alert: UtilityServiceFlowState.Alert?
    ) {
        // try to change payment node in the tree if found
        // in prepayment destination
        setPrepaymentPaymentAlert(to: alert)
        // or in servicePicker destination
        setServicePickerPaymentAlert(to: alert)
    }
    
    mutating func setFullScreenCover(
        to fullScreenCover: UtilityServiceFlowState.FullScreenCover?
    ) {
        // try to change payment node in the tree if found
        // in prepayment destination
        setPrepaymentPaymentFullScreenCover(to: fullScreenCover)
        // or in servicePicker destination
        setServicePickerPaymentFullScreenCover(to: fullScreenCover)
    }
    
    mutating func setPaymentModal(
        to modal: UtilityServiceFlowState.Modal?
    ) {
        // try to change payment node in the tree if found
        // in prepayment destination
        setPrepaymentPaymentModal(to: modal)
        // or in servicePicker destination
        setServicePickerPaymentModal(to: modal)
    }
    
    private mutating func setPrepaymentPaymentAlert(
        to alert: UtilityServiceFlowState.Alert?
    ) {
        guard var paymentFlowState else { return }
        
        paymentFlowState.alert = alert
        self.setUtilityPrepaymentDestination(to: .payment(paymentFlowState))
    }
    
    private mutating func setPrepaymentPaymentFullScreenCover(
        to fullScreenCover: UtilityServiceFlowState.FullScreenCover?
    ) {
        guard var paymentFlowState else { return }
        
        paymentFlowState.fullScreenCover = fullScreenCover
        self.setUtilityPrepaymentDestination(to: .payment(paymentFlowState))
    }
    
    private mutating func setPrepaymentPaymentModal(
        to modal: UtilityServiceFlowState.Modal?
    ) {
        guard var paymentFlowState else { return }
        
        paymentFlowState.modal = modal
        self.setUtilityPrepaymentDestination(to: .payment(paymentFlowState))
    }
    
    private mutating func setServicePickerPaymentAlert(
        to alert: UtilityServiceFlowState.Alert?
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
        to fullScreenCover: UtilityServiceFlowState.FullScreenCover?
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
        to modal: UtilityServiceFlowState.Modal?
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
