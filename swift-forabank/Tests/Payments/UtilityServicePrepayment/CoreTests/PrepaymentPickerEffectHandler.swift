//
//  PrepaymentPickerEffectHandler.swift
//
//
//  Created by Igor Malyarov on 12.05.2024.
//

import UtilityServicePrepaymentDomain

#warning("TODO: throttle, debounce, remove duplicates")
final class PrepaymentPickerEffectHandler<Operator>
where Operator: Identifiable {
    
    private let paginate: Paginate
    
    init(
        paginate: @escaping Paginate
    ) {
        self.paginate = paginate
    }
}

extension PrepaymentPickerEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case let .paginate(operatorID, pageSize):
            paginate(operatorID, pageSize, dispatch)
        }
    }
}

extension PrepaymentPickerEffectHandler {
    
    typealias PageSize = Effect.PageSize
    typealias PaginatePayload = (Operator.ID, PageSize)
    typealias PaginateResult = [Operator]
    typealias PaginateCompletion = (PaginateResult) -> Void
    typealias Paginate = (PaginatePayload, @escaping PaginateCompletion) -> Void
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = PrepaymentPickerEvent<Operator>
    typealias Effect = PrepaymentPickerEffect<Operator.ID>
}

extension PrepaymentPickerEffectHandler {
    
    func paginate(
        _ operatorID: Operator.ID,
        _ pageSize: PageSize,
        _ dispatch: @escaping Dispatch
    ) {
        paginate((operatorID, pageSize)) { dispatch(.page($0)) }
    }
}
