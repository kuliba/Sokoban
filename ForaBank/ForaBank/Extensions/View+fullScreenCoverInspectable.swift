//
//  View+fullScreenCoverInspectable.swift
//  ForaBank
//
//  Created by Igor Malyarov on 17.11.2024.
//

import SwiftUI

/// For use with ViewInspector.
extension View {
    
    func fullScreenCoverInspectable<Item, FullScreenCover>(
        item: @escaping () -> Item?,
        dismiss: @escaping () -> Void,
        content: @escaping (Item) -> FullScreenCover
    ) -> some View where Item: Identifiable, FullScreenCover: View{
        
        return fullScreenCoverInspectable(
            item: .init(
                get: item,
                set: { if $0 == nil { dismiss() }}
            ),
            content: content
        )
    }
    
    func fullScreenCoverInspectable<Item, FullScreenCover>(
        item: Binding<Item?>,
        onDismiss: (() -> Void)? = nil,
        content: @escaping (Item) -> FullScreenCover
    ) -> some View where Item: Identifiable, FullScreenCover: View{
        
        return self.modifier(InspectableFullScreenCoverWithItem(
            item: item,
            onDismiss: onDismiss,
            popupBuilder: content
        ))
    }
}

struct InspectableFullScreenCoverWithItem<Item, FullScreenCover>: ViewModifier
where Item: Identifiable,
      FullScreenCover: View {
    
    let item: Binding<Item?>
    let onDismiss: (() -> Void)?
    let popupBuilder: (Item) -> FullScreenCover
    
    func body(content: Self.Content) -> some View {
        
        content.fullScreenCover(item: item, onDismiss: onDismiss, content: popupBuilder)
    }
}
