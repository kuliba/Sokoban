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
            placeholderView()
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
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    func placeholderView() -> some View {
        
        HStack(spacing: config.placeholder.spacing) {
            
            PlaceholderView(opacity: 0.5)
                .clipShape(RoundedRectangle(
                    cornerRadius: config.placeholder.icon.radius
                ))
                ._shimmering()
                .frame(config.placeholder.icon.size)
            
            PlaceholderView(opacity: 0.5)
                .clipShape(RoundedRectangle(
                    cornerRadius: config.placeholder.title.radius
                ))
                ._shimmering()
                .frame(config.placeholder.title.size)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
