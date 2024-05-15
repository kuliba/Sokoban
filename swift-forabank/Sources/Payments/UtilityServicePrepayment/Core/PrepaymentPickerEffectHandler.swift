//
//  PrepaymentPickerEffectHandler.swift
//
//
//  Created by Igor Malyarov on 12.05.2024.
//

import UtilityServicePrepaymentDomain

public final class PrepaymentPickerEffectHandler<Operator>
where Operator: Identifiable {
    
    private let paginate: Paginate
    private let search: Search
    
    public init(
        paginate: @escaping Paginate,
        search: @escaping Search
    ) {
        self.paginate = paginate
        self.search = search
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
    
    typealias _PaginatePayload = PaginatePayload<Operator.ID>
    typealias PaginateResult = [Operator]
    typealias PaginateCompletion = (PaginateResult) -> Void
    typealias Paginate = (_PaginatePayload, @escaping PaginateCompletion) -> Void
    
    typealias SearchResult = [Operator]
    typealias SearchCompletion = (SearchResult) -> Void
    typealias Search = (String, @escaping SearchCompletion) -> Void
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = PrepaymentPickerEvent<Operator>
    typealias Effect = PrepaymentPickerEffect<Operator.ID>
}

private extension PrepaymentPickerEffectHandler {
    
    func paginate(
        _ payload: _PaginatePayload,
        _ dispatch: @escaping Dispatch
    ) {
        paginate(payload) { dispatch(.page($0)) }
    }
    
    func search(
        _ payload: String,
        _ dispatch: @escaping Dispatch
    ) {
        search(payload) { dispatch(.load($0)) }
    }
}
