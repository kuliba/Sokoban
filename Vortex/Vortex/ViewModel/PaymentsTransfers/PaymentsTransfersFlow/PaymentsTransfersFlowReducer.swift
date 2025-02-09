//
//  PaymentsTransfersFlowReducer.swift
//  Vortex
//
//  Created by Igor Malyarov on 08.05.2024.
//

import AnywayPaymentDomain
import Foundation

final class PaymentsTransfersFlowReducer {
    
    private let handlePaymentTriggerEvent: HandlePaymentTriggerEvent
    private let factory: Factory
    private let notify: Factory.Notify
    private let closeAction: () -> Void
    private let hideKeyboard: () -> Void
    
    init(
        handlePaymentTriggerEvent: @escaping HandlePaymentTriggerEvent,
        factory: Factory,
        closeAction: @escaping () -> Void,
        notify: @escaping Factory.Notify,
        hideKeyboard: @escaping () -> Void
    ) {
        self.handlePaymentTriggerEvent = handlePaymentTriggerEvent
        self.factory = factory
        self.closeAction = closeAction
        self.notify = notify
        self.hideKeyboard = hideKeyboard
    }
    
    typealias Factory = PaymentsTransfersFlowReducerFactory
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
         
        case let .paymentFlow(paymentFlow):
            reduce(&state, &effect, with: paymentFlow)
            
        case let .paymentTrigger(event):
            reduce(&state, &effect, with: event)
            
        case let .setModal(to: modal):
            state.modal = modal
            
