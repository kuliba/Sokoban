//
//  PageTitleConfig.swift
//  
//
//  Created by Andryusina Nataly on 02.09.2023.
//

import SwiftUI
import SharedConfigs

public extension UILanding.PageTitle {
    
    struct Config {
        
        public let title: TextConfig
        public let subtitle: TextConfig
                            
        func background(_ transparency: Bool) -> Color {
            
            transparency ? .clear : .white
        }
        
        public init(title: TextConfig, subtitle: TextConfig) {
            self.title = title
            self.subtitle = subtitle
        }
    }
}
