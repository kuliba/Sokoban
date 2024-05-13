//
//  UtilityPrepaymentViewModelComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 09.05.2024.
//

import UtilityServicePrepaymentCore
import UtilityServicePrepaymentDomain

final class UtilityPrepaymentViewModelComposer {
    
    private let log: (String, StaticString, UInt) -> Void
    private let paginate: UtilityPrepaymentEffectHandler.Paginate
    private let search: UtilityPrepaymentEffectHandler.Search
    
    init(
        log: @escaping (String, StaticString, UInt) -> Void,
        paginate: @escaping UtilityPrepaymentEffectHandler.Paginate,
        search: @escaping UtilityPrepaymentEffectHandler.Search
    ) {
        self.log = log
        self.paginate = paginate
        self.search = search
    }
}

extension UtilityPrepaymentViewModelComposer {
    
    func makeViewModel(
        payload: PrepaymentPayload
    ) -> UtilityPrepaymentViewModel {
        
        let reducer = UtilityPrepaymentReducer(
            observeLast: 5,
            pageSize: 20
        )
        let effectHandler = UtilityPrepaymentEffectHandler(
            paginate: paginate,
            search: search
        )
        
        return .init(
            initialState: payload.state,
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:)
        )
    }
}

extension UtilityPrepaymentViewModelComposer {
    
    typealias LastPayment = UtilityPaymentLastPayment
    typealias Operator = UtilityPaymentOperator<String>
    
    typealias Event = UtilityPaymentFlowEvent<LastPayment, Operator, UtilityService>
    typealias PrepaymentPayload = Event.UtilityPrepaymentFlowEvent.UtilityPrepaymentPayload
    
    typealias UtilityPrepaymentReducer = PrepaymentPickerReducer<UtilityPaymentLastPayment, UtilityPaymentOperator<String>>
    typealias UtilityPrepaymentEffectHandler = PrepaymentPickerEffectHandler<UtilityPaymentOperator<String>>
}
