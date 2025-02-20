//
//  SharingView.swift
//  Vortex
//
//  Created by Igor Malyarov on 19.02.2025.
//

import SwiftUI

/// A view that wraps content and presents a share sheet with the provided share items.
/// The content view receives an action to trigger the share sheet presentation.
public struct SharingView<Content: View>: View {
    
    @State private var isSharing = false
    
    private let shareItems: [Any]
    private let config: ShareSheetConfig
    private let content: (@escaping () -> Void) -> Content
    
    public init(
        isSharing: Bool = false,
        shareItems: [Any],
        config: ShareSheetConfig,
        @ViewBuilder content: @escaping (@escaping () -> Void) -> Content
    ) {
        self.isSharing = isSharing
        self.content = content
        self.shareItems = shareItems
        self.config = config
    }
    
    public var body: some View {
        
        WithSheetView(content: content) {
            
            ShareSheet(payload: .init(items: shareItems), config: config)
        }
    }
}
