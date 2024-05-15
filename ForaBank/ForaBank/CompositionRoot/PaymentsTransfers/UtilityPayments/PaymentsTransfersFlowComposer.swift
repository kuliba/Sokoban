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
    
    private let httpClient: HTTPClient
    private let model: Model
    private let pageSize: Int
    private let observeLast: Int
    private let flag: StubbedFeatureFlag.Option
    
    init(
        httpClient: HTTPClient,
        model: Model,
        pageSize: Int,
        observeLast: Int,
        flag: StubbedFeatureFlag.Option
    ) {
        self.httpClient = httpClient
        self.model = model
        self.pageSize = pageSize
        self.observeLast = observeLast
        self.flag = flag
    }
}

extension PaymentsTransfersFlowComposer {
    
    func compose() -> FlowManager {
        
        let nanoComposer = UtilityPaymentNanoServicesComposer(
            httpClient: httpClient,
            model: model,
            flag: flag
        )
        let microComposer = UtilityPaymentMicroServicesComposer(
            pageSize: pageSize,
            nanoServices: nanoComposer.compose()
        )
        
        return .init(
            handleEffect: makeEffectHandler().handleEffect(_:_:),
            makeReduce: makeReduce()
        )
    }
    
    typealias LastPayment = UtilityPaymentLastPayment
    typealias Operator = UtilityPaymentOperator
    
    typealias Content = UtilityPrepaymentViewModel
    typealias PaymentViewModel = ObservingPaymentFlowMockViewModel
    
    typealias FlowManager = PaymentsTransfersFlowManager<LastPayment, Operator, UtilityService, Content, PaymentViewModel>
}

private extension PaymentsTransfersFlowComposer {
    
    func makeEffectHandler() -> EffectHandler {
        
        let composer = UtilityPaymentsFlowComposer(flag: flag)
        let utilityEffectHandler = composer.makeEffectHandler()
        
        return .init(
            utilityEffectHandle: utilityEffectHandler.handleEffect(_:_:)
        )
    }
    
    typealias EffectHandler = PaymentsTransfersFlowEffectHandler<LastPayment, Operator, UtilityService>
    
    func makeReduce() -> FlowManager.MakeReduce {
        
        let composer = makePaymentsTransfersFlowReducerFactoryComposer()
        let factory = composer.compose()
        
        let makeReducer = {
            
            Reducer(factory: factory, closeAction: $0, notify: $1)
        }
        
        return { makeReducer($0, $1).reduce(_:_:) }
    }
    
    typealias Reducer = PaymentsTransfersFlowReducer<LastPayment, Operator, UtilityService, Content, PaymentViewModel>
    
    func makePaymentsTransfersFlowReducerFactoryComposer(
    ) -> PaymentsTransfersFlowReducerFactoryComposer {
        
        let nanoComposer = UtilityPrepaymentNanoServicesComposer(
            model: model,
            flag: flag
        )
        let microComposer = UtilityPrepaymentMicroServicesComposer(
            pageSize: pageSize,
            nanoServices: nanoComposer.compose()
        )
        
        return .init(
            model: model,
            observeLast: observeLast,
            microServices: microComposer.compose()
        )
    }
}
