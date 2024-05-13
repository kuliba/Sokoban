//
//  PrepaymentPickerEffect.swift
//
//
//  Created by Igor Malyarov on 12.05.2024.
//

public enum PrepaymentPickerEffect<OperatorID> {
    
    case paginate(Paginate)
    case search(SearchPayload)
}

public extension PrepaymentPickerEffect {
    
    typealias Paginate = PaginatePayload<OperatorID>
}

extension PrepaymentPickerEffect: Equatable where OperatorID: Equatable {}
