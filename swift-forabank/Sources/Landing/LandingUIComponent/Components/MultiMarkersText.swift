//
//  MultiMarkersText.swift
//  
//
//  Created by Andryusina Nataly on 13.09.2023.
//

import Foundation
import Tagged

extension UILanding.Multi {
    
    public struct MarkersText: Identifiable, Equatable {
        
        public let id: UUID
        let backgroundColor, style: String
        let list: [Text]
        
        public init(
            id: UUID = UUID(),
            backgroundColor: String,
            style: String,
            list: [Text]
        ) {
            self.id = id
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
