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
    
    private let flag: StubbedFeatureFlag.Option
    private let httpClient: HTTPClient
    private let model: Model
    private let loaderComposer: LoaderComposer
    private let pageSize: Int
    private let observeLast: Int
    
    init(
        flag: StubbedFeatureFlag.Option,
        httpClient: HTTPClient,
        model: Model,
        loaderComposer: LoaderComposer,
        pageSize: Int,
        observeLast: Int
    ) {
        self.flag = flag
        self.httpClient = httpClient
        self.model = model
        self.loaderComposer = loaderComposer
        self.pageSize = pageSize
        self.observeLast = observeLast
    }
}

extension PaymentsTransfersFlowComposer {
    
    func compose() -> FlowManager {
        
        return .init(
            handleEffect: makeEffectHandler().handleEffect(_:_:),
            makeReduce: makeReduce()
        )
    }
    
    typealias LoaderComposer = UtilityPaymentOperatorLoaderComposer
    
    typealias LastPayment = UtilityPaymentLastPayment
    typealias Operator = UtilityPaymentOperator
    
    typealias Content = UtilityPrepaymentViewModel
    typealias PaymentViewModel = ObservingPaymentFlowMockViewModel
    
    typealias FlowManager = PaymentsTransfersFlowManager<LastPayment, Operator, UtilityService, Content, PaymentViewModel>
}

private extension PaymentsTransfersFlowComposer {
    
    func makeEffectHandler() -> EffectHandler {
        
        let nanoComposer = UtilityPaymentNanoServicesComposer(
            flag: flag,
            httpClient: httpClient,
            loadOperators: { self.loaderComposer.compose()(.init(), $0) }
        )
        let microComposer = UtilityPaymentMicroServicesComposer(
            nanoServices: nanoComposer.compose()
        )
        let composer = UtilityPaymentsFlowComposer(
            flag: flag,
            microServices: microComposer.compose()
        )
        let utilityEffectHandler = composer.makeEffectHandler()
        
        return .init(
            utilityEffectHandle: utilityEffectHandler.handleEffect(_:_:)
        )
    }
    
    typealias EffectHandler = PaymentsTransfersFlowEffectHandler<LastPayment, Operator, UtilityService>
    
    func makeReduce() -> FlowManager.MakeReduce {
        
        let factory = makeReducerFactoryComposer().compose()
        let makeReducer = {
            
            Reducer(factory: factory, closeAction: $0, notify: $1)
        }
        
        return { makeReducer($0, $1).reduce(_:_:) }
    }
    
    private typealias Reducer = PaymentsTransfersFlowReducer<LastPayment, Operator, UtilityService, Content, PaymentViewModel>
    
    private func makeReducerFactoryComposer(
    ) -> PaymentsTransfersFlowReducerFactoryComposer {
        
        let nanoServices = UtilityPrepaymentNanoServices(
            loadOperators: loadOperators
        )
        let microComposer = UtilityPrepaymentMicroServicesComposer(
            pageSize: pageSize,
            nanoServices: nanoServices
        )
        
        return .init(
            model: model,
            observeLast: observeLast,
            microServices: microComposer.compose()
        )
    }
    
    private func loadOperators(
        payload: LoadOperatorsPayload,
        completion: @escaping ([Operator]) -> Void
    ) {
        loaderComposer.compose()(.init(operatorID: payload.operatorID, searchText: payload.searchText), completion)
    }
    
    private typealias LoadOperatorsPayload = UtilityPrepaymentNanoServices<Operator>.LoadOperatorsPayload
}
