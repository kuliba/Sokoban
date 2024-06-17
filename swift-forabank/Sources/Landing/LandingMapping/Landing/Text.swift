//
//  Text.swift
//  
//
//  Created by Andryusina Nataly on 05.09.2023.
//

import Tagged

extension Landing.DataView.Multi {
    
    public struct Text: Decodable, Equatable {
        
        public let text: [Text]
        
        public init(text: [Text]) {
            self.text = text
        }
        
        public typealias Text = Tagged<_Text, String>
        public enum _Text {}
    }
}
