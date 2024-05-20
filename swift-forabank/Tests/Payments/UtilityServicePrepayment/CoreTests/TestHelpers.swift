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
    searchText: String = ""
) -> State {
    
    return .init(
        lastPayments: lastPayments,
        operators: operators,
        searchText: searchText
    )
}

func makeLastPayment(
    _ value: String = anyMessage()
) -> LastPayment {
    
    .init(value: value)
}

func makeOperator(
    _ id: String = anyMessage()
) -> Operator {
    
    .init(id: id)
}

func makeOperatorID(
    _ id: String = anyMessage()
) -> Operator.ID {
    
    return id
}

func makePaginateEffect(
    operatorID: Operator.ID = makeOperatorID(),
    searchText: String = ""
) -> Effect {
    
    .paginate(makePaginatePayload(
        operatorID: operatorID,
        searchText: searchText
    ))
}

func makePaginatePayload(
    operatorID: Operator.ID = makeOperatorID(),
    searchText: String = ""
) -> PaginatePayload<Operator.ID> {
    
    .init(operatorID: operatorID, searchText: searchText)
}

func makeSearchEffect(
    searchText: String = ""
) -> Effect {
    
    .search(searchText)
}
