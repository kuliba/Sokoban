//
//  LandingPageTitle.swift
//  
//
//  Created by Andryusina Nataly on 31.08.2023.
//

import Foundation

extension Landing {
    
    public struct PageTitle: Equatable {
        
        public let text: String
        public let subtitle: String?
        public let transparency: Bool
        
        public init(
            text: String,
            subtitle: String?,
            transparency: Bool
        ) {
            self.text = text
            self.subtitle = subtitle
            self.transparency = transparency
        }
    }
}

