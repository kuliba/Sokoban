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
      ServiceCategory: Named & Identifiable {
    
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
            categoryView(identified.element)
            
        case .placeholder:
            placeholderLabel()
        }
    }
}

public extension CategoryPickerSectionStateItemLabel {
    
    typealias Domain = CategoryPickerContentDomain<ServiceCategory>
    typealias Item = Domain.State.Item
    typealias Config = CategoryPickerSectionStateItemLabelConfig
}

private extension CategoryPickerSectionStateItemLabel {
    
    func categoryView(
        _ stateful: Stateful<ServiceCategory, LoadState>
    ) -> some View {
        
        HStack(spacing: config.spacing) {
            
            categoryIcon(stateful.entity)
                .frame(config.iconSize)
                .renderIconBackground(with: config.iconBackground)
            
            label(stateful)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    @ViewBuilder
    func label(
        _ stateful: Stateful<ServiceCategory, LoadState>
    ) -> some View {
        
        stateful.entity.name.text(withConfig: config.title)
            .stateful(state: stateful.state)
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

private extension View {
    
    @ViewBuilder
    func stateful(
        state: LoadState
    ) -> some View {
        
        switch state {
        case .completed: self
        case .failed:    self
        case .loading:   self._shimmering()
        case .pending:   self.opacity(0.5)
        }
    }
}
