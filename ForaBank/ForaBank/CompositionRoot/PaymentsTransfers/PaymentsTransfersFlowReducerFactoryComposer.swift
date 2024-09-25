//
//  PaymentsTransfersFlowReducerFactoryComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 14.05.2024.
//

import AnywayPaymentCore
import AnywayPaymentDomain
import CombineSchedulers
import Foundation
import PaymentComponents
import RxViewModel
import TextFieldModel
import UtilityServicePrepaymentCore

final class PaymentsTransfersFlowReducerFactoryComposer {
    
    private let model: Model
    private let settings: Settings
    private let microServices: MicroServices
    private let scheduler: AnySchedulerOf<DispatchQueue>
    
    init(
        model: Model,
        settings: Settings,
        microServices: MicroServices,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.model = model
        self.settings = settings
        self.microServices = microServices
        self.scheduler = scheduler
    }
    
    typealias MicroServices = PrepaymentPickerMicroServices<Operator>
    
    typealias MakeTransactionViewModel = (AnywayTransactionState, @escaping Observe) -> AnywayTransactionViewModel
    typealias Observe = (AnywayTransactionState, AnywayTransactionState) -> Void
    
    struct Settings: Equatable {
        
        let observeLast: Int
        let fraudDelay: Double
        let navTitle: String
    }
}

extension PaymentsTransfersFlowReducerFactoryComposer {
    
    func compose(
        makeUtilityPaymentState: @escaping MakeUtilityPaymentState
    ) -> Factory {
        
        return .init(
            getFormattedAmount: getFormattedAmount,
            makeFraud: makeFraudNoticePayload,
            makeUtilityPrepaymentState: makeUtilityPrepaymentState,
            makeUtilityPaymentState: makeUtilityPaymentState,
            makePayByInstructionsViewModel: makePayByInstructionsViewModel
        )
    }
    
    typealias Factory = PaymentsTransfersFlowReducerFactory
    typealias MakeUtilityPaymentState = Factory.MakeUtilityPaymentState
    
    typealias LastPayment = UtilityPaymentLastPayment
    typealias Operator = UtilityPaymentOperator
    typealias Service = UtilityService
    
    typealias Content = UtilityPrepaymentBinder
    typealias UtilityPaymentViewModel = AnywayTransactionViewModel
}

private extension PaymentsTransfersFlowReducerFactoryComposer {
    
    func getFormattedAmount(
        state: Factory.ReducerState
    ) -> String? {
        
        guard let state = state.paymentFlowState?.content.state
        else { return nil }
        
        return model.getFormattedAmount(context: state.transaction.context)
    }
    
    func makeFraudNoticePayload(
        state: Factory.ReducerState
    ) -> FraudNoticePayload? {
        
        guard let paymentFlowState = state.paymentFlowState
        else {
            print("===>>>", "makeFraudNoticePayload failure: state.destination:", state.destination ?? "nil", #file, #line)
            return .init(title: "", subtitle: "", formattedAmount: "", delay: settings.fraudDelay)
        }
        
        let context = paymentFlowState.content.state.transaction.context
        let payload = context.outline.payload
        
        return .init(
            title: payload.title,
            subtitle: payload.subtitle,
            formattedAmount: getFormattedAmount(state: state) ?? "",
            delay: settings.fraudDelay
        )
    }
}

private extension PaymentsTransfersViewModel.Route {
    
    // UtilityPaymentFlowState could be nested in two destinations:
    // - utilityPrepayment.destination, or
    // - servicePicker.destination
    var paymentFlowState: UtilityServicePaymentFlowState? {
        
        paymentFlowStateInPrepaymentDestination ?? paymentFlowStateInServicePickerDestination
    }
    
    private var paymentFlowStateInPrepaymentDestination: UtilityServicePaymentFlowState? {
        
        guard case let .utilityPayment(utilityPrepayment) = destination,
              case let .payment(paymentFlowState) = utilityPrepayment.destination
        else { return nil }
        
        return paymentFlowState
    }
    
    private var paymentFlowStateInServicePickerDestination: UtilityServicePaymentFlowState? {
        
        guard case let .utilityPayment(utilityPrepayment) = destination,
              case let .servicePicker(servicePicker) = utilityPrepayment.destination,
              case let .payment(paymentFlowState) = servicePicker.destination
        else { return nil }
        
        return paymentFlowState
    }
}

private extension PaymentsTransfersFlowReducerFactoryComposer {
    
    func makeUtilityPrepaymentState(
        payload: UtilityPrepaymentPayload
    ) -> UtilityFlowState {
        
        let successReducer = UtilityPrepaymentSuccessReducer(
            observeLast: settings.observeLast
        )
        let reducer = UtilityPrepaymentReducer(
            successReduce: successReducer.reduce(_:_:)
        )
        
        let effectHandler = UtilityPrepaymentEffectHandler(
            microServices: microServices
        )
        
        let initialState: UtilityPrepaymentReducer.State = {
            
            struct NoOperatorsError: Error {}
            
            switch payload.operators {
            case .none:
                return .failure(NoOperatorsError())
                
            case let .some(operators):
                if operators.isEmpty {
                    return .failure(NoOperatorsError())
                } else {
                    
                    return .success(.init(
                        lastPayments: payload.lastPayments,
                        operators: operators,
                        searchText: ""
                    ))
                }
            }
        }()
        
        let viewModel = UtilityPrepaymentViewModel(
            initialState: initialState,
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:)
        )
        let placeholderText = "Наименование или ИНН"
        let searchReducer = TransformingReducer(
            placeholderText: placeholderText,
            transform: { $0}
        )
        let searchModel = RegularFieldViewModel(
            initialState: .placeholder(placeholderText),
            reducer: searchReducer,
            keyboardType: .default
        )
        let binder = UtilityPrepaymentBinder(
            model: viewModel,
            searchModel: searchModel
        )
        
        return .init(content: binder, navTitle: settings.navTitle)
    }
    
    typealias UtilityFlowState = UtilityPaymentFlowState<Operator, UtilityService, Content>
    
    typealias UtilityPrepaymentEvent = UtilityPrepaymentFlowEvent<LastPayment, Operator, Service>
    typealias UtilityPrepaymentPayload = UtilityPrepaymentEvent.Initiated.UtilityPrepaymentPayload
    
    typealias UtilityPrepaymentSuccessReducer = PrepaymentSuccessPickerReducer<UtilityPaymentLastPayment, UtilityPaymentOperator>
    typealias UtilityPrepaymentReducer = PrepaymentPickerReducer<UtilityPaymentLastPayment, UtilityPaymentOperator>
    typealias UtilityPrepaymentEffectHandler = PrepaymentPickerEffectHandler<UtilityPaymentOperator>
}

private extension PaymentsTransfersFlowReducerFactoryComposer {
    
    func makePayByInstructionsViewModel(
        closeAction: @escaping () -> Void
    ) -> Node<PaymentsViewModel> {
        
        return .init(
            model: .init(model, service: .requisites, closeAction: closeAction),
            cancellables: []
        )
    }
}
