//
//  TextsWithIconHorizontal.swift
//  
//
//  Created by Andryusina Nataly on 02.09.2023.
//

import SwiftUI

public extension Landing {
    
    struct TextsWithIconHorizontal: Equatable {
        
        public let image: Image
        public let title: String
        public let contentCenterAndPull: Bool
        
        public init(
            image: Image,
            title: String,
            contentCenterAndPull: Bool
        ) {
            self.image = image
            self.title = title
            self.contentCenterAndPull = contentCenterAndPull
        }
    }
}
