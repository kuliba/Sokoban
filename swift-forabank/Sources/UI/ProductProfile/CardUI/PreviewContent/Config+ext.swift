//
//  Config+ext.swift
//
//
//  Created by Andryusina Nataly on 18.03.2024.
//

import Foundation
import UIKit
import SwiftUI

extension Config.Back {
    
    static let preview: Self =  .init(
        headerLeadingPadding: CGFloat(12).pixelsToPoints(),
        headerTopPadding: CGFloat(12).pixelsToPoints(),
        headerTrailingPadding: CGFloat(12).pixelsToPoints())
}

extension Config.Front {
    
    static func frontConfig(
        _ size: Appearance.Size
    ) -> Config.Front {
        
        switch size {
            
        case .large:
            return .init(
                headerLeadingPadding: 43,
                headerTopPadding: 6.2,
                nameSpacing: 6,
                cardPadding: 12,
                cornerRadius: 12,
                checkPadding: 10)
            
        case .normal:
            return .init(
                headerLeadingPadding: 43,
                headerTopPadding: 6.2,
                nameSpacing: 6,
                cardPadding: 12,
                cornerRadius: 12,
                checkPadding: 10)
            
        case .small:
            return .init(
                headerLeadingPadding: 29,
                headerTopPadding: 4,
                nameSpacing: 4,
                cardPadding: 8,
                cornerRadius: 8,
                checkPadding: 8)
        }
    }
}

extension Config {
    
    static func config(
        _ appearance: Appearance
    ) -> Self  {
        
        .init(
            appearance: appearance,
            back: .preview,
            front: .frontConfig(appearance.size),
            fonts: .fontsConfig(appearance.size),
            sizes: .sizesConfig(appearance.size),
            colors: .preview,
            images: .preview
        )
    }
}

extension Config.Images {
    
    static let preview: Self = .init(
        copy: Image(systemName: "doc.on.doc"),
        check: Image(systemName: "checkmark")
    )
}

extension Config.Colors {
    
    static let preview: Self = .init(
        foreground: .white,
        background: Color(red: 0.6, green: 0.6, blue: 0.6),
        rateFill: Color(red: 0.827, green: 0.827, blue: 0.827),
        rateForeground: Color(red: 0.11, green: 0.11, blue: 0.11),
        checkForeground: Color(red: 0.11, green: 0.11, blue: 0.11)
    )
}

extension Config.Fonts {
    
    static func fontsConfig(
        _ size: Appearance.Size
    ) -> Self  {
        
        switch size {
            
        case .large, .normal:
            return .init(
                card: .footnote,
                header: .caption,
                footer: .footnote,
                number: .callout,
                rate: .footnote
            )
            
        case .small:
            return .init(
                card: .caption2,
                header: .caption2,
                footer: .caption2,
                number: .callout,
                rate: .footnote
            )
        }
    }
}

extension Config.Sizes {
    
    static func sizesConfig(
        _ size: Appearance.Size
    ) -> Self  {
        
        switch size {
            
        case .large, .normal:
            return .init(
                paymentSystemIcon: .init(width: 28, height: 28),
                checkView: .init(width: 18, height: 18),
                checkViewImage: .init(width: 12, height: 12))
            
        case .small:
            return .init(
                paymentSystemIcon: .init(width: 20, height: 20),
                checkView: .init(width: 16, height: 16),
                checkViewImage: .init(width: 10, height: 10))
        }
    }
}

public extension CGFloat {
    
    func pixelsToPoints() -> CGFloat {
        return self / UIScreen.main.scale
    }
}
