//
//  MultiLineHeaderConfig.swift
//  
//
//  Created by Andryusina Nataly on 28.08.2023.
//

import SwiftUI

extension MultiLineHeaderView {
    
    struct Config {
        
        let backgroundColor: BackgroundColor
        let item: Item
        
        var textColor: Color {
            
            return backgroundColor.isDark ? .white : .black
        }
        
        struct Item {
            
            let color: Color
            let fontRegular: Font
            let fontBold: Font
        }
        
        enum BackgroundColor {
            
            case black
            case gray
            case white
            
            var value: Color {
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
            
            var isDark: Bool {
                
                self == .black
            }
        }
    }
}
