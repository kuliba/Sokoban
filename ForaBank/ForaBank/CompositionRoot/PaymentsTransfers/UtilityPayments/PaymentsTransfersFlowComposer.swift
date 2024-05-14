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
    private let makeUtilityPrepaymentViewModel: MakeUtilityPrepaymentViewModel
    private let utilityMicroServices: UtilityMicroServices
    
    init(
        model: Model,
        makeUtilityPrepaymentViewModel: @escaping MakeUtilityPrepaymentViewModel,
        utilityMicroServices: UtilityMicroServices
    ) {
        self.model = model
        self.makeUtilityPrepaymentViewModel = makeUtilityPrepaymentViewModel
        self.utilityMicroServices = utilityMicroServices
    }
}

extension PaymentsTransfersFlowComposer {
    
    typealias UtilityPrepaymentPayload = UtilityPaymentFlowEvent<LastPayment, Operator, UtilityService>.UtilityPrepaymentFlowEvent.UtilityPrepaymentPayload
    typealias MakeUtilityPrepaymentViewModel = (UtilityPrepaymentPayload) -> UtilityPrepaymentViewModel
    
    typealias UtilityMicroServices = UtilityPaymentMicroServices<LastPayment, Operator>
}

extension PaymentsTransfersFlowComposer {
    
    func compose(
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
