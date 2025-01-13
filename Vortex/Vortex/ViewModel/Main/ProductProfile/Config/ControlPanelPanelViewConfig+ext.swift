//
//  ControlPanelViewConfig+ext.swift
//  Vortex
//
//  Created by Andryusina Nataly on 27.06.2024.
//

import Foundation

extension ControlPanelViewConfig {
    
    static let `default`: Self = .init(
        colors: .init(
            background: .bgIconGrayLightest,
            title: .textSecondary,
            subtitle: .textPlaceholder),
        height: 56,
        paddings: .init(horizontal: 16, top: 30),
        spacings: .init(vstack: 24, hstack: 8),
        fonts: .init(title: .textBodySR12160()), placeHolder: .init(
            cornerRadius: 12,
            padding: 16,
            height: 176,
            bannerWidth: 288
        ))
}
