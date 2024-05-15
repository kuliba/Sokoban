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
    
    init(
        factory: Factory
    ) {
        self.factory = factory
    }
}

extension PaymentsTransfersFlowComposer {
    
    typealias Reducer = PaymentsTransfersFlowReducer<LastPayment, Operator, UtilityService, Content, PaymentViewModel>
    typealias Factory = Reducer.Factory
}

extension PaymentsTransfersFlowComposer {
    
    func compose(
        flag: StubbedFeatureFlag.Option
    ) -> PTFlowManager {
        
        let utilityPaymentsComposer = UtilityPaymentsFlowComposer(flag: flag)
        
        let utilityFlowEffectHandler = utilityPaymentsComposer.makeEffectHandler()
        
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
    
    typealias LastPayment = UtilityPaymentLastPayment
    typealias Operator = UtilityPaymentOperator
    
    typealias Content = UtilityPrepaymentViewModel
    typealias PaymentViewModel = ObservingPaymentFlowMockViewModel
    
    typealias PTFlowManager = PaymentsTransfersFlowManager<LastPayment, Operator, UtilityService, Content, PaymentViewModel>
}
