//
//  ProductConfig.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 29.06.2023.
//

import SwiftUI

struct Values {
    
    let startValue: Double
    let endValue: Double
}

extension ProductView {
    
    typealias Appearance = ViewModel.Appearance
        
    struct CardViewConfig {
        
        let headerLeadingPadding: CGFloat
        let headerTopPadding: CGFloat
        let nameSpacing: CGFloat
        let cardPadding: CGFloat
        let cornerRadius: CGFloat
        let checkPadding: CGFloat
    }
    
    struct Config {
        
        let appearance: Appearance
        let cardViewConfig: CardViewConfig
        let fontConfig: FontConfig
        let sizeConfig: SizeConfig
    }

    struct FontConfig {
        
        let nameFontForCard: Font
        let nameFontForHeader: Font
        let nameFontForFooter: Font
    }
    
    struct SizeConfig {
        
        let paymentSystemIconSize: CGSize
        let checkViewSize: CGSize
        let checkViewImageSize: CGSize
    }
}

extension ProductView.ViewModel {
    
    var cardViewConfig: ProductView.CardViewConfig {
        
        switch appearance.size {
            
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
    
    var config: ProductView.Config {
        
        .init(
            appearance: appearance,
            cardViewConfig: cardViewConfig,
            fontConfig: fontConfig,
            sizeConfig: sizeConfig)
    }
    
    var fontConfig: ProductView.FontConfig {
        
        switch appearance.size {
            
        case .large:
            return .init(
                nameFontForCard: Font.custom("Inter", size: 14.0),
                nameFontForHeader: Font.custom("Inter", size: 12.0),
                nameFontForFooter: Font.custom("Inter-SemiBold", size: 14.0))
            
        case .normal:
            return .init(
                nameFontForCard: Font.custom("Inter", size: 14.0),
                nameFontForHeader: Font.custom("Inter", size: 12.0),
                nameFontForFooter: Font.custom("Inter-SemiBold", size: 14.0))
            
        case .small:
            return .init(
                nameFontForCard: Font.custom("Inter", size: 11.0),
                nameFontForHeader: Font.custom("Inter", size: 11.0),
                nameFontForFooter: Font.custom("Inter", size: 11.0))
        }
    }
    
    var sizeConfig: ProductView.SizeConfig {
        
        switch appearance.size {
            
        case .large:
            return .init(
                paymentSystemIconSize: .init(width: 28, height: 28),
                checkViewSize: .init(width: 18, height: 18),
                checkViewImageSize: .init(width: 12, height: 12))
            
        case .normal:
            return .init(
                paymentSystemIconSize: .init(width: 28, height: 28),
                checkViewSize: .init(width: 18, height: 18),
                checkViewImageSize: .init(width: 12, height: 12))
            
        case .small:
            return .init(
                paymentSystemIconSize: .init(width: 20, height: 20),
                checkViewSize: .init(width: 16, height: 16),
                checkViewImageSize: .init(width: 10, height: 10))
        }
    }
}

public extension CGFloat {
    
    func pixelsToPoints() -> CGFloat {
        return self / UIScreen.main.scale
    }
}
