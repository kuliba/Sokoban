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
    
    private let factory: Factory
    private let utilityFlowEffectHandler: UtilityFlowEffectHandler
    
    init(
        factory: Factory,
        utilityFlowEffectHandler: UtilityFlowEffectHandler
    ) {
        self.factory = factory
        self.utilityFlowEffectHandler = utilityFlowEffectHandler
    }
}

extension PaymentsTransfersFlowComposer {
    
    typealias Reducer = PaymentsTransfersFlowReducer<LastPayment, Operator, UtilityService, Content, PaymentViewModel>
    typealias Factory = Reducer.Factory
    
    typealias UtilityFlowEffectHandler = UtilityPaymentFlowEffectHandler<LastPayment, Operator, UtilityService>
    
    typealias LastPayment = UtilityPaymentLastPayment
    typealias Operator = UtilityPaymentOperator
}

extension PaymentsTransfersFlowComposer {
    
    func compose(
        flag: StubbedFeatureFlag.Option
    ) -> PTFlowManager {
        
        let effectHandler = PaymentsTransfersFlowEffectHandler(
            utilityEffectHandle: utilityFlowEffectHandler.handleEffect(_:_:)
        )
        
        let makeReducer = { [factory] in
            
            Reducer(factory: factory, closeAction: $0, notify: $1)
        }
        
        return .init(
            handleEffect: effectHandler.handleEffect(_:_:),
            makeReduce: { makeReducer($0, $1).reduce(_:_:) }
        )
    }
    typealias Content = UtilityPrepaymentViewModel
    typealias PaymentViewModel = ObservingPaymentFlowMockViewModel
    
    typealias PTFlowManager = PaymentsTransfersFlowManager<LastPayment, Operator, UtilityService, Content, PaymentViewModel>
}
