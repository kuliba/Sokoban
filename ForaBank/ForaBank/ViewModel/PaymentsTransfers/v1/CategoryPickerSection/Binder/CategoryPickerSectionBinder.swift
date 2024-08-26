//
//  CategoryPickerSectionBinder.swift
//  ForaBank
//
//  Created by Igor Malyarov on 22.08.2024.
//

import PayHubUI

typealias CategoryPickerSectionBinder = PayHubUI.CategoryPickerSectionBinder<ServiceCategory, CategoryModelStub, CategoryListModelStub>

final class CategoryModelStub {
    
    let category: ServiceCategory
    
    init(category: ServiceCategory) {
     
        self.category = category
    }
}

final class CategoryListModelStub {}
