//
//  ExpandablePicker.swift
//  AnywayPaymentPreview
//
//  Created by Igor Malyarov on 13.04.2024.
//

import SwiftUI

struct ExpandablePicker<ID, Item, ItemView>: View
where ID: Hashable,
      Item: Equatable,
      ItemView: View {
    
    let state: State
    let event: (Event) -> Void
    let keyPath: KeyPath<Item, ID>
    let itemView: (Item) -> ItemView
    
    var body: some View {
        
        VStack {
            
            HStack {
                
                _itemView(state.selection)
                
                Button("toggle", action: { event(.toggle) })
            }
            
            if isVisible {
                
                VStack {
                    
                    ForEach(state.items, id: keyPath, content: selectableItemView)
                }
                .animation(.easeInOut, value: state)
            }
        }
    }
    
    private var isVisible: Bool {
        
        state.toggle == .expanded
    }
    
    private func _itemView(_ item: Item) -> some View {
        
        itemView(item)
            .font(.headline.weight(item == state.selection ? .bold : .medium))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 3)
    }
    
    private func selectableItemView(item: Item) -> some View {
        
        _itemView(item)
            .contentShape(Rectangle())
            .onTapGesture { event(.select(item)) }
    }
}

extension ExpandablePicker {
    
    typealias State = ExpandablePickerState<Item>
    typealias Event = ExpandablePickerEvent<Item>
}

extension ExpandablePicker where ID == Item, Item: Hashable {
    
    init(
        state: State,
        event: @escaping (Event) -> Void,
        itemView: @escaping (Item) -> ItemView
    ) {
        
        self.init(state: state, event: event, keyPath: \.self, itemView: itemView)
    }
}

extension ExpandablePicker where ID == Item.ID, Item: Identifiable {
    
    init(
        state: State,
        event: @escaping (Event) -> Void,
        itemView: @escaping (Item) -> ItemView
    ) {
        
        self.init(state: state, event: event, keyPath: \.id, itemView: itemView)
    }
}

struct ExpandablePicker_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ExpandablePicker(
            state: .preview,
            event: { _ in },
            itemView: { Text($0) }
        )
        .padding()
    }
}
