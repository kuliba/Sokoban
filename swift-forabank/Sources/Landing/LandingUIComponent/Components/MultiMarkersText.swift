//
//  MultiMarkersText.swift
//  
//
//  Created by Andryusina Nataly on 13.09.2023.
//

import Tagged

extension UILanding.Multi {
    
    public struct MarkersText: Hashable {
        
        public let backgroundColor, style: String
        public let list: [Text]
        
        public init(
            backgroundColor: String,
            style: String,
            list: [Text]
        ) {
            self.backgroundColor = backgroundColor
            self.style = style
            self.list = list
        }
        
        public typealias Text = Tagged<_Text, String>
        public enum _Text {}
    }
}

extension UILanding.Multi.MarkersText {
    
    func imageRequests() -> [ImageRequest] {
        
        return []
    }
}
