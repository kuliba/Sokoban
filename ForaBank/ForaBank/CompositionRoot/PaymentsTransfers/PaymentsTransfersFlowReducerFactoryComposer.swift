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
    private let initiateOTP: InitiateOTP
    private let observeLast: Int
    private let fraudDelay: Double
    private let navTitle: String
    private let microServices: MicroServices
    private let makeTransactionViewModel: MakeTransactionViewModel
    
    init(
        model: Model,
        initiateOTP: @escaping InitiateOTP,
        observeLast: Int,
        fraudDelay: Double,
        navTitle: String,
        microServices: MicroServices,
        makeTransactionViewModel: @escaping MakeTransactionViewModel
    ) {
        self.model = model
        self.initiateOTP = initiateOTP
        self.observeLast = observeLast
        self.fraudDelay = fraudDelay
        self.navTitle = navTitle
        self.microServices = microServices
        self.makeTransactionViewModel = makeTransactionViewModel
    }
    
    typealias InitiateOTP = CountdownEffectHandler.InitiateOTP
    
    typealias MicroServices = PrepaymentPickerMicroServices<Operator>
    
    typealias MakeTransactionViewModel = (AnywayTransactionState, @escaping Observe) -> AnywayTransactionViewModel
    typealias Observe = (AnywayTransactionState, AnywayTransactionState) -> Void
}

extension PaymentsTransfersFlowReducerFactoryComposer {
    
    func compose(
        with spinnerActions: RootViewModel.RootActions.Spinner?
    ) -> Factory {
        
        return .init(
            getFormattedAmount: getFormattedAmount,
            makeFraud: makeFraudNoticePayload,
            makeUtilityPrepaymentState: makeUtilityPrepaymentState,
            makeUtilityPaymentState: makeUtilityPaymentState(with: spinnerActions),
            makePaymentsViewModel: makePayByInstructionsViewModel
        )
    }
    
    typealias Factory = PaymentsTransfersFlowReducerFactory<LastPayment, Operator, UtilityService, Content, UtilityPaymentViewModel>
}

extension PaymentsTransfersFlowReducerFactoryComposer {
    
    typealias LastPayment = UtilityPaymentLastPayment
    typealias Operator = UtilityPaymentOperator
    typealias Service = UtilityService
    
    typealias Content = UtilityPrepaymentViewModel
    typealias UtilityPaymentViewModel = CachedAnywayTransactionViewModel
}

private extension PaymentsTransfersFlowReducerFactoryComposer {
    
    func getFormattedAmount(
        state: Factory.ReducerState
    ) -> String? {
        
        guard let context = state.paymentFlowState?.viewModel.state.context
        else { return nil }
        
        guard case let .amount(amount, currency) = context.payment.footer
        else { return "" }
        
        var formattedAmount = "\(amount)"
        
#warning("look into model to extract currency symbol")
        if let currency {
            formattedAmount += " \(currency)"
        }
        
        return formattedAmount
    }
    
    func makeFraudNoticePayload(
        state: Factory.ReducerState
    ) -> FraudNoticePayload? {
        
        guard case let .utilityPayment(utilityPrepayment) = state.destination,
              case let .payment(paymentFlowState) = utilityPrepayment.destination
        else { return nil }
        
        let context = paymentFlowState.viewModel.state.context
        let payload = context.outline.payload
        
        return .init(
            title: payload.title,
            subtitle: payload.subtitle,
            formattedAmount: getFormattedAmount(state: state) ?? "",
            delay: fraudDelay
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

private extension CachedAnywayPayment<AnywayElementModel>.Footer {
    
    var formattedAmount: String? {
        
        guard case let .amount(amount, currency) = self
        else { return nil }
        
        return "\(amount) \(currency ?? "")"
    }
}

private extension PaymentsTransfersFlowReducerFactoryComposer {
    
    func makeUtilityPrepaymentState(
        payload: UtilityPrepaymentPayload
    ) -> UtilityFlowState {
        
        let reducer = UtilityPrepaymentReducer(observeLast: observeLast)
        
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
        
        return .init(content: viewModel, navTitle: navTitle)
    }
    
    typealias UtilityFlowState = UtilityPaymentFlowState<Operator, UtilityService, Content, UtilityPaymentViewModel>
    
    typealias UtilityPrepaymentEvent = UtilityPrepaymentFlowEvent<LastPayment, Operator, Service>
    typealias UtilityPrepaymentPayload = UtilityPrepaymentEvent.Initiated.UtilityPrepaymentPayload
    
    typealias UtilityPrepaymentReducer = PrepaymentPickerReducer<UtilityPaymentLastPayment, UtilityPaymentOperator>
    typealias UtilityPrepaymentEffectHandler = PrepaymentPickerEffectHandler<UtilityPaymentOperator>
}

private extension PaymentsTransfersFlowReducerFactoryComposer {
    
    func makeUtilityPaymentState(
        with spinnerActions: RootViewModel.RootActions.Spinner?
    ) -> (AnywayTransactionState, @escaping NotifyStatus) -> UtilityServicePaymentFlowState<UtilityPaymentViewModel> {
        
        let elementMapperComposer = AnywayElementModelMapperComposer(
            currencyOfProduct: currencyOfProduct,
            getProducts: model.productSelectProducts,
            initiateOTP: initiateOTP
        )
        
        let composer = CachedAnywayTransactionViewModelComposer(
            elementMapperComposer: elementMapperComposer,
            makeTransactionViewModel: makeTransactionViewModel,
            spinnerActions: spinnerActions
        )
        
        return { transactionState, notify in
            
            let viewModel = composer.makeCachedAnywayTransactionViewModel(
                transactionState: transactionState,
                notify: notify
            )
            
            return .init(viewModel: viewModel)
        }
    }
    
    typealias NotifyStatus = (AnywayTransactionStatus?) -> Void
    
    private func currencyOfProduct(
        product: ProductSelect.Product
    ) -> String {
        
        model.currencyOf(product: product) ?? ""
    }
}

private extension PaymentsTransfersFlowReducerFactoryComposer {
    
    func makePayByInstructionsViewModel(
        closeAction: @escaping () -> Void
    ) -> PaymentsViewModel {
        
        return .init(model, service: .requisites, closeAction: closeAction)
    }
}
