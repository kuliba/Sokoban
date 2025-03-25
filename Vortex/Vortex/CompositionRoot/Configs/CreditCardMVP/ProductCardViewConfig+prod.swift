//
//  ProductCardViewConfig+prod.swift
//  Vortex
//
//  Created by Igor Malyarov on 25.03.2025.
//

import CreditCardMVPUI
import SwiftUI

extension ProductCardViewConfig {
    
    static func prod() -> Self {
        
        return .init(
            backgroundColor: .mainColorsGrayLightest,
            cornerRadius: 12,
            edges: .init(top: 13, leading: 16, bottom: 13, trailing: 16),
            spacing: 20,
            header: .prod(),
            label: .prod()
        )
    }
}

private extension ProductCardViewConfig.HeaderConfig {
    
    static func prod() -> Self {
        
        return .init(
            title: .init(
                textFont: .textH3Sb18240(),
                textColor: .mainColorsBlack
            ),
            subtitle: .init(
                textFont: .textBodySR12160(),
                textColor: .textPlaceholder
            ),
            spacing: 4
        )
    }
}

private extension ProductCardViewConfig.LabelConfig {
    
    static func prod() -> Self {
        
        return .init(
            icon: .prod(),
            option: .prod(),
            title: .init(spacing: 12),
            spacing: 20
        )
    }
}

private extension ProductCardViewConfig.LabelConfig.IconConfig {
    
    static func prod() -> Self {
        
        return .init(
            cornerRadius: 8,
            limit: .init(
                textFont: .textBodyXsSb11140(),
                textColor: .textWhite
            ),
            limitPadding: 8,
            shadow: .prod(),
            size: .init(width: 112, height: 72)
        )
    }
}

private extension ProductCardViewConfig.LabelConfig.IconConfig.ShadowConfig {
    
    static func prod() -> Self {
        
        return .init(
            color: .mainColorsBlack.opacity(0.3),
            offset: 8,
            blur: 12,
            size: .init(width: 88, height: 54)
        )
    }
}

private extension ProductCardViewConfig.LabelConfig.OptionConfig {
    
    static func prod() -> Self {
        
        return .init(
            icon: .ic16ArrowRightCircle,
            iconColor: .systemColorActive,
            iconSize: 16,
            spacing: 2,
            title: .init(
                textFont: .textBodySR12160(),
                textColor: .textPlaceholder
            ),
            value: .init(
                textFont: .textH4M16240(),
                textColor: .textSecondary
            ),
            valueSpacing: 9
        )
    }
}
