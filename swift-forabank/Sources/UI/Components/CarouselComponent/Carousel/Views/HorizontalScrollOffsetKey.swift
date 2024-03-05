//
//  HorizontalScrollOffsetKey.swift
//
//
//  Created by Disman Dmitry on 20.02.2024.
//

import SwiftUI
import Combine

struct HorizontalScrollOffsetKey: PreferenceKey {
    
    static var defaultValue = CGFloat.zero
    
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}

extension View {
    
    func onHorizontalScroll(
        in coordinateSpace: CoordinateSpace,
        completion: @escaping (CGFloat) -> Void
    ) -> some View {
        
        modifier(OnHorizontalScroll(
            coordinateSpace: coordinateSpace,
            completion: completion)
        )
    }
}

struct OnHorizontalScroll: ViewModifier {
    
    let coordinateSpace: CoordinateSpace
    let completion: (CGFloat) -> Void
    
    private let scrollViewVerticalOffset = CurrentValueSubject<CGFloat, Never>(0)
    
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader(content: { geometry in
                    
                    Color.clear
                        .preference(
                            key: HorizontalScrollOffsetKey.self,
                            value: abs(geometry.frame(in: coordinateSpace).origin.x)
                    )
                })
            )
            .onPreferenceChange(HorizontalScrollOffsetKey.self, perform: scrollViewVerticalOffset.send(_:))
            .onReceive(scrollViewVerticalOffset, perform: completion)
    }
}
