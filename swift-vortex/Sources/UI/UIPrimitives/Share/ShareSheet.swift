//
//  ShareSheet.swift
//
//
//  Created by Igor Malyarov on 18.02.2025.
//

import SwiftUI
import UIKit

/// A SwiftUI wrapper for `UIActivityViewController` that presents a share sheet.
///
/// The `ShareSheet` uses the provided payload and configuration to set up the share sheet.
/// It leverages iOS 15+ sheet presentation options if available.
public struct ShareSheet: UIViewControllerRepresentable {
    
    /// The payload containing items to be shared.
    private let payload: ShareSheetPayload
    /// The configuration for the share sheet appearance and behavior.
    private let config: ShareSheetConfig
    
    /// Creates a new `ShareSheet` instance.
    ///
    /// - Parameters:
    ///   - payload: The payload with items to share.
    ///   - config: The configuration for the share sheet. Defaults to `.default`.
    public init(
        payload: ShareSheetPayload,
        config: ShareSheetConfig = .default
    ) {
        self.payload = payload
        self.config = config
    }
    
    public func makeUIViewController(
        context: Context
    ) -> UIActivityViewController {
        
        let controller = UIActivityViewController(
            activityItems: payload.items,
            applicationActivities: nil
        )
        controller.excludedActivityTypes = config.excludedActivityTypes
        
        // Configure sheet presentation if available and custom parameters are provided.
        if let sheet = controller.sheetPresentationController {
            
            if let customDetents = config.detents {
                sheet.detents = customDetents
            }
            sheet.prefersGrabberVisible = config.prefersGrabberVisible
        }
        
        return controller
    }
    
    public func updateUIViewController(
        _ uiViewController: UIActivityViewController,
        context: Context
    ) {
        // No update logic needed for static content.
    }
}

// MARK: - Previews

struct ShareSheet_Previews: PreviewProvider {
    
    static var previews: some View {
        
        VStack {
            
            shareButton(config: .default)
            shareButton(config: .mediumWithGrabber)
            shareButton(config: .withGrabber)
        }
    }
    
    private static func shareButton(
        config: ShareSheetConfig
    ) -> some View {
        
        ShareButton(
            payload: .init(items: ["Payee: someone"]),
            config: config,
            label: { Text("Share") }
        )
    }
}
