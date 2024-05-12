//
//  TestHelpers.swift
//
//
//  Created by Igor Malyarov on 12.05.2024.
//

import Foundation
import UtilityServicePrepaymentCore
import UtilityServicePrepaymentDomain

// MARK: - Types

struct LastPayment: Equatable {
    
    let value: String
}

struct Operator: Equatable & Identifiable {
    
    let id: String
}

typealias State = PrepaymentPickerState<LastPayment, Operator>
typealias Event = PrepaymentPickerEvent<Operator>
typealias Effect = PrepaymentPickerEffect<Operator.ID>

typealias EffectHandler = PrepaymentPickerEffectHandler<Operator>

// MARK: - Helpers

func makeEmptyState() -> State {
    
    makeState(operators: [])
}

func makeState(
    lastPayments: [LastPayment] = [],
    operators: [Operator] = [makeOperator()],
    searchText: String = "",
    isSearching: Bool = false
) -> State {
    
    return .init(
        lastPayments: lastPayments,
        operators: operators,
        searchText: searchText,
        isSearching: isSearching
    )
}

func makeLastPayment(
    _ value: String = UUID().uuidString
) -> LastPayment {
    
    .init(value: value)
}

func makeOperator(
    _ id: String = UUID().uuidString
) -> Operator {
    
    .init(id: id)
}

func makeOperatorID(
    _ id: String = UUID().uuidString
) -> Operator.ID {
    
    return id
}

func makePageSize(
) -> Effect.PaginatePayload.PageSize {
    
    Int.random(in: 1...(.max))
}

func makePaginateEffect(
    operatorID: Operator.ID? = makeOperatorID(),
    pageSize: Effect.PaginatePayload.PageSize = makePageSize(),
    searchText: String = ""
) -> Effect {
    
    .paginate(.init(
        operatorID: operatorID,
        pageSize: pageSize,
        searchText: searchText
    ))
}

func makePaginatePayload(
    operatorID: Operator.ID? = makeOperatorID(),
    pageSize: Effect.PaginatePayload.PageSize = makePageSize(),
    searchText: String = ""
) -> EffectHandler.PaginatePayload {
    
    .init(operatorID: operatorID, pageSize: pageSize, searchText: searchText)
}
