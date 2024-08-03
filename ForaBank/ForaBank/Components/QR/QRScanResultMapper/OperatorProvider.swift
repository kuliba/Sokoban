//
//  OperatorProvider.swift
//  ForaBank
//
//  Created by Igor Malyarov on 02.08.2024.
//

enum OperatorProvider<Operator, Provider> {
    
    case `operator`(Operator)
    case provider(Provider)
}

extension OperatorProvider: Equatable where Operator: Equatable, Provider: Equatable {}
