//
//  BottomSheetView.swift
//  SwiftUiTest
//
//  Created by Max Gribov on 18.07.2022.
//

import SwiftUI
import Combine
import BottomSheetComponent

protocol BottomSheetCustomizable: Identifiable {
    
    var animationSpeed: Double { get }
    var isUserInteractionEnabled: CurrentValueSubject<Bool, Never> { get }
}

extension BottomSheetCustomizable {
    
    var animationSpeed: Double { 0.5 }
    var isUserInteractionEnabled: CurrentValueSubject<Bool, Never> { .init(true) }
}

// MARK: - View Extensions

extension View {

    func bottomSheet<Item, Content>(item: Binding<Item?>, animationSpeed: Double = 0.5, @ViewBuilder content: @escaping (Item) -> Content) -> some View where Item : BottomSheetCustomizable, Content : View {
        
        return modifier(
            BottomSheetItemModifier(
                item: item,
                animationSpeed: item.wrappedValue?.animationSpeed ?? animationSpeed,
                sheetContent: content
            )
        )
    }
}
