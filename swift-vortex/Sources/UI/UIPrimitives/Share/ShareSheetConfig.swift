//
//  ShareSheetConfig.swift
//
//
//  Created by Igor Malyarov on 18.02.2025.
//

import UIKit

public struct ShareSheetConfig {
    
    let detents: [UISheetPresentationController.Detent]?
    let excludedActivityTypes: [UIActivity.ActivityType]?
    let prefersGrabberVisible: Bool
    
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
    
    static let `default`: Self = .init()
    static let mediumWithGrabber: Self = .init(detents: [.medium()], prefersGrabberVisible: true)
    static let withGrabber: Self = .init(prefersGrabberVisible: true)
}
