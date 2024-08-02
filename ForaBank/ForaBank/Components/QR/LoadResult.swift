//
//  LoadResult.swift
//  ForaBank
//
//  Created by Igor Malyarov on 01.08.2024.
//

import ForaTools

enum LoadResult<Operator, Provider> {
    
    case mixed(Mixed)
    case multiple(MultipleOperators)
    case none
    case `operator`(Operator)
    case provider(Provider)
    
    typealias Mixed = MultiElementArray<OperatorProvider<Operator, Provider>>
    typealias MultipleOperators = MultiElementArray<Operator>
}

extension LoadResult: Equatable where Operator: Equatable, Provider: Equatable {}

extension LoadResult {
    
    init(
        operators: [Operator],
        providers: [Provider]
    ) {
        typealias Either = OperatorProvider<Operator, Provider>
        
        switch (MultiElementArray(operators), operators.first, MultiElementArray(providers), providers.first) {
            
            // 0, 0
        case (_, .none, _, .none):
            self = .none
            
            // 0, 1
        case let (.none, .none, .none, .some(provider)):
            self = .provider(provider)
            
            // 0, 2
        case let (.none, .none, .some(providers), _):
            let providers = providers.map(Either.provider)
            self = .mixed(providers)
            
            // 1, 0
        case let (.none, .some(`operator`), .none, .none):
            self = .operator(`operator`)
            
            // 1, 1
        case let (.none, .some(`operator`), .none, .some(provider)):
            self = .mixed(.init(.operator(`operator`), .provider(provider)))
            
            // 1, 2
        case let (.none, .some(`operator`), .some(providers), _):
            let operators = MultiElementArray(Either.operator(`operator`))
            let providers = providers.map(Either.provider)
            self = .mixed(operators + providers)
            
            // 2, 0
        case let (.some(operators), _,_, .none):
            self = .multiple(operators)
            
            // 2, 1
        case let (.some(operators), _, .none, .some(provider)):
            let operators = operators.map(Either.operator)
            let providers = MultiElementArray(Either.provider(provider))
            self = .mixed(operators + providers)
            
            // 2, 2
        case let (.some(operators), _, .some(providers), _):
            let operators = operators.map(Either.operator)
            let providers = providers.map(Either.provider)
            self = .mixed(operators + providers)
        }
    }
}
