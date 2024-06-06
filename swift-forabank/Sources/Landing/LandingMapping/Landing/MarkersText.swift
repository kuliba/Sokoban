//
//  MarkersText.swift
//  
//
//  Created by Andryusina Nataly on 05.09.2023.
//

import Tagged

extension Landing.DataView.Multi {
    
    public struct MarkersText: Decodable, Equatable {
        
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
