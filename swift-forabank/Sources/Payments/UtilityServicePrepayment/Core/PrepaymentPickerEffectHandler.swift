//
//  PrepaymentPickerEffectHandler.swift
//
//
//  Created by Igor Malyarov on 12.05.2024.
//

import UtilityServicePrepaymentDomain

#warning("TODO: throttle, debounce, remove duplicates")
public final class PrepaymentPickerEffectHandler<Operator>
where Operator: Identifiable {
    
    private let paginate: Paginate
    
    public init(
        paginate: @escaping Paginate
    ) {
        self.paginate = paginate
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
        }
    }
}

public extension PrepaymentPickerEffectHandler {
    
    typealias PaginatePayload = Effect.PaginatePayload
    typealias PaginateResult = [Operator]
    typealias PaginateCompletion = (PaginateResult) -> Void
    typealias Paginate = (PaginatePayload, @escaping PaginateCompletion) -> Void
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = PrepaymentPickerEvent<Operator>
    typealias Effect = PrepaymentPickerEffect<Operator.ID>
}

private extension PrepaymentPickerEffectHandler {
    
    func paginate(
        _ payload: PaginatePayload,
        _ dispatch: @escaping Dispatch
    ) {
        paginate(payload) { dispatch(.page($0)) }
    }
}
