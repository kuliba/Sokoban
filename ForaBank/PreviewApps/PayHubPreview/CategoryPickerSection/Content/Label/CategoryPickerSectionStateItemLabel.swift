//
//  CategoryPickerSectionStateItemLabel.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 21.08.2024.
//

import SwiftUI

struct CategoryPickerSectionStateItemLabel: View {
    
    let item: Item
    let config: Config
    
    var body: some View {
        
        switch item {
        case let .element(identified):
            switch identified.element {
            case let .category(category):
                Label { Text(category.name) } icon: { Text("...") }
                
            case .showAll:
                Text("Show All")
                    .font(.subheadline)
            }
            
        case .placeholder:
            ProgressView()
        }
    }
}

extension CategoryPickerSectionStateItemLabel {
    
    typealias Item = CategoryPickerSectionState.Item
    typealias Config = CategoryPickerSectionStateItemLabelConfig
}
