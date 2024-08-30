//
//  CategoryPickerSectionDestinationView.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 30.08.2024.
//

import SwiftUI
import PayHub

struct CategoryPickerSectionDestinationView: View {
    
    let destination: Destination
    
    var body: some View {
        
        switch destination {
        case let .category(categoryModelStub):
            Text("TBD: CategoryPickerSectionDestinationView for \(String(describing: categoryModelStub))")
            
        case let .list(plainCategoryPickerBinder):
            Text("TBD: CategoryPickerSectionDestinationView for \(String(describing: plainCategoryPickerBinder))")
        }
    }
}

extension CategoryPickerSectionDestinationView {
    
    typealias Destination = CategoryPickerSectionDestination<CategoryModelStub, PlainCategoryPickerBinder>
}
