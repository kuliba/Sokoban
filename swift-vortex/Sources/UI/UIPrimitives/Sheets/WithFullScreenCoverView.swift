//
//  WithFullScreenCoverView.swift
//  Vortex
//
//  Created by Igor Malyarov on 19.02.2025.
//

import SwiftUI

/// A view that presents content with an attached full screen cover. The content view receives an action to trigger the full screen cover presentation, and the full screen cover view receives an action to dismiss itself.
public struct WithFullScreenCoverView<Content: View, Sheet: View>: View {
    
    @State private var isPresented: Bool
    
    /// A closure that provides the content view. It receives an action to trigger the full screen cover presentation.
    private let content: (@escaping () -> Void) -> Content
    /// A closure that provides the full screen cover view. It receives an action to dismiss the full screen cover.
    private let sheet: (@escaping () -> Void) -> Sheet
    
    /// Initializes a new instance of `WithFullScreenCoverView`.
    /// - Parameters:
    ///   - isPresented: A Boolean value that determines if the full screen cover is initially presented.
    ///   - content: A closure that returns the content view. It receives an action to trigger the full screen cover presentation.
    ///   - sheet: A closure that returns the full screen cover view. It receives an action to dismiss the full screen cover.
    public init(
        isPresented: Bool = false,
        @ViewBuilder content: @escaping (@escaping () -> Void) -> Content,
        @ViewBuilder sheet: @escaping (@escaping () -> Void) -> Sheet
    ) {
        self.isPresented = isPresented
        self.content = content
        self.sheet = sheet
    }
    
    public var body: some View {
        
        content { isPresented = true }
            .fullScreenCover(isPresented: $isPresented) { sheet { isPresented = false }}
    }
}

extension WithFullScreenCoverView {
    
    /// Creates a `WithFullScreenCoverView` with content and a full screen cover view when the full screen cover's dismiss action is not needed.
    /// - Parameters:
    ///   - isPresented: A Boolean value that determines if the full screen cover is initially presented.
    ///   - content: A closure that provides the content view. It receives a closure to trigger the full screen cover presentation.
    ///   - sheet: A closure that returns the full screen cover view.
    public init(
        isPresented: Bool = false,
        @ViewBuilder content: @escaping (@escaping () -> Void) -> Content,
        @ViewBuilder sheet: @escaping () -> Sheet
    ) {
        self.init(isPresented: isPresented, content: content, sheet: { _ in sheet() })
    }
}
