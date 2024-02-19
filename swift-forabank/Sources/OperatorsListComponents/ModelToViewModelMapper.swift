//
//  ModelToViewModelMapper.swift
//
//
//  Created by Дмитрий Савушкин on 12.02.2024.
//

import Foundation

public struct ModelToViewModelMapper {
    
    let action: (Event) -> Void
    
    public init(
        action: @escaping (Event) -> Void
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
            description: `operator`.subtitle,
            action: {}
        )
    }
}
