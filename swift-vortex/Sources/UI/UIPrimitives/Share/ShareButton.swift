//
//  ShareButton.swift
//
//
//  Created by Igor Malyarov on 18.02.2025.
//

import SwiftUI

/// A customizable share button that presents a share sheet when tapped.
///
/// `ShareButton` allows you to define a custom label and a custom share sheet view.
/// It is generic over the label and share sheet views so that you can provide your own styling
/// or even a different share sheet implementation if needed.
public struct ShareButton<Label: View, ShareView: View>: View {
    
    /// A Boolean state that indicates whether the share sheet is currently presented.
    @State private var isSharing = false
    
    /// An optional closure to be executed when the share sheet is dismissed.
    private let onDismiss: (() -> Void)?
    /// A closure that returns the custom view for the button label.
    private let label: () -> Label
    /// A closure that returns the share sheet view to be presented.
    private let shareView: () -> ShareView
    
    /// Creates a new instance of `ShareButton`.
    ///
    /// - Parameters:
    ///   - onDismiss: An optional closure to execute when the share sheet is dismissed.
    ///   - label: A closure returning the view for the button’s label.
    ///   - shareView: A closure returning the share sheet view to present.
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
            .sheet(
                isPresented: $isSharing,
                onDismiss: onDismiss,
                content: shareView
            )
    }
}

extension ShareButton
where ShareView == ShareSheet {
    
    /// Convenience initializer for creating a `ShareButton` that uses the default `ShareSheet`.
    ///
    /// - Parameters:
    ///   - payload: The payload containing items to share.
    ///   - config: The configuration for the share sheet presentation.
    ///   - onDismiss: An optional closure executed when the share sheet is dismissed.
    ///   - label: A closure returning the view for the button’s label.
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
