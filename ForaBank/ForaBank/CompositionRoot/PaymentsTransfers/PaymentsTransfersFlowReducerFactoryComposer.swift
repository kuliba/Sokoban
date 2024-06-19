//
//  PaymentsTransfersFlowReducerFactoryComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 14.05.2024.
//

import AnywayPaymentCore
import AnywayPaymentDomain
import PaymentComponents
import RxViewModel
import UtilityServicePrepaymentCore

final class PaymentsTransfersFlowReducerFactoryComposer {
    
    private let model: Model
    private let settings: Settings
    private let microServices: MicroServices
    
    init(
        model: Model,
        settings: Settings,
        microServices: MicroServices
    ) {
        self.model = model
        self.settings = settings
        self.microServices = microServices
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
            makePaymentsViewModel: makePayByInstructionsViewModel
        )
    }
    
    typealias Factory = PaymentsTransfersFlowReducerFactory<LastPayment, Operator, UtilityService, Content, UtilityPaymentViewModel>
    typealias MakeUtilityPaymentState = Factory.MakeUtilityPaymentState
    
    typealias LastPayment = UtilityPaymentLastPayment
    typealias Operator = UtilityPaymentOperator
    typealias Service = UtilityService
    
    typealias Content = UtilityPrepaymentViewModel
    typealias UtilityPaymentViewModel = AnywayTransactionViewModel
}

private extension PaymentsTransfersFlowReducerFactoryComposer {
    
    func getFormattedAmount(
        state: Factory.ReducerState
    ) -> String? {
        
        guard let state = state.paymentFlowState?.viewModel.state
        else { return nil }
        
        let context = state.transaction.context
        let digest = context.makeDigest()
        let amount = digest.amount
        let currency = digest.core?.currency
        
        var formattedAmount = amount.map { "\($0)" } ?? ""
        
#warning("look into model to extract currency symbol")
        if let currency {
            formattedAmount += " \(currency)"
            _ = model
        }
        
        return formattedAmount
    }
    
    func makeFraudNoticePayload(
        state: Factory.ReducerState
    ) -> FraudNoticePayload? {
        
        guard case let .utilityPayment(utilityPrepayment) = state.destination,
              case let .payment(paymentFlowState) = utilityPrepayment.destination
        else { return nil }
        
        let context = paymentFlowState.viewModel.state.transaction.context
        let payload = context.outline.payload
        
        return .init(
            title: payload.title,
            subtitle: payload.subtitle,
            formattedAmount: getFormattedAmount(state: state) ?? "",
            delay: settings.fraudDelay
        )
    }
}

private extension PaymentsTransfersViewModel._Route {
    
    var paymentFlowState: UtilityPaymentFlowState<Operator, UtilityService, Content, PaymentViewModel>.Destination.Payment? {
        
        guard case let .utilityPayment(utilityPrepayment) = destination,
              case let .payment(paymentFlowState) = utilityPrepayment.destination
        else { return nil }
        
        return paymentFlowState
    }
}

private extension PaymentsTransfersFlowReducerFactoryComposer {
    
    func makeUtilityPrepaymentState(
        payload: UtilityPrepaymentPayload
    ) -> UtilityFlowState {
        
        let reducer = UtilityPrepaymentReducer(
            observeLast: settings.observeLast
        )
        
        let effectHandler = UtilityPrepaymentEffectHandler(
            microServices: microServices
        )
        
        let viewModel = UtilityPrepaymentViewModel(
            initialState: .init(
                lastPayments: payload.lastPayments,
                operators: payload.operators,
                searchText: ""
            ),
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:)
        )
        
        return .init(content: viewModel, navTitle: settings.navTitle)
    }
    
    typealias UtilityFlowState = UtilityPaymentFlowState<Operator, UtilityService, Content, UtilityPaymentViewModel>
    
    typealias UtilityPrepaymentEvent = UtilityPrepaymentFlowEvent<LastPayment, Operator, Service>
    typealias UtilityPrepaymentPayload = UtilityPrepaymentEvent.Initiated.UtilityPrepaymentPayload
    
    typealias UtilityPrepaymentReducer = PrepaymentPickerReducer<UtilityPaymentLastPayment, UtilityPaymentOperator>
    typealias UtilityPrepaymentEffectHandler = PrepaymentPickerEffectHandler<UtilityPaymentOperator>
}

private extension PaymentsTransfersFlowReducerFactoryComposer {
    
    func makePayByInstructionsViewModel(
        closeAction: @escaping () -> Void
    ) -> PaymentsViewModel {
        
        return .init(model, service: .requisites, closeAction: closeAction)
    }
}
