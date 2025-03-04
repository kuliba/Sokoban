//
//  OffsetReportingScrollView.swift
//  Vortex
//
//  Created by Igor Malyarov on 02.03.2025.
//

import SwiftUI

/// A generic view that wraps a ScrollView and reports its vertical offset via a callback.
public struct OffsetReportingScrollView<Content: View>: View {
    
    @State private var offsetY: CGFloat
    
    private let content: (CGFloat) -> Content
    
    public init(
        offsetY: CGFloat = .zero,
        @ViewBuilder content: @escaping (CGFloat) -> Content
    ) {
        self.offsetY = offsetY
        self.content = content
    }
    
    public var body: some View {
        
        ScrollView {
            
            geometryReader()
            content(offsetY)
        }
        .coordinateSpace(name: "scroll")
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) {
            
            offsetY = $0
        }
        // .onChange(of: offsetY) { print("onChange @State", Int($0).formatted()) }
    }
}

private extension OffsetReportingScrollView {
    
    func geometryReader() -> some View {
        
        GeometryReader { proxy in
            
            let y = proxy.frame(in: .named("scroll")).origin.y
            // let _ = print("y:", Int(y).formatted())
            
            Color.clear
                .frame(height: 0)
                .preference(
                    key: ScrollOffsetPreferenceKey.self,
                    value: y
                )
        }
    }
}

/// A preference key to capture the vertical offset from a scroll view’s content.
///
/// When multiple subviews contribute to this preference (for example, when wrapping content in a VStack),
/// some subviews may contribute the default value of 0. Using the standard reduce implementation,
/// these default values can override the dynamic offset provided by a GeometryReader.
///
/// To fix this, we ignore any contributions that are equal to the default value (0), so that the
/// nonzero value from the GeometryReader is preserved. This ensures that offset updates are reported
/// correctly even when the content is wrapped in additional containers.
struct ScrollOffsetPreferenceKey: PreferenceKey {
    
    static var defaultValue: CGFloat = 0
    
    static func reduce(
        value: inout CGFloat,
        nextValue: () -> CGFloat
    ) {
        // value = nextValue()
        let candidate = nextValue()
        if candidate != Self.defaultValue {
            value = candidate
        }
    }
}
