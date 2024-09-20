//
//  SelectedCategoryStub.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 23.08.2024.
//

final class SelectedCategoryStub {
    
    let category: ServiceCategory
    let latest: [Latest]
    let operators: [Operator]
    
    init(
        category: ServiceCategory, 
        latest: [Latest],
        operators: [Operator]
    ) {
        self.category = category
        self.latest = latest
        self.operators = operators
    }
}
