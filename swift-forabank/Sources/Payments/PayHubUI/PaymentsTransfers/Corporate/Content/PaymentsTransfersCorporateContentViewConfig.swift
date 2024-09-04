//
//  PaymentsTransfersCorporateContentViewConfig.swift
//
//
//  Created by Igor Malyarov on 04.09.2024.
//

import SharedConfigs
import SwiftUI

public struct PaymentsTransfersCorporateContentViewConfig: Equatable {
    
    public let bannerSectionHeight: CGFloat
    public let header: TitleConfig
    public let headerTopPadding: CGFloat
    public let spacing: CGFloat
    public let stack: EdgeInsets
    public let title: TitleConfig
    public let titleTopPadding: CGFloat
    
    public init(
        bannerSectionHeight: CGFloat,
        header: TitleConfig,
        headerTopPadding: CGFloat,
        spacing: CGFloat,
        stack: EdgeInsets,
        title: TitleConfig,
        titleTopPadding: CGFloat
    ) {
        self.bannerSectionHeight = bannerSectionHeight
        self.header = header
        self.headerTopPadding = headerTopPadding
        self.spacing = spacing
        self.stack = stack
        self.title = title
        self.titleTopPadding = titleTopPadding
    }
}
