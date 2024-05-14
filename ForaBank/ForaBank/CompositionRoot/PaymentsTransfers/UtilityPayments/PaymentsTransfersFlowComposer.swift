//
//  PaymentsTransfersFlowComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 09.05.2024.
//

import OperatorsListComponents
import ForaTools
import Foundation
import UtilityServicePrepaymentCore
import UtilityServicePrepaymentDomain

final class PaymentsTransfersFlowComposer {
    
    private let model: Model
    private let observeLast: Int
    private let utilityMicroServices: UtilityMicroServices
    
    init(
        model: Model,
        observeLast: Int,
        utilityMicroServices: UtilityMicroServices
    ) {
        self.model = model
        self.observeLast = observeLast
        self.utilityMicroServices = utilityMicroServices
    }
}

extension PaymentsTransfersFlowComposer {
    
    typealias Log = (String, StaticString, UInt) -> Void
    typealias UtilityMicroServices = UtilityPaymentMicroServices<LastPayment, Operator>
}

extension PaymentsTransfersFlowComposer {
    
    func makeFlowManager(
        flag: StubbedFeatureFlag.Option
    ) -> PaymentsTransfersManager {
        
        typealias Reducer = PaymentsTransfersFlowReducer<LastPayment, Operator, UtilityService, Content, PaymentViewModel>
        typealias ReducerFactory = Reducer.Factory
        
        let factory = ReducerFactory(
            makeUtilityPrepaymentViewModel: makeUtilityPrepaymentViewModel,
            makeUtilityPaymentViewModel: { _, notify in
                
                return .init(notify: notify)
            },
            makePaymentsViewModel: { [model = self.model] in
                
                return .init(model, service: .requisites, closeAction: $0)
            }
        )
        
        let utilityPaymentsComposer = UtilityPaymentsFlowComposer(flag: flag)
        
        let utilityFlowEffectHandler = utilityPaymentsComposer.makeEffectHandler()
        
        let effectHandler = PaymentsTransfersFlowEffectHandler(
            utilityEffectHandle: utilityFlowEffectHandler.handleEffect(_:_:)
        )
        
        let makeReducer = {
            
            Reducer(factory: factory, closeAction: $0, notify: $1)
        }
        
        return .init(
            handleEffect: effectHandler.handleEffect(_:_:),
            makeReduce: { makeReducer($0, $1).reduce(_:_:) }
        )
    }
    
    typealias LastPayment = UtilityPaymentLastPayment
    typealias Operator = UtilityPaymentOperator
    
    typealias Content = UtilityPrepaymentViewModel
    typealias PaymentViewModel = ObservingPaymentFlowMockViewModel
    
    typealias PaymentsTransfersManager = PaymentsTransfersFlowManager<LastPayment, Operator, UtilityService, Content, PaymentViewModel>
}

private extension PaymentsTransfersFlowComposer {
    
    func makeUtilityPrepaymentViewModel(
        payload: PrepaymentPayload
    ) -> UtilityPrepaymentViewModel {
        
        let reducer = UtilityPrepaymentReducer(observeLast: 5)
        
#warning("TODO: throttle, debounce, remove duplicates")
        let effectHandler = UtilityPrepaymentEffectHandler(
            paginate: utilityMicroServices.paginate,
            search: utilityMicroServices.search
        )
        
        return .init(
            initialState: payload.state,
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:)
        )
    }
    
    typealias Event = UtilityPaymentFlowEvent<LastPayment, Operator, UtilityService>
    typealias PrepaymentPayload = Event.UtilityPrepaymentFlowEvent.UtilityPrepaymentPayload
    
    typealias UtilityPrepaymentReducer = PrepaymentPickerReducer<UtilityPaymentLastPayment, UtilityPaymentOperator>
    typealias UtilityPrepaymentEffectHandler = PrepaymentPickerEffectHandler<UtilityPaymentOperator>
}
