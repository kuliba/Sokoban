//
//  MultiLineHeader.swift
//  
//
//  Created by Andryusina Nataly on 02.09.2023.
//

import Foundation

public extension Landing {
    
    struct MultiLineHeader: Equatable, Identifiable {
        
        public let id = UUID()
        public let regularTextList: [String]?
        public let boldTextList: [String]?
                
        public init(
            regularTextList: [String]?,
            boldTextList: [String]?
        ) {
            self.regularTextList = regularTextList
            self.boldTextList = boldTextList
        }
    }
}

extension String: Identifiable {
    
    public typealias ID = Int
    public var id: Int {
        return hash
    }
}
