//
//  CategoryPickerSectionBinder.swift
//  ForaBank
//
//  Created by Igor Malyarov on 22.08.2024.
//

import PayHubUI

typealias CategoryPickerSectionBinder = PayHubUI.CategoryPickerSectionBinder<ServiceCategory, SelectedCategoryStub, CategoryListModelStub>

final class SelectedCategoryStub {
    
    let category: ServiceCategory
    
    init(category: ServiceCategory) {
     
        self.category = category
    }
}

final class CategoryListModelStub {
    
    let categories: [ServiceCategory]
    
    init(categories: [ServiceCategory]) {
     
        self.categories = categories
    }
}
