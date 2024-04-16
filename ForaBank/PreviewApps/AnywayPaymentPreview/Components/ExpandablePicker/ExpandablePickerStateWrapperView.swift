//
//  ExpandablePickerStateWrapperView.swift
//  AnywayPaymentPreview
//
//  Created by Igor Malyarov on 13.04.2024.
//

import SwiftUI

struct ExpandablePickerStateWrapperView<Item, ItemView>: View
where Item: Hashable,
      ItemView: View {
    
    @StateObject var viewModel: ExpandablePickerViewModel<Item>
    
    let itemView: (Item) -> ItemView
    
    var body: some View {
        
        ExpandablePicker(
            state: viewModel.state,
            event: viewModel.event(_:),
            itemView: itemView
        )
    }
}

struct ExpandablePickerStateWrapperView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ExpandablePickerStateWrapperView(
            viewModel: .preview,
            itemView: { Text($0) }
        )
        .padding()
    }
}
