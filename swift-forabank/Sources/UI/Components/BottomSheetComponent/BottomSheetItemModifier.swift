//
//  BottomSheetItemModifier.swift
//  
//
//  Created by Valentin Ozerov on 11.12.2024.
//

import SwiftUI

public struct BottomSheetItemModifier<SheetContent: View, Item: Identifiable>: ViewModifier {
    
    @Binding var item: Item?
    
    let animationSpeed: Double
    let sheetContent: (Item) -> SheetContent
    
    @State private var isUserInteractionEnabled: Bool = true
    
    public init(
        item: Binding<Item?>,
        animationSpeed: Double,
        @ViewBuilder sheetContent: @escaping (Item) -> SheetContent
    ) {
        self._item = item
        self.animationSpeed = animationSpeed
        self.sheetContent = sheetContent
    }
    
    var isPresented: Binding<Bool> {
        
        .init(
            get: { item != nil },
            set: { if !$0 { item = nil }}
        )
    }
    
    public func body(content: Content) -> some View {
        
        content
            .transaction({ $0.disablesAnimations = false })
            .fullScreenCover(item: $item, content: {
                
                BottomSheetView(
                    isPresented: isPresented,
                    animationSpeed: animationSpeed,
                    content: sheetContent($0))
            })
            .transaction({ $0.disablesAnimations = true })
    }
}
