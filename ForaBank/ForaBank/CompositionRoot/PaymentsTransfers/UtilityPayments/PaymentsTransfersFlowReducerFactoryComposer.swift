//
//  PaymentsTransfersFlowReducerFactoryComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 14.05.2024.
//

import UtilityServicePrepaymentCore

final class PaymentsTransfersFlowReducerFactoryComposer {
    
    private let model: Model
    private let observeLast: Int
    private let microServices: MicroServices
    
    init(
        model: Model,
        observeLast: Int,
        microServices: MicroServices
    ) {
        self.model = model
        self.observeLast = observeLast
        self.microServices = microServices
    }
}

extension PaymentsTransfersFlowReducerFactoryComposer {
    
    func compose() -> Factory {
        
        return .init(
            makeUtilityPrepaymentState: makeUtilityPrepaymentState,
            makeUtilityPaymentState: makeUtilityPaymentState,
            makePaymentsViewModel: makePaymentsViewModel
        )
    }
}

extension PaymentsTransfersFlowReducerFactoryComposer {
    
    typealias MicroServices = PrepaymentPickerMicroServices<UtilityPaymentOperator>
    
    typealias Factory = PaymentsTransfersFlowReducerFactory<LastPayment, Operator, UtilityService, Content, PaymentViewModel>
    
    typealias LastPayment = UtilityPaymentLastPayment
    typealias Operator = UtilityPaymentOperator
    
    typealias Content = UtilityPrepaymentViewModel
    typealias PaymentViewModel = ObservingPaymentFlowMockViewModel
}

private extension PaymentsTransfersFlowReducerFactoryComposer {
    
    func makeUtilityPrepaymentState(
        payload: UtilityPrepaymentPayload
    ) -> UtilityFlowState {
        
        let payload = PrepaymentPayload(
            lastPayments: payload.lastPayments,
            operators: payload.operators
        )
        
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
        
        return .init(content: viewModel)
    }
    
    typealias UtilityFlowState = UtilityPaymentFlowState<LastPayment, Operator, UtilityService, Content, PaymentViewModel>
    
    typealias UtilityPrepaymentFlowEvent = UtilityPaymentFlowEvent<PaymentsTransfersFlowReducerFactoryComposer.LastPayment, PaymentsTransfersFlowReducerFactoryComposer.Operator, UtilityService>.UtilityPrepaymentFlowEvent
    typealias UtilityPrepaymentPayload = UtilityPrepaymentFlowEvent.UtilityPrepaymentPayload
    
    struct PrepaymentPayload {
        
        let lastPayments: [UtilityPaymentLastPayment]
        let operators: [UtilityPaymentOperator]
    }
    
    typealias UtilityPrepaymentReducer = PrepaymentPickerReducer<UtilityPaymentLastPayment, UtilityPaymentOperator>
    typealias UtilityPrepaymentEffectHandler = PrepaymentPickerEffectHandler<UtilityPaymentOperator>
}

private extension PaymentsTransfersFlowReducerFactoryComposer {
    
    func makeUtilityPaymentState(
        response: StartUtilityPaymentResponse,
        notify: @escaping (PaymentStateProjection) -> Void
    ) -> UtilityServicePaymentFlowState<PaymentViewModel> {
        
        let initialState: PaymentFlowMockState = {
            
#warning("map StartUtilityPaymentResponse")
            return .init()
        }()
        let viewModel = makeUtilityPaymentViewModel(
            initialState: initialState,
            notify: notify
        )
        
#warning("add subscription")
        
        return .init(viewModel: viewModel)
    }
    
    private func makeUtilityPaymentViewModel(
        initialState: PaymentFlowMockState,
        notify: @escaping (PaymentStateProjection) -> Void
    ) -> ObservingPaymentFlowMockViewModel {
        
        return .init(state: initialState, notify: notify)
    }
}

private extension PaymentsTransfersFlowReducerFactoryComposer {
    
    func makePaymentsViewModel(
        closeAction: @escaping () -> Void
    ) -> PaymentsViewModel {
        
        return .init(model, service: .requisites, closeAction: closeAction)
    }
}
