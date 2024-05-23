//
//  ProductConfig.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 29.06.2023.
//

import SwiftUI
import CardUI

extension CardUI.Config.Back {
    
    static let backConfig: Self = .init(
        headerLeadingPadding: CGFloat(12).pixelsToPoints(),
        headerTopPadding: CGFloat(12).pixelsToPoints(),
        headerTrailingPadding: CGFloat(12).pixelsToPoints())
}

extension CardUI.Config {
    
    static func frontConfig(_ size: Appearance.Size) -> Front {
        
        switch size {
            
        case .large, .normal:
            return .init(
                headerLeadingPadding: 43,
                headerTopPadding: 6.2,
                nameSpacing: 6,
                cardPadding: 12,
                cornerRadius: 12,
                checkPadding: 10,
                cloverTrailing: 4
            )
            
        case .small:
            return .init(
                headerLeadingPadding: 29,
                headerTopPadding: 4,
                nameSpacing: 4,
                cardPadding: 8,
                cornerRadius: 8,
                checkPadding: 9,
                cloverTrailing: 2
            )
        }
    }
    
    static func config(appearance: Appearance) -> Self {
        
        .init(
            appearance: appearance,
            back: .backConfig,
            front: frontConfig(appearance.size),
            fonts: fontsConfig(appearance.size),
            sizes: sizesConfig(appearance.size),
            colors: .init(
                foreground: .mainColorsWhite,
                background: .textPlaceholder,
                rateFill: .mainColorsGrayMedium,
                rateForeground: .textSecondary
            ),
            images: .init(copy: .ic24Copy, check: .ic16CheckLightGray16Fixed)
        )
    }
    
    static func fontsConfig(_ size: Appearance.Size) -> Fonts {
        
        switch size {
        case .large, .normal:
            return .init(
                card: .textBodyMR14200(),
                header: .textBodySR12160(),
                footer: .textBodyMSb14200(),
                number: .textH4M16240(),
                rate: .textBodySM12160()
            )

        case .small:
            return .init(
                card: .textBodyXsR11140(),
                header: .textBodyXsR11140(),
                footer: .textBodyXsR11140(),
                number: .textH4M16240(),
                rate: .textBodySM12160()

            )
        }
    }
    
    static func sizesConfig(_ size: Appearance.Size) -> Sizes {
        
        switch size {
            
        case .large, .normal:
            return .init(
                paymentSystemIcon: .init(width: 28, height: 28),
                checkViewImage: .init(width: 18, height: 18))
                        
        case .small:
            return .init(
                paymentSystemIcon: .init(width: 20, height: 20),
                checkViewImage: .init(width: 18, height: 18))
        }
    }
}
