//
//  OffsetObservingScrollView.swift
//
//
//  Created by Andryusina Nataly on 15.10.2024.
//

import Foundation
import SwiftUI

public struct OffsetObservingScrollView<Content: View>: View {
    
    private let axes: Axis.Set
    private let showsIndicators: Bool
    private let coordinateSpaceName: UUID
    
    @Binding var offset: CGPoint
    @ViewBuilder var content: () -> Content
    
    public init(
        axes: Axis.Set,
        showsIndicators: Bool,
        offset: Binding<CGPoint>,
        coordinateSpaceName: UUID = UUID(),
        content: @escaping () -> Content
    ) {
        self.axes = axes
        self.showsIndicators = showsIndicators
        self._offset = offset
        self.content = content
        self.coordinateSpaceName = coordinateSpaceName
    }
    
    public var body: some View {
        
        ScrollView(axes, showsIndicators: showsIndicators) {
            
            PositionObservingView(
                coordinateSpace: .named(coordinateSpaceName),
                position: Binding(
                    get: { offset },
                    set: { newOffset in
                        offset = CGPoint(
                            x: -newOffset.x,
                            y: -newOffset.y
                        )
                    }
                ),
                content: content
            )
        }
        .coordinateSpace(name: coordinateSpaceName)
    }
}

private struct PositionObservingView<Content: View>: View {
    
    let coordinateSpace: CoordinateSpace
    
    @Binding var position: CGPoint
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        
        content()
            .background(GeometryReader { geometry in
                Color.clear.preference(
                    key: PreferenceKey.self,
                    value: geometry.frame(in: coordinateSpace).origin
                )
            })
            .onPreferenceChange(PreferenceKey.self) { position in
                self.position = position
            }
    }
}

private extension PositionObservingView {
    struct PreferenceKey: SwiftUI.PreferenceKey {
        static var defaultValue: CGPoint { .zero }
        
        static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
            // No-op
        }
    }
}
