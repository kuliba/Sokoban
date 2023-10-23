//
//  MarkersText.swift
//
//
//  Created by Andrew Kurdin on 21.09.2023.
//

import SwiftUI

public extension UILanding.Multi.MarkersText {
    
    struct Config {
        
        public let colors: Colors
        public let vstack: VStackSettings
        public let internalContent: InternalVStackWithContent
        
        public struct Colors {
            
            public let foreground: Foreground
            public let backgroud: BackgroundColors
            
            public struct Foreground {
                
                public let black: Color
                public let white: Color
                public let defaultColor: Color
                
                public init(black: Color, white: Color, defaultColor: Color) {
                    self.black = black
                    self.white = white
                    self.defaultColor = defaultColor
                }
            }
            
            public struct BackgroundColors {
                
                public let gray: Color
                public let black: Color
                public let white: Color
                public let defaultColor: Color
                
                public init(gray: Color, black: Color, white: Color, defaultColor: Color) {
                    self.gray = gray
                    self.black = black
                    self.white = white
                    self.defaultColor = defaultColor
                }
            }
           
            public init(foreground: Foreground, backgroud: BackgroundColors) {
                self.foreground = foreground
                self.backgroud = backgroud
            }
        }
        
        public struct VStackSettings {
            
            public let padding: Paddings
            
            public struct Paddings {
                
                public let leading: CGFloat
                public let trailing: CGFloat
                public let vertical: CGFloat
                
                public init(leading: CGFloat, trailing: CGFloat, vertical: CGFloat) {
                    self.leading = leading
                    self.trailing = trailing
                    self.vertical = vertical
                }
            }
            
            public init(padding: Paddings) {
                self.padding = padding
            }
        }
        
        public struct InternalVStackWithContent {
            
            public let spacing: CGFloat
            public let cornerRadius: CGFloat
            public let lineTextLeadingPadding: CGFloat
            public let textFont: Font
            
            public init(
                spacing: CGFloat,
                cornerRadius: CGFloat,
                lineTextLeadingPadding: CGFloat,
                textFont: Font
            ) {
                self.spacing = spacing
                self.cornerRadius = cornerRadius
                self.lineTextLeadingPadding = lineTextLeadingPadding
                self.textFont = textFont
            }
        }
        
        public init(
            colors: Colors,
            vstack: VStackSettings,
            internalContent: InternalVStackWithContent
        ) {
            self.colors = colors
            self.vstack = vstack
            self.internalContent = internalContent
        }
                
        func backgroundColor(_ backgroundColor: String) -> Color {
            
            let colorType: BackgroundColorType? = .init(rawValue: backgroundColor)
                
            switch colorType {
                
            case .black:
                return colors.backgroud.black
            case .gray:
                return colors.backgroud.gray
            case .white:
                return colors.backgroud.white
            case .none:
                return colors.backgroud.defaultColor
            }
        }
        
        func backgroundColor(_ strStyle: String, _ bgColor: String) -> Color {
            
            switch getStyle(strStyle) {
            case .padding, .fill:
                return backgroundColor(bgColor)
            case .paddingWithCorners:
                return .clear
            }
        }
        
        func foregroundColor(_ backgroundColor: String) -> Color {
            
            let colorType: BackgroundColorType? = .init(rawValue: backgroundColor)
           
            switch colorType {
                
            case .black:
                return colors.foreground.white
            case .gray, .white:
                return colors.foreground.black
            case .none:
                return colors.foreground.defaultColor
            }
        }
        
        func getCornerRadius(_ strStyle: String) -> CGFloat {
            
            getStyle(strStyle) == .paddingWithCorners ? internalContent.cornerRadius : 0
        }
        
        enum PaddingStyle: String, Equatable {
            case padding = "BLACK"
            case paddingWithCorners = "PADDINGWITHCORNERS"
            case fill = "FILL"
        }
        
        private func getStyle(_ strStyle: String) -> PaddingStyle {
            
            return PaddingStyle.init(rawValue: strStyle) ?? .padding
        }
        
         func getLeadingPadding(_ strStyle: String) -> CGFloat {
            switch getStyle(strStyle) {
            case .padding, .paddingWithCorners:
                return vstack.padding.leading
            case .fill:
                return 0
            }
        }
        
         func getTrailingPadding(_ strStyle: String) -> CGFloat {
            switch getStyle(strStyle) {
            case .padding, .paddingWithCorners:
                return vstack.padding.trailing
            case .fill:
                return 0
            }
        }
        
         func getVerticalPadding(_ strStyle: String) -> CGFloat {
            switch getStyle(strStyle) {
            case .padding, .paddingWithCorners:
                return vstack.padding.vertical
            case .fill:
                return 0
            }
        }
        
        func getDoubleHorizontalPaddingForCornersView(_ strStyle: String) -> CGFloat {
           switch getStyle(strStyle) {
           case .paddingWithCorners:
               return vstack.padding.leading
           case .padding, .fill:
               return 0
           }
       }
    }
}
