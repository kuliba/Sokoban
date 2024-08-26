//
//  CategoryPickerSectionBinder.swift
//  ForaBank
//
//  Created by Igor Malyarov on 22.08.2024.
//

import PayHubUI

typealias CategoryPickerSectionBinder = PayHubUI.CategoryPickerSectionBinder<ServiceCategory, CategoryModel, CategoryListModel>

final class CategoryModel {
    
    let category: ServiceCategory
    
    init(category: ServiceCategory) {
     
        self.category = category
    }
}

final class CategoryListModel {}
