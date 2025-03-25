//
//  ProductCardViewConfig+preview.swift
//  
//
//  Created by Igor Malyarov on 25.03.2025.
//

extension ProductCardViewConfig {
    
    static func preview() -> Self {
        
        return .init(
            backgroundColor: .gray.opacity(0.1), // main colors/ gray lightest
            cornerRadius: 12,
            edges: .init(top: 13, leading: 16, bottom: 13, trailing: 16),
            spacing: 20,
            header: .preview(),
            label: .preview()
        )
    }
}

extension ProductCardViewConfig.HeaderConfig {
    
    static func preview() -> Self {
        
        return .init(
            title: .init(
                textFont: .title3.bold(), // Text/H3/SB_18×24_0%
                textColor: .primary // Main colors/Black
            ),
            subtitle: .init(
                textFont: .subheadline, // Text/Body S/R_12×16_0%
                textColor: .secondary // placeholder (?)
            ),
            spacing: 4
        )
    }
}

extension ProductCardViewConfig.LabelConfig {
    
    static func preview() -> Self {
        
        return .init(
            icon: .preview(),
            option: .preview(),
            title: .init(spacing: 12),
            spacing: 20
        )
    }
}

extension ProductCardViewConfig.LabelConfig.IconConfig {
    
    static func preview() -> Self {
        
        return .init(
            cornerRadius: 8,
            limit: .init(
                textFont: .caption.bold(), // Text/Body XS/SB_11×14_0%
                textColor: .white // Text/White
            ),
            limitPadding: 8,
            shadow: .preview(),
            size: .init(width: 112, height: 72)
        )
    }
}

extension ProductCardViewConfig.LabelConfig.IconConfig.ShadowConfig {
    
    static func preview() -> Self {
        
        return .init(
            color: .secondary, // ???
            offset: 8,
            blur: 12,
            size: .init(width: 88, height: 54)
        )
    }
}

extension ProductCardViewConfig.LabelConfig.OptionConfig {
    
    static func preview() -> Self {
        
        return .init(
            icon: .init(systemName: "star"), // ic/16/arrow-right-circle
            iconColor: .green, // System color/active
            iconSize: 16,
            spacing: 2,
            title: .init(
                textFont: .footnote, // Text/Body S/R_12×16_0%
                textColor: .secondary // Text/placeholder
            ),
            value: .init(
                textFont: .headline, // Text/H4/M_16×24_0%
                textColor: .primary // Text/secondary
            ),
            valueSpacing: 9
        )
    }
}
