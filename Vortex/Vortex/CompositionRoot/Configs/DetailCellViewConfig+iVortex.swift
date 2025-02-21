//
//  DetailCellViewConfig+iVortex.swift
//  Vortex
//
//  Created by Igor Malyarov on 18.02.2025.
//

import Foundation
import UIPrimitives

extension DetailCellViewConfig {
    
    static let iVortex: Self = .init(
        labelVPadding: 6,
        imageForegroundColor: .iconGray,
        imageSize: .init(width: 24, height: 24),
        imagePadding: .init(top: 10, leading: 0, bottom: 0, trailing: 0),
        hSpacing: 16,
        vSpacing: 4,
        title: .init(
            textFont: .textBodySR12160(),
            textColor: .textPlaceholder
        ),
        value: .init(
            textFont: .textBodyMM14200(),
            textColor: .textSecondary
        ),
        product: .iVortex
    )
}

extension DetailCellViewConfig.ProductConfig {
    
    static let iVortex: Self = .init(
        balance: .init(textFont: .textBodyMM14200(), textColor: .textSecondary),
        description: .init(textFont: .textBodySR12160(), textColor: .textPlaceholder),
        hSpacing: 16,
        iconSize: .init(width: 32, height: 32),
        name: .init(textFont: .textBodyMM14200(), textColor: .textSecondary),
        title: .init(textFont: .textBodySR12160(), textColor: .textPlaceholder),
        vStackVPadding: 6
    )
}
