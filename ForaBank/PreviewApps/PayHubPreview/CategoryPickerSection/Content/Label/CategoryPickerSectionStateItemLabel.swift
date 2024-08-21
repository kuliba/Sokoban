//
//  CategoryPickerSectionStateItemLabel.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 21.08.2024.
//

import SwiftUI

struct CategoryPickerSectionStateItemLabel<CategoryIcon>: View
where CategoryIcon: View {
    
    let item: Item
    let config: Config
    let categoryIcon: (ServiceCategory) -> CategoryIcon
    
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
            
            categoryIcon(category)
                .frame(config.iconSize)
                .renderIconBackground(with: config.iconBackground)
            
            category.name.text(withConfig: config.title)
        }
    }
}
