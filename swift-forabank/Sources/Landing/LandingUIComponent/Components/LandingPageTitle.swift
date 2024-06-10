//
//  LandingPageTitle.swift
//  
//
//  Created by Andryusina Nataly on 02.09.2023.
//

import Foundation

public extension UILanding {
    
    struct PageTitle: Equatable {
        
        public let id: UUID
        public let text: String
        public let subTitle: String?
        public let transparency: Bool
        
        public init(
            id: UUID = UUID(),
            text: String,
            subTitle: String?,
            transparency: Bool
        ) {
            self.id = id
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

