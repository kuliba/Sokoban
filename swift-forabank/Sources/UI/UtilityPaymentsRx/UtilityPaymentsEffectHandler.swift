//
//  UtilityPaymentsEffectHandler.swift
//
//
//  Created by Igor Malyarov on 19.02.2024.
//

public final class UtilityPaymentsEffectHandler {
    
    private let loadLastPayments: LoadLastPayments
    private let loadOperators: LoadOperators
    private let paginate: Paginate
    private let scheduler: AnySchedulerOfDispatchQueue
    
    public init(
        loadLastPayments: @escaping LoadLastPayments,
        loadOperators: @escaping LoadOperators,
        paginate: @escaping Paginate,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
        self.loadLastPayments = loadLastPayments
        self.loadOperators = loadOperators
        self.paginate = paginate
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
            
        case .paginate:
            paginate(dispatch)
        }
    }
}

public extension UtilityPaymentsEffectHandler {
    
    typealias LoadLastPaymentsCompletion = (LoadLastPaymentsResult) -> Void
    typealias LoadLastPayments = (@escaping LoadLastPaymentsCompletion) -> Void
    
    typealias LoadOperatorsCompletion = (LoadOperatorsResult) -> Void
    typealias LoadOperators = (@escaping LoadOperatorsCompletion) -> Void
    
    typealias PaginateCompletion = ([Operator]) -> Void
    typealias Paginate = (@escaping PaginateCompletion) -> Void
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = UtilityPaymentsEvent
    typealias Effect = UtilityPaymentsEffect
}

private extension UtilityPaymentsEffectHandler {
    
    func initiate(
        _ dispatch: @escaping Dispatch
    ) {
        loadLastPayments { dispatch(.loaded(.lastPayments($0))) }
        loadOperators { dispatch(.loaded(.operators($0))) }
    }
    
    func paginate(
        _ dispatch: @escaping Dispatch
    ) {
        paginate { dispatch(.paginated($0)) }
    }
}
