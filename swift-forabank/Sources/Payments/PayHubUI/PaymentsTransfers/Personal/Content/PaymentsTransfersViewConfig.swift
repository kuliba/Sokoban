//
//  PaymentsTransfersViewConfig.swift
//
//
//  Created by Igor Malyarov on 03.09.2024.
//

import SharedConfigs
import SwiftUI

public struct PaymentsTransfersViewConfig: Equatable {
    
    public let titleSpacing: CGFloat
    public let spacing: CGFloat
    public let title: TitleConfig

    public init(
        titleSpacing: CGFloat,
        spacing: CGFloat,
        title: TitleConfig
    ) {
        self.titleSpacing = titleSpacing
        self.spacing = spacing
        self.title = title
    }
}
