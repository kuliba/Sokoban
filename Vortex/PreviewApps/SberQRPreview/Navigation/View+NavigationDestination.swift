//
//  View+NavigationDestination.swift
//
//
//  Created by Andryusina Nataly on 15.09.2023.
//

import SwiftUI

extension View {
    
    func navigationDestination<Item: Identifiable, Content: View>(
        _ titleKey: LocalizedStringKey = "",
        item: Binding<Item?>,
        @ViewBuilder content: @escaping (Item) -> Content
    ) -> some View {
       
        self.background(
            NavigationLink(
                titleKey,
                isActive: .init(
                    get: { item.wrappedValue != nil },
                    set: { if !$0 { item.wrappedValue = nil }}
                ),
                destination: {
                    item.wrappedValue.map(content)
                }
            )
        )
    }
}
