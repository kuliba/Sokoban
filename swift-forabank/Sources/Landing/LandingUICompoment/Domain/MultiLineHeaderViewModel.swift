//
//  MultiLineHeaderViewModel.swift
//  
//
//  Created by Andryusina Nataly on 27.08.2023.
//

import SwiftUI

struct MultiLineHeaderViewModel {
    
    let backgroundColor: BackgroundColor
    let regularTextItems: [Item]?
    let boldTextItems: [Item]?
    
    var textColor: Color {
        
        return backgroundColor.isDark ? .white : .black
    }
}

extension MultiLineHeaderViewModel {
    
    struct Item: Hashable {
        
        let name: String
    }
}

extension MultiLineHeaderViewModel {
    
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
