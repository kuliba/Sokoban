//
//  CategoryPickerSectionContentView.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 21.08.2024.
//

import SwiftUI

struct CategoryPickerSectionContentView<ItemLabel>: View
where ItemLabel: View {
    
    let state: State
    let event: (Event) -> Void
    @ViewBuilder let itemLabel: (State.Item) -> ItemLabel
    
    private let transition: AnyTransition = .opacity.combined(with: .scale)
    
    var body: some View {
        
        if state.isLoadingFailed {
            Text("Failed to load categories")
                .foregroundColor(.red)
        } else {
            VStack {
                
                state.showAll.map {
                    
                    itemView(item: $0)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                
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
}

private extension CategoryPickerSectionState {
    
    var isLoadingFailed: Bool {
        
        !isLoading && categories.isEmpty
    }
    
    var categories: [Item] {
        
        items.filter { $0.case == .category }
    }
    
    var itemsWithoutShowAll: [Item] {
        
        items.filter { $0.case != .showAll }
    }
    
    var showAll: Item? {
        
        items.filter { $0.case == .showAll }.first
    }
}

private extension CategoryPickerSectionState.Item {
    
    var `case`: CategoryPickerSectionItem.Case? {
        
        guard case let .element(identified) = self
        else { return nil }
        
        return identified.element.case
    }
}

extension CategoryPickerSectionItem {
    
    var `case`: Case {
        
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
            
        case let .element(element):
            switch element.element {
            case let .category(category):
                Button {
                    event(.select(.category(category)))
                } label: {
                    label
                }
                .buttonStyle(.plain)
                
            case .showAll:
                Button {
                    event(.select(.showAll))
                } label: {
                    label
                }
                .buttonStyle(.plain)
            }
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
