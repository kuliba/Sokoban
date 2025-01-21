//
//  CreateDraftCollateralLoanApplicationConfig.swift
//
//
//  Created by Valentin Ozerov on 30.12.2024.
//

import SwiftUI
import UIPrimitives

public struct CreateDraftCollateralLoanApplicationConfig {
        
    public let fonts: Fonts
    public let colors: Colors
    public let layouts: Layouts
    public let header: Header
    public let button: Button

    public struct Fonts {
        
        let title: TextConfig
        let value: TextConfig
        
        public init(title: TextConfig, value: TextConfig) {

            self.title = title
            self.value = value
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
            
            public let stack: EdgeInsets
            public let contentStack: EdgeInsets

            public init(stack: EdgeInsets, contentStack: EdgeInsets) {
                
                self.stack = stack
                self.contentStack = contentStack
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

extension CreateDraftCollateralLoanApplicationConfig {
    
    public static let `default` = Self(
        fonts: .init(
            title: .init(textFont: Font.system(size: 14), textColor: .title),
            value: .init(textFont: Font.system(size: 16), textColor: .primary)
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
                stack: .init(
                    top: 16,
                    leading: 16,
                    bottom: 16,
                    trailing: 15
                ),
                contentStack: .init(
                    top: 13,
                    leading: 12,
                    bottom: 13,
                    trailing: 16
                )
            )
        ),
        header: .preview,
        button: .preview
    )
}

private extension Color {
    
    static let title: Self = .init(red: 0.6, green: 0.6, blue: 0.6)
    static let background: Self = .init(red: 0.96, green: 0.96, blue: 0.97)
}
