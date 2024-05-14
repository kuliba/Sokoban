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
    private let log: Log
    
    init(
        httpClient: HTTPClient,
        model: Model,
        log: @escaping (String, StaticString, UInt) -> Void
    ) {
        self.httpClient = httpClient
        self.model = model
        self.log = log
    }
}

extension PaymentsTransfersFlowComposer {
    
    typealias Log = (String, StaticString, UInt) -> Void
}

extension PaymentsTransfersFlowComposer {
    
    func makeFlowManager(
        flag: StubbedFeatureFlag.Option
    ) -> PaymentsTransfersManager {
        
        let utilityPrepaymentViewModelComposer = UtilityPrepaymentViewModelComposer(
            log: log,
            paginate: { [loadOperators = model.loadOperators] payload, completion in
                
                loadOperators(payload.loadPayload) { result in
                
                    completion((try? result.get()) ?? [])
                }
            },
            search: { [loadOperators = model.loadOperators] payload, completion in
                
                loadOperators(payload.loadPayload) { result in
                
                    completion((try? result.get()) ?? [])
                }
            }
        )
        
        typealias Reducer = PaymentsTransfersFlowReducer<LastPayment, Operator, UtilityService, Content, PaymentViewModel>
        typealias ReducerFactory = Reducer.Factory
        
        let factory = ReducerFactory(
            makeUtilityPrepaymentViewModel: utilityPrepaymentViewModelComposer.makeViewModel,
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
    typealias Operator = UtilityPaymentOperator<String>
    
    typealias Content = UtilityPrepaymentViewModel
    typealias PaymentViewModel = ObservingPaymentFlowMockViewModel
    
    typealias PaymentsTransfersManager = PaymentsTransfersFlowManager<LastPayment, Operator, UtilityService, Content, PaymentViewModel>
}

// MARK: - Adapters

#warning("change `loadOperators` parameters and remove adapter")
extension PaginatePayload<String> {
    
    var loadPayload: LoadOperatorsPayload<String> {
        
        .init(
            afterOperatorID: operatorID,
            searchText: searchText,
            pageSize: pageSize
        )
    }
}

#warning("change `loadOperators` parameters and remove adapter")
extension SearchPayload {
    
    var loadPayload: LoadOperatorsPayload<String> {
        
        .init(
            afterOperatorID: nil,
            searchText: searchText,
            pageSize: pageSize
        )
    }
}
