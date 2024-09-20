//
//  OperationPickerStateItemLabelConfig.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 17.08.2024.
//

import SharedConfigs
import SwiftUI

public struct OperationPickerStateItemLabelConfig: Equatable {
    
    public let latestPlaceholder: LatestPlaceholderConfig
    
    public init(
        latestPlaceholder: LatestPlaceholderConfig
    ) {
        self.latestPlaceholder = latestPlaceholder
    }
}
