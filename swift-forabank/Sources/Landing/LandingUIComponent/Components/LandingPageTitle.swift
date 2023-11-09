//
//  LandingPageTitle.swift
//  
//
//  Created by Andryusina Nataly on 02.09.2023.
//

import Foundation

public extension UILanding {
    
    struct PageTitle: Hashable {
        
        public let text: String
        public let subTitle: String?
        public let transparency: Bool
        
        public init(
            text: String,
            subTitle: String?,
            transparency: Bool
        ) {
            self.text = text
            self.subTitle = subTitle
            self.transparency = transparency
        }
    }
}

extension UILanding.PageTitle {
    
    func imageRequests() -> [ImageRequest] {
        
        return []
    }
}

