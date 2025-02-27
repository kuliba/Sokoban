//
//  View+conditionalBottomPadding.swift
//  Vortex
//
//  Created by Igor Malyarov on 27.02.2025.
//

import SwiftUI

/**
 Applies conditional bottom padding to the view.
 
 This modifier adds bottom padding equal to `defaultPadding` only when the view does not have
 a bottom safe area inset (i.e. when `safeInsets.bottom` is 0). This is useful for ensuring that
 your content is padded appropriately on devices without a home indicator.
 
 - Parameter defaultPadding: The amount of padding to apply when there is no bottom safe area inset.
 Defaults to 20 points.
 - Returns: A view modified with conditional bottom padding.
 */
extension View {
    
    func conditionalBottomPadding(
        _ defaultPadding: CGFloat = 20
    ) -> some View {
        
        self.modifier(ConditionalBottomPadding(defaultPadding: defaultPadding))
    }
}

struct ConditionalBottomPadding: ViewModifier {
    
    @State private var safeInsets: EdgeInsets = EdgeInsets()
    
    var defaultPadding: CGFloat = 20
    
    func body(content: Content) -> some View {
        
        content
            .padding(.bottom, safeInsets.bottom > 0 ? 0 : defaultPadding)
            .background(
                GeometryReader { proxy in

                    Color.clear
                        .preference(
                            key: SafeAreaInsetsKey.self,
                            value: proxy.safeAreaInsets
                        )
                }
            )
            .onPreferenceChange(SafeAreaInsetsKey.self) { safeInsets = $0 }
    }
}

struct SafeAreaInsetsKey: PreferenceKey {
    
    static let defaultValue: EdgeInsets = EdgeInsets()
    
    static func reduce(
        value: inout EdgeInsets,
        nextValue: () -> EdgeInsets
    ) {
        let next = nextValue()
        
        value = EdgeInsets(
            top: max(value.top, next.top),
            leading: max(value.leading, next.leading),
            bottom: max(value.bottom, next.bottom),
            trailing: max(value.trailing, next.trailing)
        )
    }
}
