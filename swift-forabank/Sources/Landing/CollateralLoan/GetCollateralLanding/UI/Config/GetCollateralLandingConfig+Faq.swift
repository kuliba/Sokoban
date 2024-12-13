//
//  GetCollateralLandingConfig+fag.swift
//
//
//  Created by Valentin Ozerov on 20.11.2024.
//

import Foundation
import SwiftUI
import DropDownTextListComponent

extension DropDownTextListConfig {
    
    static let `default` = Self(
        cornerRadius: 12,
        chevronDownImage: Image(systemName: "chevron.down"),
        layouts: .init(
            horizontalPadding: 16,
            verticalPadding: 12
        ),
        colors: .init(
            divider: .faqDivider,
            background: .grayLightest
        ),
        fonts: .init(
            title: .init(textFont: Font.system(size: 18).bold(), textColor: .primary),
            itemTitle: .init(textFont: Font.system(size: 14), textColor: .primary),
            itemSubtitle: .init(textFont: Font.system(size: 14), textColor: .textPlaceholder)
        )
    )
}
