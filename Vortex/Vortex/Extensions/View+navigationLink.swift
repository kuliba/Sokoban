//
//  View+navigationLink.swift
//  Vortex
//
//  Created by Igor Malyarov on 17.02.2025.
//

import SwiftUI

// TODO: - extract to UIPrimitives

extension View {
    
    func navigationLink<Value, V: View>(
        value: Value?,
        dismiss: @escaping () -> Void,
        content: (Value) -> V
    ) -> some View {
        
        background(NavigationLink(value: value, dismiss: dismiss, content: content))
    }
    
    func navigationLink<Value, V: View>(
        value: Binding<Value?>,
        content: (Value) -> V
    ) -> some View {
        
        background(NavigationLink(value: value, content: content))
    }
}

extension NavigationLink {
    
    init<Value, V: View>(
        value: Value?,
        dismiss: @escaping () -> Void,
        content: (Value) -> V
    ) where Label == Text, Destination == V? {
        
        self.init(
            value: .init(
                get: { value },
                set: { if $0 == nil { dismiss() }}
            ),
            content: content
        )
    }
    
    init<Value, V: View>(
        value: Binding<Value?>,
        content: (Value) -> V
    ) where Label == Text, Destination == V? {
        
        self.init(
            "",
            isActive: .init(
                get: { value.wrappedValue != nil },
                set: { if !$0 { value.wrappedValue = nil }}
            ),
            destination: { value.wrappedValue.map(content) }
        )
    }
}
