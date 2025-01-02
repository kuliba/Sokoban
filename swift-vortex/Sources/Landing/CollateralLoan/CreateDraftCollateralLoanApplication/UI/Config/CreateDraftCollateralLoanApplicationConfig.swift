//
//  CreateDraftCollateralLoanApplicationConfig.swift
//
//
//  Created by Valentin Ozerov on 30.12.2024.
//

import SwiftUI

public struct CreateDraftCollateralLoanApplicationConfig {
        
    public let fonts: Fonts
    public let colors: Colors
    public let layouts: Layouts
    public let header: Header

    public struct Fonts {
        
        let title: FontConfig
        let message: FontConfig
        
        public init(title: FontConfig, message: FontConfig) {
            self.title = title
            self.message = message
        }
    }
    
    public struct Colors {
        
        public let background: Color
        
        public init(background: Color) {
            self.background = background
        }
    }
    
    public struct Layouts {
        
        public let iconSize: CGSize
        public let cornerRadius: CGFloat
        public let contentHorizontalSpacing: CGFloat
        public let contentVerticalSpacing: CGFloat
        public let paddings: Paddings

        public init(
            iconSize: CGSize,
            cornerRadius: CGFloat,
            contentHorizontalSpacing: CGFloat,
            contentVerticalSpacing: CGFloat,
            paddings: Paddings
        ) {
            self.iconSize = iconSize
            self.cornerRadius = cornerRadius
            self.contentHorizontalSpacing = contentHorizontalSpacing
            self.contentVerticalSpacing = contentVerticalSpacing
            self.paddings = paddings
        }
        
        public struct Paddings {
            
            public let leading: CGFloat
            public let trailing: CGFloat
            public let vertical: CGFloat
            public let contentLeading: CGFloat
            public let contentTrailing: CGFloat
            public let contentVertical: CGFloat

            public init(
                leading: CGFloat,
                trailing: CGFloat,
                vertical: CGFloat,
                contentLeading: CGFloat,
                contentTrailing: CGFloat,
                contentVertical: CGFloat
            ) {
                self.leading = leading
                self.trailing = trailing
                self.vertical = vertical
                self.contentLeading = contentLeading
                self.contentTrailing = contentTrailing
                self.contentVertical = contentVertical
            }
        }
    }
    
    public struct FontConfig {
        
        public let font: Font
        public let foreground: Color
        public let background: Color
        
        public init(
            _ font: Font,
            foreground: Color = .black,
            background: Color = .white
        ) {
            self.font = font
            self.foreground = foreground
            self.background = background
        }
    }
}

public extension CreateDraftCollateralLoanApplicationConfig {
    
    static let `default` = Self(
        fonts: .init(
            title: .init(Font.system(size: 14), foreground: .title),
            message: .init(Font.system(size: 16))
        ),
        colors: .init(
            background: .background
        ),
        layouts: .init(
            iconSize: .init(width: 27, height: 27),
            cornerRadius: 12,
            contentHorizontalSpacing: 12,
            contentVerticalSpacing: 4,
            paddings: .init(
                leading: 16,
                trailing: 15,
                vertical: 16,
                contentLeading: 12,
                contentTrailing: 16,
                contentVertical: 13
            )
        ),
        header: .default
    )
}

extension Color {
    
    static let title: Self = .init(red: 0.6, green: 0.6, blue: 0.6)
    static let background: Self = .init(red: 0.96, green: 0.96, blue: 0.97)
}
