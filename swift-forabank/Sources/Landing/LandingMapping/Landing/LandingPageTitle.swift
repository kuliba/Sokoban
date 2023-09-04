//
//  LandingPageTitle.swift
//  
//
//  Created by Andryusina Nataly on 31.08.2023.
//

import Foundation

extension Landing {
    
    public struct PageTitle: Equatable {
        
        let text: String
        let transparency: Bool
        
        public init(
            text: String,
            transparency: Bool
        ) {
            self.text = text
            self.transparency = transparency
        }
    }
}

