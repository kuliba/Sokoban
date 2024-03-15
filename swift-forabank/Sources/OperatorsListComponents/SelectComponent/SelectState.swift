//
//  SelectState.swift
//
//
//  Created by Дмитрий Савушкин on 13.03.2024.
//

import Foundation
import SwiftUI

enum SelectState {
    
    case collapsed(option: Option?)
    case expanded(options: [Option])
    
    struct Option {
        
        let id: String
        let title: String
        let isSelected: Bool
        
        let config: Config
        
        struct Config {
            
            let icon: Image
            let foreground: Color
            let background: Color
            
            let selectIcon: Image
            let selectForeground: Color
            let selectBackground: Color
            
            let mainBackground: Color
            
            let kind: Kind
            
            enum Kind: Int {
                
                case small = 16
                case normal = 24
            }
        }
    }
}
