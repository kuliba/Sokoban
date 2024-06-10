//
//  LandingMultiText.swift
//  
//
//  Created by Andryusina Nataly on 07.09.2023.
//

import Foundation
import Tagged

public extension UILanding.Multi {
    
    struct Texts: Equatable  {
        
        public let id: UUID
        public let texts: [Text]
        
        public init(id: UUID = UUID(), texts: [Text]) {
            self.id = id
            self.texts = texts
        }
        
        public typealias Text = Tagged<_Text, String>
        public enum _Text {}
    }
}

extension UILanding.Multi.Texts {
    
    func imageRequests() -> [ImageRequest] {
        
        return []
    }
}
