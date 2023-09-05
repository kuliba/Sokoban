//
//  MultiLineHeaderUIConfig.swift
//  
//
//  Created by Andryusina Nataly on 28.08.2023.
//

import SwiftUI

public extension Landing.MultiLineHeader {
    
    struct Config: Equatable {
        
        public let backgroundColor: BackgroundColor
        public let item: Item
        
        public var textColor: Color {
            
            return backgroundColor.isDark ? .white : .black
        }
        
        public struct Item: Equatable {
            
            public let color: Color
            public let fontRegular: Font
            public let fontBold: Font
            
            public init(
                color: Color,
                fontRegular: Font,
                fontBold: Font
            ) {
                self.color = color
                self.fontRegular = fontRegular
                self.fontBold = fontBold
            }
        }
        
        public enum BackgroundColor: Equatable {
            
            case black
            case gray
            case white
            
            public var value: Color {
                get {
                    switch self {
                        
                    case .black:
                        return .black
                    case .gray:
                        return .gray
                    case .white:
                        return .white
                    }
                }
            }
            
            public var isDark: Bool {
                
                self == .black
            }
        }
        
        public init(backgroundColor: BackgroundColor, item: Item) {
            self.backgroundColor = backgroundColor
            self.item = item
        }
    }
}
