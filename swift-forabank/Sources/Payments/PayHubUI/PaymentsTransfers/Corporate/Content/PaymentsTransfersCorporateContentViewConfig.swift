//
//  PaymentsTransfersCorporateContentViewConfig.swift
//
//
//  Created by Igor Malyarov on 04.09.2024.
//

import SharedConfigs
import SwiftUI

public struct PaymentsTransfersCorporateContentViewConfig: Equatable {
    
    public let header: TitleConfig
    public let headerTopPadding: CGFloat
    public let spacing: CGFloat
    public let title: TitleConfig
    public let titleTopPadding: CGFloat
    
    public init(
        header: TitleConfig,
        headerTopPadding: CGFloat,
        spacing: CGFloat,
        title: TitleConfig,
        titleTopPadding: CGFloat
    ) {
        self.header = header
        self.headerTopPadding = headerTopPadding
        self.spacing = spacing
        self.title = title
        self.titleTopPadding = titleTopPadding
    }
}
