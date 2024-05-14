//
//  UtilityPrepaymentNanoServices.swift
//  ForaBank
//
//  Created by Igor Malyarov on 14.05.2024.
//

import OperatorsListComponents

struct UtilityPrepaymentNanoServices<Operator>
where Operator: Identifiable {
    
    /// Load cached operators.
    let loadOperators: LoadOperators
}

extension UtilityPrepaymentNanoServices {
    
    
    typealias _LoadOperatorsPayload = LoadOperatorsPayload<Operator.ID>
    typealias LoadOperatorsCompletion = ([Operator]) -> Void
    typealias LoadOperators = (_LoadOperatorsPayload, @escaping LoadOperatorsCompletion) -> Void

}
