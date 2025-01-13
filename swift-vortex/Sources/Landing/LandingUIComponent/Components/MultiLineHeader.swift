//
//  MultiLineHeader.swift
//  
//
//  Created by Andryusina Nataly on 02.09.2023.
//

import Foundation
import SwiftUI

public extension UILanding.Multi {
    
    struct LineHeader: Equatable {
        
        let id: UUID
        let backgroundColor: String
        let regularTextList: [String]?
        let boldTextList: [String]?
                
        public init(
            id: UUID = UUID(),
            backgroundColor: String,
            regularTextList: [String]?,
            boldTextList: [String]?
        ) {
            self.id = id
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
