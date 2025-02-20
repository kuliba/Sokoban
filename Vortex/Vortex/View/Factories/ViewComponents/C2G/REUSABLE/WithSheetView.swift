//
//  WithSheetView.swift
//  Vortex
//
//  Created by Igor Malyarov on 19.02.2025.
//

import SwiftUI

// TODO: - extract to UIPrimitives

/// A view that presents content with an attached sheet. The content view receives an action to trigger the sheet presentation, and the sheet view receives an action to dismiss itself.
struct WithSheetView<Content: View, Sheet: View>: View {
    
    @State private var isPresented: Bool
    
    /// A closure that provides the content view. It receives an action to trigger the sheet presentation.
    let content: (@escaping () -> Void) -> Content
    /// A closure that provides the sheet view. It receives an action to dismiss the sheet.
    let sheet: (@escaping () -> Void) -> Sheet
    
    /// Initializes a new instance of `WithSheetView`.
    /// - Parameters:
    ///   - isPresented: A Boolean value that determines if the sheet is initially presented.
    ///   - content: A closure that returns the content view. It receives an action to trigger the sheet presentation.
    ///   - sheet: A closure that returns the sheet view. It receives an action to dismiss the sheet.
    init(
        isPresented: Bool = false,
        @ViewBuilder content: @escaping (@escaping () -> Void) -> Content,
        @ViewBuilder sheet: @escaping (@escaping () -> Void) -> Sheet
    ) {
        self.isPresented = isPresented
        self.content = content
        self.sheet = sheet
    }
    
    var body: some View {
        
        content { isPresented = true }
            .sheet(isPresented: $isPresented) { sheet { isPresented = false }}
    }
}

extension WithSheetView {
    
    /// Creates a `WithSheetView` with content and a sheet view when the sheet's dismiss action is not needed.
    /// - Parameters:
    ///   - isPresented: A Boolean value that determines if the sheet is initially presented.
    ///   - content: A closure that provides the content view. It receives a closure to trigger the sheet presentation.
    ///   - sheet: A closure that returns the sheet view.
    init(
        isPresented: Bool = false,
        @ViewBuilder content: @escaping (@escaping () -> Void) -> Content,
        @ViewBuilder sheet: @escaping () -> Sheet
    ) {
        self.init(isPresented: isPresented, content: content, sheet: { _ in sheet() })
    }
}
