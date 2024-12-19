//
//  UtilityPrepaymentNanoServices.swift
//  Vortex
//
//  Created by Igor Malyarov on 14.05.2024.
//


struct UtilityPrepaymentNanoServices<Operator>
where Operator: Identifiable {
    
    /// Load cached operators.
    let loadOperators: LoadOperators
}

extension UtilityPrepaymentNanoServices {
    
    typealias LoadOperatorsCompletion = ([Operator]) -> Void
    typealias LoadOperators = (LoadOperatorsPayload, @escaping LoadOperatorsCompletion) -> Void
}

