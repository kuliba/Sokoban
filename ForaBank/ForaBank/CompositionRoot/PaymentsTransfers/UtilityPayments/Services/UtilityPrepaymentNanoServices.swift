//
//  UtilityPrepaymentNanoServices.swift
//  ForaBank
//
//  Created by Igor Malyarov on 14.05.2024.
//

struct UtilityPrepaymentNanoServices<Operator>
where Operator: Identifiable {
    
    /// Load cached operators.
    let loadOperators: LoadOperators
}

extension UtilityPrepaymentNanoServices {
    
    struct LoadOperatorsPayload: Equatable {
        
        let operatorID: Operator.ID?
        let searchText: String
        let pageSize: Int
        
        init(
            afterOperatorID operatorID: Operator.ID?,
            searchText: String,
            pageSize: Int
        ) {
            self.operatorID = operatorID
            self.searchText = searchText
            self.pageSize = pageSize
        }
    }
    
    typealias LoadOperatorsCompletion = ([Operator]) -> Void
    typealias LoadOperators = (LoadOperatorsPayload, @escaping LoadOperatorsCompletion) -> Void
}
