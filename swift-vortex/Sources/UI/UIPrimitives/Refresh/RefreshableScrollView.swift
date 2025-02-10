//
//  RefreshableScrollView.swift
//  RefreshableScrollViewPreview
//
//  Created by Igor Malyarov on 16.10.2024.
//

import SwiftUI

/// A scroll view that supports pull-to-refresh functionality.
///
/// `RefreshableScrollView` is a custom view that provides pull-to-refresh
/// capability to its content. It triggers an action when the user pulls
/// down the content beyond a specified offset.
///
/// - Note: This view does not display a visual indicator during the refresh.
///         Ensure that the `action` provides appropriate feedback if needed.
public struct RefreshableScrollView<Content: View>: View {
    
    /// The action to perform when a refresh is triggered.
    private let action: () -> Void
    
    /// The content to display inside the scroll view.
    private let content: Content
    
    /// The name of the coordinate space used for offset calculations.
    private let coordinateSpaceName: String
    
    /// The offset threshold to trigger the refresh action.
    private let offsetForStartUpdate: CGFloat
    
    /// The delay after which the refreshing state resets.
    private let refreshCompletionDelay: TimeInterval
    
    /// A Boolean value that controls whether the scroll view displays the scroll indicators.
    private let showsIndicators: Bool
    
    /// A state variable that tracks whether a refresh is in progress.
    @State private var isRefreshing = false
    
    /// Creates a `RefreshableScrollView` with the specified parameters.
    ///
    /// - Parameters:
    ///   - action: The action to perform when a refresh is triggered.
    ///   - showsIndicators: A Boolean value that indicates whether the scroll view shows indicators. Defaults to `true`.
    ///   - coordinateSpaceName: The name of the coordinate space. Defaults to `"RefreshableScrollView"`.
    ///   - offsetForStartUpdate: The offset threshold to trigger the refresh action. Defaults to `-100`.
    ///   - refreshCompletionDelay: The delay after which the refreshing state resets. Defaults to `1.0` second.
    ///   - content: A view builder that creates the content of this scroll view.
    public init(
        action: @escaping () -> Void,
        showsIndicators: Bool = true,
        coordinateSpaceName: String = "RefreshableScrollView",
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
            
            VStack { content }
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

/// A preference key to track the scroll offset.
///
/// `ScrollOffsetKey` is used internally by `RefreshableScrollView` to monitor
/// the content offset within the scroll view's coordinate space.
private struct ScrollOffsetKey: PreferenceKey {
    
    /// The default value of the preference key.
    static var defaultValue: CGFloat { .zero }
    
    /// Combines a sequence of values by summing them up.
    ///
    /// - Parameters:
    ///   - value: The current accumulated value.
    ///   - nextValue: A closure that returns the next value in the sequence.
    static func reduce(
        value: inout CGFloat,
        nextValue: () -> CGFloat
    ) {
        value += nextValue()
    }
}
