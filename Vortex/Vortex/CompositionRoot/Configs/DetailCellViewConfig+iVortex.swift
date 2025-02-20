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
        imagePadding: .init(top: 14, leading: 4, bottom: 0, trailing: 0),
        hSpacing: 20,
        vSpacing: 4,
        title: .init(
            textFont: .textBodySR12160(),
            textColor: .textPlaceholder
        ),
        value: .init(
            textFont: .textBodyMM14200(),
            textColor: .textSecondary
        )
    )
}
