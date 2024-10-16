//
//  RefreshableScrollView.swift
//  RefreshableScrollViewPreview
//
//  Created by Igor Malyarov on 16.10.2024.
//

import SwiftUI

public struct RefreshableScrollView<Content: View>: View {
    
    private let action: () -> Void
    private let content: Content
    private let coordinateSpaceName: String
    private let offsetForStartUpdate: CGFloat
    private let refreshCompletionDelay: TimeInterval
    private let showsIndicators: Bool
    
    @State private var isRefreshing = false
    
    public init(
        action: @escaping () -> Void,
        showsIndicators: Bool = true,
        coordinateSpaceName: String = "scroll",
        offsetForStartUpdate: CGFloat = -100,
        refreshCompletionDelay: TimeInterval = 1.0,
        @ViewBuilder content: () -> Content
    ) {
        self.action = action
        self.showsIndicators = showsIndicators
        self.content = content()
        self.coordinateSpaceName = coordinateSpaceName
        self.offsetForStartUpdate = offsetForStartUpdate
        self.refreshCompletionDelay = refreshCompletionDelay
    }
    
    public var body: some View {
        
        ScrollView(showsIndicators: showsIndicators) {
            
            content
                .background(
                    GeometryReader { geo in
                        
                        Color.clear
                            .preference(
                                key: ScrollOffsetKey.self,
                                value: -geo.frame(in: .named(coordinateSpaceName)).origin.y
                            )
                    }
                )
                .onPreferenceChange(ScrollOffsetKey.self) { offset in
                    
                    if offset < offsetForStartUpdate && !isRefreshing {
                        
                        isRefreshing = true
                        action()
                        
                        // Reset isRefreshing after the specified delay
                        DispatchQueue.main.asyncAfter(
                            deadline: .now() + refreshCompletionDelay
                        ) {
                            isRefreshing = false
                        }
                    }
                }
        }
        .coordinateSpace(name: coordinateSpaceName)
    }
}

// Move ScrollOffsetKey outside the generic struct
private struct ScrollOffsetKey: PreferenceKey {
    
    static var defaultValue: CGFloat { .zero }
    
    static func reduce(
        value: inout CGFloat,
        nextValue: () -> CGFloat
    ) {
        value += nextValue()
    }
}
