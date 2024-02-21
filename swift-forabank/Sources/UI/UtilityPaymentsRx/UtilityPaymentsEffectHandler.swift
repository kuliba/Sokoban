//
//  UtilityPaymentsEffectHandler.swift
//
//
//  Created by Igor Malyarov on 19.02.2024.
//

import Foundation

public final class UtilityPaymentsEffectHandler<LastPayment, Operator>
where LastPayment: Equatable & Identifiable,
      Operator: Equatable & Identifiable {
    
    private let debounce: DispatchTimeInterval
    private let loadLastPayments: LoadLastPayments
    private let loadOperators: LoadOperators
    private let scheduler: AnySchedulerOfDispatchQueue
    
    public init(
        debounce: DispatchTimeInterval = .milliseconds(300),
        loadLastPayments: @escaping LoadLastPayments,
        loadOperators: @escaping LoadOperators,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
        self.debounce = debounce
        self.loadLastPayments = loadLastPayments
        self.loadOperators = loadOperators
        self.scheduler = scheduler
    }
}

public extension UtilityPaymentsEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case .initiate:
            initiate(dispatch)
            
        case let .paginate(operatorID, pageSize):
            paginate(operatorID, pageSize, dispatch)
            
        case let .search(text):
            search(text, dispatch)
        }
    }
}

public extension UtilityPaymentsEffectHandler {
    
    typealias LoadLastPaymentsResult = Result<[LastPayment], ServiceFailure>
    typealias LoadLastPaymentsCompletion = (LoadLastPaymentsResult) -> Void
    typealias LoadLastPayments = (@escaping LoadLastPaymentsCompletion) -> Void
    
    typealias PageSize = Int
    typealias LoadOperatorsPayload = (Operator.ID, PageSize)
    typealias LoadOperatorsResult = Result<[Operator], ServiceFailure>
    typealias LoadOperatorsCompletion = (LoadOperatorsResult) -> Void
    typealias LoadOperators = (LoadOperatorsPayload?, @escaping LoadOperatorsCompletion) -> Void
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = UtilityPaymentsEvent<LastPayment, Operator>
    typealias Effect = UtilityPaymentsEffect<Operator>
}

private extension UtilityPaymentsEffectHandler {
    
    func initiate(
        _ dispatch: @escaping Dispatch
    ) {
        loadLastPayments { dispatch(.loaded(.lastPayments($0))) }
        loadOperators(nil) { dispatch(.loaded(.operators($0))) }
    }
    
    func paginate(
        _ operatorID: Operator.ID,
        _ pageSize: Int,
        _ dispatch: @escaping Dispatch
    ) {
        loadOperators((operatorID, pageSize)) {
            dispatch(.paginated($0)) }
    }
    
    func search(
        _ searchText: String,
        _ dispatch: @escaping Dispatch
    ) {
        scheduler.schedule(after: .init(.now() + debounce)) {
            
            dispatch(.search(.updated(searchText)))
        }
    }
}
