//
//  PaymentsTransfersFlowReducer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 08.05.2024.
//

import AnywayPaymentDomain
import Foundation

final class PaymentsTransfersFlowReducer<LastPayment, Operator, Service, Content, PaymentViewModel> {
    
    private let handlePaymentTriggerEvent: HandlePaymentTriggerEvent
    private let factory: Factory
    private let notify: Factory.Notify
    private let closeAction: () -> Void
    
    init(
        handlePaymentTriggerEvent: @escaping HandlePaymentTriggerEvent,
        factory: Factory,
        closeAction: @escaping () -> Void,
        notify: @escaping Factory.Notify
    ) {
        self.handlePaymentTriggerEvent = handlePaymentTriggerEvent
        self.factory = factory
        self.closeAction = closeAction
        self.notify = notify
    }
    
    typealias Factory = PaymentsTransfersFlowReducerFactory<LastPayment, Operator, Service, Content, PaymentViewModel>
    typealias HandlePaymentTriggerEvent = (PaymentTriggerEvent) -> (PaymentTriggerState)
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
         
        case let .paymentTrigger(event):
            reduce(&state, &effect, with: event)
            
        case let .setModal(to: modal):
            state.modal = modal
            
        case let .utilityFlow(utilityFlow):
            (state, effect) = reduce(state, utilityFlow)
        }
        
        return (state, effect)
    }
    
    typealias State = PaymentsTransfersViewModel._Route<LastPayment, Operator, Service, Content, PaymentViewModel>
    typealias Event = PaymentsTransfersFlowEvent<LastPayment, Operator, Service>
    typealias Effect = PaymentsTransfersFlowEffect<LastPayment, Operator, Service>
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
    
    private typealias UtilityPaymentEvent = UtilityPaymentFlowEvent<LastPayment, Operator, Service>
    private typealias UtilityPrepaymentEffect = UtilityPrepaymentFlowEffect<LastPayment, Operator, Service>
    
    private func reduce(
        _ state: inout State,
        _ effect: inout Effect?,
        with event: PaymentTriggerEvent
    ) {
        switch handlePaymentTriggerEvent(event) {
        case let .legacy(legacy):
            state.legacy = legacy
            
        case .v1:
            return
        }
    }
    
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
        case let .dismiss(dismiss):
            reduce(&state, with: dismiss)
            
        case let .notified(status):
            reduce(&state, &effect, with: status)
            
        case let .showResult(transactionResult):
            switch transactionResult {
            case let .failure(fraud):
                state.setPaymentFullScreenCover(to: .completed(.failure(.init(
                    formattedAmount: fraud.formattedAmount,
                    hasExpired: fraud.hasExpired
                ))))
                
            case let .success(report):
                state.setPaymentFullScreenCover(to: .completed(.success(report)))
            }
        }
        
        return (state, effect)
    }
    
    private func reduce(
        _ state: inout State,
        with dismiss: UtilityServicePaymentFlowEvent.Dismiss
    ) {
        switch dismiss {
        case .fraud:
            state.setPaymentModal(to: nil)
            
        case .fullScreenCover:
            state.setPaymentFullScreenCover(to: nil)
            
        case .paymentError:
            state.destination = nil
        }
    }
    
    private func reduce(
        _ state: inout State,
        _ effect: inout Effect?,
        with status: AnywayTransactionStatus?
    ) {
        switch status {
        case .none:
            state.setPaymentAlert(to: nil)
            state.setPaymentFullScreenCover(to: nil)
            state.setPaymentModal(to: nil)

        case .awaitingPaymentRestartConfirmation:
            state.setPaymentAlert(to: .paymentRestartConfirmation)
            
        case .fraudSuspected:
            if let fraud = factory.makeFraud(state) {
                state.setPaymentModal(to: .fraud(fraud))
            }
            
        case .inflight:
            break
            
        case let .serverError(errorMessage):
            state.setPaymentAlert(to: .serverError(errorMessage))
            
        case let .result(transactionResult):
            reduce(&state, &effect, with: transactionResult)
        }
    }
    
    private func reduce(
        _ state: inout State,
        _ effect: inout Effect?,
        with result: AnywayTransactionStatus.TransactionResult
    ) {
        guard let formattedAmount = factory.getFormattedAmount(state)
        else { return }
        
        switch result {
        case let .failure(terminated):
            switch terminated {
            case let .fraud(fraud):
                state.setPaymentModal(to: nil)
                effect = .delay(
                    .utilityFlow(.payment(.showResult(.failure(.init(
                        formattedAmount: formattedAmount,
                        hasExpired: fraud == .expired
                    ))))),
                    for: .microseconds(300)
                )
                
#warning("the case should have associated string")
            case .transactionFailure:
                state.setPaymentAlert(to: .terminalError("Во время проведения платежа произошла ошибка.\nПопробуйте повторить операцию позже."))
                
#warning("the case should have associated string")
            case .updatePaymentFailure:
                state.setPaymentAlert(to: .serverError("Error"))
            }
            
        case let .success(report):
            state.setPaymentModal(to: nil)
            effect = .delay(
                .utilityFlow(.payment(.showResult(.success(report)))),
                for: .microseconds(300)
            )
        }
    }
    
    private typealias UtilityPrepaymentEvent = UtilityPrepaymentFlowEvent<LastPayment, Operator, Service>
    
    private func reduce(
        _ state: State,
        _ event: UtilityPrepaymentEvent
    ) -> (State, UtilityPrepaymentEffect?) {
        
        var state = state
        var effect: UtilityPrepaymentEffect?
        
        switch event {
        case let .dismiss(dismiss):
            reduce(&state, with: dismiss)
            
        case let .initiated(initiated):
            reduce(&state, with: initiated)
            
        case .outside(.addCompany):
            state.outside = .chat
            
        case .payByInstructions:
            payByInstructions(&state)
            
        case .payByInstructionsFromError:
            state.destination = .payments(factory.makePayByInstructionsViewModel(closeAction))
            
        case let .select(select):
            effect = .select(select)
            
        case let .selectionProcessed(paymentStarted):
            reduce(&state, with: paymentStarted)
        }
        
        return (state, effect)
    }
    
    private func reduce(
        _ state: inout State,
        with dismiss: UtilityPrepaymentEvent.Dismiss
    ) {
        switch dismiss {
        case .alert:
            state.setUtilityPrepaymentAlert(to: nil)
            
        case .destination:
            state.setUtilityPrepaymentDestination(to: nil)
            
        case .operatorFailureDestination:
            state.setUtilityServiceOperatorFailureDestination(to: nil)
            
        case .servicesDestination:
            state.setUtilityServicePickerDestination(to: nil)
        }
    }
    
    private func reduce(
        _ state: inout State,
        with initiated: UtilityPrepaymentEvent.Initiated
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
        let viewModel = factory.makePayByInstructionsViewModel(closeAction)
        
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
        with result: UtilityPrepaymentEvent.ProcessSelectionResult
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
        with failure: UtilityPrepaymentEvent.ProcessSelectionFailure
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
        with success: UtilityPrepaymentEvent.ProcessSelectionSuccess
    ) {
        switch success {
        case let .services(services, `operator`):
            state.setUtilityPrepaymentDestination(to: .servicePicker(.init(
                content: .init(services: services, operator: `operator`),
                destination: nil
            )))
            
        case let .startPayment(transaction):
            reduce(&state, with: transaction)
        }
    }
    
    private func reduce(
        _ state: inout State,
        with transaction: AnywayTransactionState.Transaction
    ) {
        let utilityPaymentState = factory.makeUtilityPaymentState(transaction, notify)
        
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
        
        guard case let .payment(paymentFlowState) = utilityPrepaymentDestination
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
    
    mutating func setPaymentFullScreenCover(
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
