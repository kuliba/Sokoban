//
//  CategoryPickerSectionContentView.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 21.08.2024.
//

import SharedConfigs
import SwiftUI

struct CategoryPickerSectionContentView<ItemLabel>: View
where ItemLabel: View {
    
    let state: State
    let event: (Event) -> Void
    let config: Config
    @ViewBuilder let itemLabel: (State.Item) -> ItemLabel
    
    private let transition: AnyTransition = .opacity.combined(with: .scale)
    
    var body: some View {
        
        if state.isLoadingFailed {
            Text("Failed to load categories")
                .foregroundColor(.red)
        } else {
            VStack {
                
                sectionHeader()
                    .frame(height: config.headerHeight)
                
                List {
                    
                    ForEach(state.itemsWithoutShowAll, content: itemView)
                }
                .listStyle(.plain)
            }
        }
    }
}

extension CategoryPickerSectionContentView {
    
    typealias State = CategoryPickerSectionState
    typealias Event = CategoryPickerSectionEvent
    typealias Config = CategoryPickerSectionContentViewConfig
}

private extension CategoryPickerSectionState {
    
    var isLoadingFailed: Bool {
        
        !isLoading && categories.isEmpty
    }
    
    private var categories: [Item] {
        
        items.filter { $0._case == .category }
    }
    
    var itemsWithoutShowAll: [Item] {
        
        items.filter { $0._case != .showAll }
    }
    
    var showAll: Item? {
        
        items.filter { $0._case == .showAll }.first
    }
}

private extension CategoryPickerSectionState.Item {
    
    var _case: CategoryPickerSectionItem.Case? {
        
        guard case let .element(identified) = self
        else { return nil }
        
        return identified.element._case
    }
}

extension CategoryPickerSectionItem {
    
    var _case: Case {
        
        switch self {
        case .category: return .category
        case .showAll:  return .showAll
        }
    }
    
    enum Case {
        
        case category, showAll
    }
}

private extension CategoryPickerSectionContentView {
    
    func sectionHeader() -> some View {
        
        HStack {
            
            if state.isLoading {
                titlePlaceholder(config: config.titlePlaceholder)
            } else {
                config.title.render()
            }
            
            Spacer()
            
            state.showAll.map(itemView(item:))
        }
    }
    
    private func titlePlaceholder(
        config: CategoryPickerSectionContentViewConfig.TitlePlaceholder
    ) -> some View {
        
        config.color
            .clipShape(RoundedRectangle(cornerRadius: config.radius))
            .frame(config.size)
            ._shimmering()
    }
    
    @ViewBuilder
    func itemView(
        item: State.Item
    ) -> some View {
        
        let label = itemLabel(item)
            .contentShape(Rectangle())
            .transition(transition(for: item))
        
        switch item {
        case .placeholder:
            label
            
        case let .element(identified):
            Button {
                event(.select(identified.element))
            } label: {
                label
            }
            .buttonStyle(.plain)
        }
    }
    
    func transition(
        for item: State.Item
    ) -> AnyTransition {
        
        switch item {
        case .placeholder:
            return transition
            
        case .element:
            return transition
        }
    }
}

struct CategoryPickerSectionContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            categoryPickerSectionContentView(.placeholders(count: 5))
            categoryPickerSectionContentView(.preview)
            categoryPickerSectionContentView(.placeholders(count: 0))
        }
    }
    
    private static func categoryPickerSectionContentView(
        _ items: [CategoryPickerSectionState.Item]
    ) -> some View {
        
        CategoryPickerSectionContentView(
            state: .init(prefix: items, suffix: []),
            event: { print($0) },
            config: .preview,
            itemLabel: {
                
                CategoryPickerSectionStateItemLabel(
                    item: $0,
                    config: .preview,
                    categoryIcon: { _ in  Color.blue.opacity(0.1) }
                )
            }
        )
    }
}

extension Array where Element == CategoryPickerSectionState.Item {
    
    static func placeholders(count: Int) -> Self {
        
        (0..<count).map { _ in .placeholder(.init()) }
    }
    
    static var preview: Self {
        
        [.element(.init(.showAll))] + [ServiceCategory].preview.map { .element(.init(.category($0))) }
    }
}
