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
            makeUtilityPrepaymentViewModel: { [makeUtilityPrepaymentViewModel] in
                
                makeUtilityPrepaymentViewModel(.init(
                    lastPayments: $0.lastPayments,
                    operators: $0.operators
                ))
            },
            makeUtilityPaymentViewModel: { _, notify in
                
                return .init(notify: notify)
            },
            makePaymentsViewModel: { [model = self.model] in
                
                return .init(model, service: .requisites, closeAction: $0)
            }
        )
    }
}

extension PaymentsTransfersFlowReducerFactoryComposer {
    
    typealias MicroServices = UtilityPrepaymentMicroServices<UtilityPaymentOperator>
    
    typealias Factory = PaymentsTransfersFlowReducerFactory<LastPayment, Operator, UtilityService, Content, PaymentViewModel>
    
    typealias LastPayment = UtilityPaymentLastPayment
    typealias Operator = UtilityPaymentOperator
    
    typealias Content = UtilityPrepaymentViewModel
    typealias PaymentViewModel = ObservingPaymentFlowMockViewModel
}

private extension PaymentsTransfersFlowReducerFactoryComposer {
    
    func makeUtilityPrepaymentViewModel(
        payload: Payload
    ) -> UtilityPrepaymentViewModel {
        
        let reducer = UtilityPrepaymentReducer(observeLast: observeLast)
        
#warning("TODO: throttle, debounce, remove duplicates")
        let effectHandler = UtilityPrepaymentEffectHandler(
            paginate: microServices.paginate,
            search: microServices.search
        )
        
        return .init(
            initialState: .init(
                lastPayments: payload.lastPayments,
                operators: payload.operators,
                searchText: ""
            ),
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:)
        )
    }
    
    struct Payload {
        
        let lastPayments: [UtilityPaymentLastPayment]
        let operators: [UtilityPaymentOperator]
    }
    
    typealias UtilityPrepaymentReducer = PrepaymentPickerReducer<UtilityPaymentLastPayment, UtilityPaymentOperator>
    typealias UtilityPrepaymentEffectHandler = PrepaymentPickerEffectHandler<UtilityPaymentOperator>
}
