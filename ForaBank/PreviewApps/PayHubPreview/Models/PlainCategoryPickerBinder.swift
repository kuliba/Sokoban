//
//  PlainCategoryPickerBinder.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 23.08.2024.
//

final class PlainCategoryPickerBinder {
    
    let categories: [ServiceCategory]
    
    init(categories: [ServiceCategory]) {
     
        self.categories = categories
    }
}

final class PlainCategoryPickerBinderComposer {
    
    func compose(
        categories: [ServiceCategory]
    ) -> PlainCategoryPickerBinder {
        
        return .init(categories: categories)
    }
}
