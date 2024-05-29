//
//  PrepaymentPickerEffectHandler.swift
//
//
//  Created by Igor Malyarov on 12.05.2024.
//

import UtilityServicePrepaymentDomain

public final class PrepaymentPickerEffectHandler<Operator>
where Operator: Identifiable {
    
    private let microServices: MicroServices
    
    public init(microServices: MicroServices) {
        
        self.microServices = microServices
    }
}

public extension PrepaymentPickerEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case let .paginate(payload):
            paginate(payload, dispatch)
            
        case let .search(payload):
            search(payload, dispatch)
        }
    }
}

public extension PrepaymentPickerEffectHandler {
    
    typealias MicroServices = PrepaymentPickerMicroServices<Operator>
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = PrepaymentPickerEvent<Operator>
    typealias Effect = PrepaymentPickerEffect<Operator.ID>
}

private extension PrepaymentPickerEffectHandler {
    
    func paginate(
        _ payload: MicroServices._PaginatePayload,
        _ dispatch: @escaping Dispatch
    ) {
        microServices.paginate(payload) { dispatch(.page($0)) }
    }
    
    func search(
        _ payload: String,
        _ dispatch: @escaping Dispatch
    ) {
        microServices.search(payload) { dispatch(.load($0)) }
    }
}
