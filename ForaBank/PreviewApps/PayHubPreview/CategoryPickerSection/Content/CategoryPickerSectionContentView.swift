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
            List {
                
                ForEach(state.items, content: itemView)
            }
            .listStyle(PlainListStyle())
        }
    }
}

extension CategoryPickerSectionContentView {
    
    typealias State = CategoryPickerSectionState
    typealias Event = CategoryPickerSectionEvent
}

private extension CategoryPickerSectionState {
    
    var isLoadingFailed: Bool {
        
        !isLoading && items.isEmpty
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
                .buttonStyle(PlainButtonStyle())
                
            case .showAll:
                Button {
                    event(.select(.showAll))
                } label: {
                    label
                }
                .buttonStyle(PlainButtonStyle())
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
