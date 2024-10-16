//
//  RefreshModifier.swift
//  
//
//  Created by Andryusina Nataly on 24.09.2024.
//

import SwiftUI

public struct RefreshModifier: ViewModifier {
    
    let action: () -> Void
    let nameCoordinateSpace: String
    let offsetForStartUpdate: CGFloat
    
    public init(
        action: @escaping () -> Void,
        nameCoordinateSpace: String = "scroll",
        offsetForStartUpdate: CGFloat = -100
    ) {
        self.action = action
        self.nameCoordinateSpace = nameCoordinateSpace
        self.offsetForStartUpdate = offsetForStartUpdate
    }
    
    public func body(content: Content) -> some View {
        
        ScrollView(showsIndicators: false) {
            
            content
                .background(GeometryReader { geo in
                    
                    Color.clear
                        .preference(
                            key: ScrollOffsetKey.self,
                            value: -geo.frame(in: .named(nameCoordinateSpace)).origin.y)
                    
                })
                .onPreferenceChange(ScrollOffsetKey.self) {
                    
                    if $0 < offsetForStartUpdate {
                        action()
                    }
                }
        }
        .coordinateSpace(name: nameCoordinateSpace)
    }
    
    struct ScrollOffsetKey: PreferenceKey {
        
        typealias Value = CGFloat
        static var defaultValue: CGFloat { .zero }
        static func reduce(
            value: inout Value,
            nextValue: () -> Value
        ) {
            value += nextValue()
        }
    }
}
