//
//  ExpandablePicker.swift
//  AnywayPaymentPreview
//
//  Created by Igor Malyarov on 13.04.2024.
//

import SwiftUI

struct ExpandablePicker<Item, ItemView>: View
where Item: Hashable,
      ItemView: View {
    
    let state: State
    let event: (Event) -> Void
    
    let itemView: (Item) -> ItemView
    
    var body: some View {
        
        VStack {
            
            HStack {
                
                _itemView(state.selection)
                
                Button("toggle", action: { event(.toggle) })
            }
            
            if isVisible {
                
                VStack {
                    
                    ForEach(state.items, id: \.self, content: selectableItemView)
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
