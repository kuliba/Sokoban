//
//  SelectState.swift
//
//
//  Created by Дмитрий Савушкин on 13.03.2024.
//

import Foundation
import SwiftUI

public enum SelectState {
    
    case collapsed(option: Option?)
    case expanded(options: [Option])
    
    public struct Option {
        
        let id: String
        let title: String
        let isSelected: Bool
        
        let config: Config
        
        public init(
            id: String,
            title: String,
            isSelected: Bool,
            config: SelectState.Option.Config
        ) {
            self.id = id
            self.title = title
            self.isSelected = isSelected
            self.config = config
        }
        
        public struct Config {
            
            let icon: Image
            let foreground: Color
            let background: Color
            
            let selectIcon: Image
            let selectForeground: Color
            let selectBackground: Color
            
            let mainBackground: Color
            
            let kind: Kind
            
            public init(
                icon: Image,
                foreground: Color,
                background: Color,
                selectIcon: Image,
                selectForeground: Color,
                selectBackground: Color,
                mainBackground: Color,
                kind: SelectState.Option.Config.Kind
            ) {
                self.icon = icon
                self.foreground = foreground
                self.background = background
                self.selectIcon = selectIcon
                self.selectForeground = selectForeground
                self.selectBackground = selectBackground
                self.mainBackground = mainBackground
                self.kind = kind
            }
            
            public enum Kind: Int {
                
                case small = 16
                case normal = 24
            }
        }
    }
}
