//
//  CategoryPickerSectionStateItemLabel.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 21.08.2024.
//

import PayHub
import SwiftUI

public protocol Named {
    
    var name: String { get }
}

public struct CategoryPickerSectionStateItemLabel<CategoryIcon, PlaceholderView, ServiceCategory>: View
where CategoryIcon: View,
      PlaceholderView: View,
      ServiceCategory: Named {
    
    private let item: Item
    private let config: Config
    private let categoryIcon: (ServiceCategory) -> CategoryIcon
    private let placeholderView: () -> PlaceholderView
    
    public init(
        item: Item, 
        config: Config,
        categoryIcon: @escaping (ServiceCategory) -> CategoryIcon,
        placeholderView: @escaping () -> PlaceholderView
    ) {
        self.item = item
        self.config = config
        self.categoryIcon = categoryIcon
        self.placeholderView = placeholderView
    }
    
    public var body: some View {
        
        switch item {
        case let .element(identified):
            switch identified.element {
            case let .category(category):
                categoryView(category)
                
            case .showAll:
                config.showAll.render()
            }
            
        case .placeholder:
            placeholderLabel()
        }
    }
}

public extension CategoryPickerSectionStateItemLabel {
    
    typealias Item = CategoryPickerSectionState<ServiceCategory>.Item
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
    
    func placeholderLabel() -> some View {
        
        HStack(spacing: config.placeholder.spacing) {
            
            placeholderView()
                .clipShape(RoundedRectangle(
                    cornerRadius: config.placeholder.icon.radius
                ))
                ._shimmering()
                .frame(config.placeholder.icon.size)
            
            placeholderView()
                .clipShape(RoundedRectangle(
                    cornerRadius: config.placeholder.title.radius
                ))
                ._shimmering()
                .frame(config.placeholder.title.size)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
