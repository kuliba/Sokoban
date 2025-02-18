//
//  ShareSheetConfig.swift
//
//
//  Created by Igor Malyarov on 18.02.2025.
//

import UIKit

/// Configuration options for the share sheet presentation.
///
/// **Note:** The `UIActivityViewController` is a system-controlled view controller.
/// Customizations such as setting detents via `detents` may not be honored by the system.
/// In practice, the share sheet might always appear at a fixed size regardless of these settings.
public struct ShareSheetConfig {
    
    /// An array of detents (sizes) for the share sheet.
    public let detents: [UISheetPresentationController.Detent]?
    /// An array of activity types to exclude from the share sheet.
    public let excludedActivityTypes: [UIActivity.ActivityType]?
    /// A Boolean indicating whether a grabber (visual indicator) should be shown.
    public let prefersGrabberVisible: Bool
    
    /// Creates a new `ShareSheetConfig` instance.
    ///
    /// - Parameters:
    ///   - detents: The available detents for the share sheet. Defaults to `nil`.
    ///   - excludedActivityTypes: Activity types to exclude. Defaults to `nil`.
    ///   - prefersGrabberVisible: Whether the grabber should be visible. Defaults to `false`.
    public init(
        detents: [UISheetPresentationController.Detent]? = nil,
        excludedActivityTypes: [UIActivity.ActivityType]? = nil,
        prefersGrabberVisible: Bool = false
    ) {
        self.detents = detents
        self.excludedActivityTypes = excludedActivityTypes
        self.prefersGrabberVisible = prefersGrabberVisible
    }
}

public extension ShareSheetConfig {
    
    /// Default configuration with no custom detents and no grabber.
    static let `default`: Self = .init()
    
    /// Configuration with a medium detent and a grabber.
    static let mediumWithGrabber: Self = .init(detents: [.medium()], prefersGrabberVisible: true)
    
    /// Configuration with a grabber visible (detents not set).
    static let withGrabber: Self = .init(prefersGrabberVisible: true)
}
