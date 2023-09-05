//
//  IconWithTwoTextLines.swift
//  
//
//  Created by Andryusina Nataly on 02.09.2023.
//

import SwiftUI

public extension Landing {
    
    struct IconWithTwoTextLines {
        
        public let image: Image
        public let title, subTitle: String?
        
        public init(
            image: Image,
            title: String?,
            subTitle: String?
        ) {
            
            self.image = image
            self.title = title
            self.subTitle = subTitle
        }
    }
}
