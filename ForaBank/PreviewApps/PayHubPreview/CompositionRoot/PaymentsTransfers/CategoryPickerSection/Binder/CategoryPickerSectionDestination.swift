//
//  CategoryPickerSectionDestination.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 30.08.2024.
//

import PayHub

typealias CategoryPickerSectionDestination = PayHub.CategoryPickerSectionDestination<CategoryPickerDestination, PlainCategoryPickerBinder>


enum CategoryPickerDestination {
    
    case ok(CategoryModelStub)
    case failure(String)
}
