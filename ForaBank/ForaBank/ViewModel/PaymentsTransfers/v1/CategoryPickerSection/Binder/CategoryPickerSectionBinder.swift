//
//  CategoryPickerSectionBinder.swift
//  ForaBank
//
//  Created by Igor Malyarov on 22.08.2024.
//

import PayHubUI

typealias CategoryPickerSectionBinder = PayHubUI.CategoryPickerSectionBinder<ServiceCategory, SelectedCategoryDestination, CategoryListModelStub>

final class CategoryListModelStub {
    
    let categories: [ServiceCategory]
    
    init(categories: [ServiceCategory]) {
     
        self.categories = categories
    }
}
