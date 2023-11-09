//
//  LandingMultiText.swift
//  
//
//  Created by Andryusina Nataly on 07.09.2023.
//

import Tagged

public extension UILanding.Multi {
    
    struct Texts: Hashable  {
        
        public let texts: [Text]
        
        public init(texts: [Text]) {
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
