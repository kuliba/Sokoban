//
//  PrepaymentPickerMicroServices.swift
//  ForaBank
//
//  Created by Igor Malyarov on 14.05.2024.
//

import UtilityServicePrepaymentDomain

public struct PrepaymentPickerMicroServices<Operator>
where Operator: Identifiable{
    
    public let paginate: Paginate
    public let search: Search
    
    public init(
        paginate: @escaping Paginate,
        search: @escaping Search
    ) {
        self.paginate = paginate
        self.search = search
    }
}

public extension PrepaymentPickerMicroServices {
    
    typealias _PaginatePayload = PaginatePayload<Operator.ID>
    typealias PaginateResult = [Operator]
    typealias PaginateCompletion = (PaginateResult) -> Void
    typealias Paginate = (_PaginatePayload, @escaping PaginateCompletion) -> Void
    
    typealias SearchResult = [Operator]
    typealias SearchCompletion = (SearchResult) -> Void
    typealias Search = (String, @escaping SearchCompletion) -> Void
}
