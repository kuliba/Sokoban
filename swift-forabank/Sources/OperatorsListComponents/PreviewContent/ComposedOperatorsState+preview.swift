//
//  ComposedOperatorsState+preview.swift
//
//
//  Created by Igor Malyarov on 11.05.2024.
//

extension ComposedOperatorsState
where LastPayment == OperatorsListComponents.LastPayment,
      Operator == OperatorsListComponents.Operator<String> {
    
    static var preview: Self {
        
        return .init(
            lastPayments: .preview,
            operators: .preview,
            searchText: "abc"
        )
    }
}
