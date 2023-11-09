//
//  MultiLineHeader.swift
//  
//
//  Created by Andryusina Nataly on 02.09.2023.
//

import Foundation
import SwiftUI

public extension UILanding.Multi {
    
    struct LineHeader: Hashable, Identifiable {
        
        public var id: Self { self }
        public let backgroundColor: String
        public let regularTextList: [String]?
        public let boldTextList: [String]?
                
        public init(
            backgroundColor: String,
            regularTextList: [String]?,
            boldTextList: [String]?
        ) {
            self.backgroundColor = backgroundColor
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

extension UILanding.Multi.LineHeader {
    
    func imageRequests() -> [ImageRequest] {
        
        return []
    }
}
