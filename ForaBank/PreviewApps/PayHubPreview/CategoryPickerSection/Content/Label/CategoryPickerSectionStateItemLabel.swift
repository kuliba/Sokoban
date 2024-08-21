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
                categoryView(category)
                
            case .showAll:
                config.showAll.render()
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

private extension CategoryPickerSectionStateItemLabel {
    
    func categoryView(
        _ category: ServiceCategory
    ) -> some View {
        
        HStack(spacing: config.spacing) {
            
            Color.blue.opacity(0.1)
                .frame(config.iconSize)
                .renderIconBackground(with: config.iconBackground)
            
            category.name.text(withConfig: config.title)
        }
    }
}
