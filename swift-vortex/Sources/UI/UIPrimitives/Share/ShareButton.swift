//
//  ShareButton.swift
//
//
//  Created by Igor Malyarov on 18.02.2025.
//

import SwiftUI

public struct ShareButton<Label: View, ShareView: View>: View {
    
    @State private var isSharing = false
    
    private let onDismiss: (() -> Void)?
    private let label: () -> Label
    private let shareView: () -> ShareView
    
    public init(
        onDismiss: (() -> Void)? = nil,
        label: @escaping () -> Label,
        shareView: @escaping () -> ShareView
    ) {
        self.onDismiss = onDismiss
        self.label = label
        self.shareView = shareView
    }
    
    public var body: some View {
        
        Button(action: { isSharing = true }, label: label)
            .sheet(isPresented: $isSharing, onDismiss: onDismiss, content: shareView)
    }
}

extension ShareButton
where ShareView == ShareSheet {
    
    public init(
        payload: ShareSheetPayload,
        config: ShareSheetConfig,
        onDismiss: (() -> Void)? = nil,
        label: @escaping () -> Label
    ) {
        self.init(onDismiss: onDismiss, label: label) {
            
            ShareView(payload: payload, config: config)
        }
    }
}
