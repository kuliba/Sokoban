//
//  CategoryPickerSectionBinder.swift
//  ForaBank
//
//  Created by Igor Malyarov on 22.08.2024.
//

import PayHubUI

typealias CategoryPickerSectionBinder = PayHubUI.CategoryPickerSectionBinder<ServiceCategory, SelectedCategoryDestination, CategoryListModelStub>

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

final class CategoryListModelStub {
    
    let categories: [ServiceCategory]
    
    init(categories: [ServiceCategory]) {
     
        self.categories = categories
    }
}
