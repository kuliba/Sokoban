//
//  LandingMultiLineHeader.swift
//  
//
//  Created by Andryusina Nataly on 31.08.2023.
//

import Foundation

extension Landing {
    
    public struct MultiLineHeader: Equatable {
        
        let backgroundColor: String
        let regularTextList, boldTextList: [String]?
        
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
