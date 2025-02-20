//
//  SharingView.swift
//  Vortex
//
//  Created by Igor Malyarov on 19.02.2025.
//

import SwiftUI
import UIPrimitives

/// A view that wraps content and presents a share sheet with the provided share items.
/// The content view receives an action to trigger the share sheet presentation.
struct SharingView<Content: View>: View {
    
    @State private var isSharing = false
    
    let shareItems: [Any]
    @ViewBuilder
    let content: (@escaping () -> Void) -> Content
    
    var body: some View {
        
        WithSheetView(content: content) {
            
            ShareSheet(payload: .init(items: shareItems), config: .iVortex)
        }
    }
}
