//
//  OperatorProvider.swift
//  
//
//  Created by Igor Malyarov on 08.11.2024.
//

public enum OperatorProvider<Operator, Provider> {
    
    case `operator`(Operator)
    case provider(Provider)
}

extension OperatorProvider: Equatable where Operator: Equatable, Provider: Equatable {}
