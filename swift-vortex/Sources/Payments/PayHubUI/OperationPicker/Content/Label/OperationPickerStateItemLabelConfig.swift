//
//  OperationPickerStateItemLabelConfig.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 17.08.2024.
//

import SharedConfigs
import SwiftUI

public struct OperationPickerStateItemLabelConfig: Equatable {
    
    public let iconSize: CGSize
    public let exchange: IconConfig
    public let latestPlaceholder: LatestPlaceholderConfig
    public let templates: IconConfig
    
    public init(
        iconSize: CGSize,
        exchange: IconConfig,
        latestPlaceholder: LatestPlaceholderConfig,
        templates: IconConfig
    ) {
        self.iconSize = iconSize
        self.exchange = exchange
        self.latestPlaceholder = latestPlaceholder
        self.templates = templates
    }
}

extension OperationPickerStateItemLabelConfig {
    
    public struct IconConfig: Equatable {
        
        public let color: Color
        public let icon: Image
        public let title: String
        
        public init(
            color: Color,
            icon: Image,
            title: String
        ) {
            self.color = color
            self.icon = icon
            self.title = title
        }
    }
}
