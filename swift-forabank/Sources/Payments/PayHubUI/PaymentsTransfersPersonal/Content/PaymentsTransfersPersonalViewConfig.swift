//
//  PaymentsTransfersViewConfig.swift
//
//
//  Created by Igor Malyarov on 03.09.2024.
//

import SharedConfigs
import SwiftUI

public struct PaymentsTransfersPersonalViewConfig: Equatable {
    
    public let titleSpacing: CGFloat
    public let title: TitleConfig

    public init(
        titleSpacing: CGFloat,
        title: TitleConfig
    ) {
        self.titleSpacing = titleSpacing
        self.title = title
    }
}
