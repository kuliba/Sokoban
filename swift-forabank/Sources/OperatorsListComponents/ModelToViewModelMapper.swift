//
//  ModelToViewModelMapper.swift
//
//
//  Created by Дмитрий Савушкин on 12.02.2024.
//

import Foundation

public struct ModelToViewModelMapper {
    
    let action: (ComposedOperatorsEvent) -> Void
    
    public init(
        action: @escaping (ComposedOperatorsEvent) -> Void
    ) {
        self.action = action
    }
}

public extension ModelToViewModelMapper {
    
    func map(
        _ operator: Operator
    ) -> OperatorViewModel {
        
        return .init(
            icon: Data(),
            title: `operator`.title,
            description: `operator`.subtitle
        )
    }
}