        case let .utilityFlow(utilityFlow):
            (state, effect) = reduce(state, utilityFlow)
        }
        
        return (state, effect)
    }
    
    typealias State = PaymentsTransfersViewModel.Route
    typealias Event = PaymentsTransfersFlowEvent<UtilityPaymentLastPayment, UtilityPaymentProvider, UtilityService>
    typealias Effect = PaymentsTransfersFlowEffect<UtilityPaymentLastPayment, UtilityPaymentProvider, UtilityService>
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
    
    private typealias UtilityPaymentEvent = UtilityPaymentFlowEvent<UtilityPaymentLastPayment, UtilityPaymentProvider, UtilityService>
    private typealias UtilityPrepaymentEffect = UtilityPrepaymentFlowEffect<UtilityPaymentLastPayment, UtilityPaymentProvider, UtilityService>
    
    private func reduce(
        _ state: inout State,
        _ effect: inout Effect?,
        with paymentFlow: PaymentFlow
    ) {
        switch paymentFlow {
        case let .service(result):
            switch result {
            case let .failure(serviceFailure):
                reduce(&state, with: serviceFailure)
                
            case let .success(transaction):
                let utilityPaymentState = factory.makeUtilityPaymentState(transaction, notify)
                state.destination = .servicePayment(utilityPaymentState)
            }
        }
    }
    
    private func reduce(
        _ state: inout State,
        with serviceFailure: PaymentFlow.ServiceFailure
    ) {
        guard state.destination == nil else  { return }
        
        let alert: ServiceFailureAlert = {
            switch serviceFailure {
            case .connectivityError:
                return .init(serviceFailure: .connectivityError)
                
            case let .serverError(message):
                return .init(serviceFailure: .serverError(message))
            }
        }()
        
        state.modal = .serviceAlert(alert)
    }
    
    private func reduce(
        _ state: inout State,
        _ effect: inout Effect?,
        with event: PaymentTriggerEvent
    ) {
        switch handlePaymentTriggerEvent(event) {
        case let .legacy(legacy):
            state.legacy = legacy
            
        case .v1:
            switch event {
            case let .latestPayment(latestPayment):
                effect = .initiatePayment(.service(.latestPayment(latestPayment)))
            }
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
                state.setPaymentFullScreenCover(to: .completed(.init(
                    formattedAmount: fraud.formattedAmount, 
                    merchantIcon: state.merchantIcon,
                    result: .failure(.init(hasExpired: fraud.hasExpired)),
                    templateID: state.paymentFlowState?.content.state.transaction.context.outline.payload.templateID
                )))
                
            case let .success(report):
                state.setPaymentFullScreenCover(to: .completed(.init(
                    formattedAmount: factory.getFormattedAmount(state) ?? "",
                    merchantIcon: state.merchantIcon,
                    result: .success(report),
                    templateID: state.paymentFlowState?.content.state.transaction.context.outline.payload.templateID
                )))
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
                
            case let .transactionFailure(message):
                state.setPaymentAlert(to: .terminalError(message))
                
            case let .updatePaymentFailure(message):
                state.setPaymentAlert(to: .serverError(message))
            }
            
        case let .success(report):
            state.setPaymentModal(to: nil)
            effect = .delay(
                .utilityFlow(.payment(.showResult(.success(report)))),
                for: .microseconds(300)
            )
        }
    }
    
    private typealias UtilityPrepaymentEvent = UtilityPrepaymentFlowEvent<UtilityPaymentLastPayment, UtilityPaymentProvider, UtilityService>
    
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
            state.destination = nil
            // state.setUtilityPrepaymentAlert(to: nil)
            
        case .destination:
            hideKeyboard()
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
        let node = factory.makePayByInstructionsViewModel(closeAction)
        
        switch state.utilityPrepaymentDestination {
        case .none:
            state.setUtilityPrepaymentDestination(to: .payByInstructions(node.model))
            
        case .operatorFailure:
            state.setUtilityServiceOperatorFailureDestination(to: .payByInstructions(node.model))
            
        default:
            break
        }
    }
    
    typealias OperatorServices = Vortex.OperatorServices<UtilityPaymentProvider, UtilityService>
    private typealias InitiateAnywayPaymentDomain = Vortex.InitiateAnywayPaymentDomain<UtilityPaymentLastPayment, UtilityPaymentProvider, UtilityService, OperatorServices, AnywayTransactionState.Transaction>
    
    private func reduce(
        _ state: inout State,
        with result: InitiateAnywayPaymentDomain.Result
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
        with failure: InitiateAnywayPaymentDomain.Failure
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
        with success: InitiateAnywayPaymentDomain.Success
    ) {
        switch success {
        case let .services(operatorServices):
            state.setUtilityPrepaymentDestination(to: .servicePicker(.init(
                content: .init(
                    services: operatorServices.services,
                    operator: operatorServices.operator
                ),
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

private extension PaymentsTransfersViewModel.Route {
    
    typealias UtilityFlowState = UtilityPaymentFlowState<UtilityPaymentProvider, UtilityService, UtilityPrepaymentBinder>
    
    var merchantIcon: String? {
        
        guard let paymentFlowState = paymentFlowState ?? paymentFlowStateInServicePicker ?? paymentFlowStateInDestination
        else { return nil }
        
        let icon = paymentFlowState.content.state.transaction.context.outline.payload.icon
        return icon
    }
    
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
    
    typealias OperatorFailure = SberOperatorFailureFlowState<UtilityPaymentProvider>
    
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
    
    typealias ServicePickerState = UtilityServicePickerFlowState<UtilityPaymentProvider, UtilityService>
    
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
    
    /*private*/ var paymentFlowState: UtilityServicePaymentFlowState? {
        
        guard case let .payment(paymentFlowState) = utilityPrepaymentDestination
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
        // or in destination
        setDestinationPaymentAlert(to: alert)
    }
    
    mutating func setPaymentFullScreenCover(
        to fullScreenCover: UtilityServicePaymentFlowState.FullScreenCover?
    ) {
        // try to change payment node in the tree if found
        // in prepayment destination
        setPrepaymentPaymentFullScreenCover(to: fullScreenCover)
        // or in servicePicker destination
        setServicePickerPaymentFullScreenCover(to: fullScreenCover)
        // or in destination
        setDestinationPaymentFullScreenCover(to: fullScreenCover)
    }
    
    mutating func setPaymentModal(
        to modal: UtilityServicePaymentFlowState.Modal?
    ) {
        // try to change payment node in the tree if found
        // in prepayment destination
        setPrepaymentPaymentModal(to: modal)
        // or in servicePicker destination
        setServicePickerPaymentModal(to: modal)
        // or in destination
        setDestinationPaymentModal(to: modal)
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
    
    private var paymentFlowStateInServicePicker: UtilityServicePaymentFlowState? {
        
        guard case let .utilityPayment(utilityPrepayment) = destination,
              case let .servicePicker(servicePicker) = utilityPrepayment.destination,
              case let .payment(paymentFlowState) = servicePicker.destination
        else { return nil }

        return paymentFlowState
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
    
    private mutating func setDestinationPaymentAlert(
        to alert: UtilityServicePaymentFlowState.Alert?
    ) {
        guard case var .servicePayment(paymentFlowState) = destination
        else { return }
        
        paymentFlowState.alert = alert
        self.destination = .servicePayment(paymentFlowState)
    }
    
    private var paymentFlowStateInDestination: UtilityServicePaymentFlowState? {
        
        guard case var .servicePayment(paymentFlowState) = destination
        else { return nil }

        return paymentFlowState
    }
    
    private mutating func setDestinationPaymentFullScreenCover(
        to fullScreenCover: UtilityServicePaymentFlowState.FullScreenCover?
    ) {
        guard case var .servicePayment(paymentFlowState) = destination
        else { return }
        
        paymentFlowState.fullScreenCover = fullScreenCover
        self.destination = .servicePayment(paymentFlowState)
    }
    
    private mutating func setDestinationPaymentModal(
        to modal: UtilityServicePaymentFlowState.Modal?
    ) {
        guard case var .servicePayment(paymentFlowState) = destination
        else { return }
        
        paymentFlowState.modal = modal
        self.destination = .servicePayment(paymentFlowState)
    }
}
