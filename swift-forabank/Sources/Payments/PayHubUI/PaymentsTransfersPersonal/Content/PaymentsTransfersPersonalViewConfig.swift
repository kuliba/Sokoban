//
//  PaymentsTransfersViewConfig.swift
//
//
//  Created by Igor Malyarov on 03.09.2024.
//

import SharedConfigs
import SwiftUI

public struct PaymentsTransfersPersonalViewConfig: Equatable {
    
    public let spacing: CGFloat
    public let titleSpacing: CGFloat
    public let title: TitleConfig

    public init(
        spacing: CGFloat,
        titleSpacing: CGFloat,
        title: TitleConfig
    ) {
        self.titleSpacing = titleSpacing
        self.spacing = spacing
        self.title = title
    }
}
