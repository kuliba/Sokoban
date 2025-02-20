//
//  DetailsCell.swift
//  Vortex
//
//  Created by Igor Malyarov on 20.02.2025.
//

import SwiftUI

public enum DetailsCell: Equatable {
    
    case field(
        Field
    )
    case product(
        Product
    )
    
    public struct Field: Equatable {
        
        public let image: Image?
        public let title: String
        public let value: String
        
        public init(
            image: Image?,
            title: String,
            value: String
        ) {
            self.image = image
            self.title = title
            self.value = value
        }
    }
    
    public struct Product: Equatable {
        
        public let title: String
        
        public init(
            title: String
        ) {
            self.title = title
        }
    }
}
