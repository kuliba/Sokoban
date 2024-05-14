//
//  UtilityPrepaymentViewModelComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 14.05.2024.
//

import UtilityServicePrepaymentCore

final class UtilityPrepaymentViewModelComposer {
    
    private let observeLast: Int
    private let microServices: PrepaymentMicroServices
    
    init(
        observeLast: Int,
        microServices: PrepaymentMicroServices
    ) {
        self.observeLast = observeLast
        self.microServices = microServices
    }
}

extension UtilityPrepaymentViewModelComposer {
    
    typealias PrepaymentMicroServices = UtilityPrepaymentMicroServices<UtilityPaymentOperator>
}

extension UtilityPrepaymentViewModelComposer {
    
    func compose(
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
