//
//  DetailsCell.swift
//  Vortex
//
//  Created by Igor Malyarov on 20.02.2025.
//

import SwiftUI

public enum DetailsCell: Equatable {
    
    case field(Field)
    case product(Product)
    
    public struct Field: Equatable {
        
        public let image: Image?
        public let isLarge: Bool
        public let title: String
        public let value: String
        
        public init(
            image: Image?,
            isLarge: Bool = false,
            title: String,
            value: String
        ) {
            self.image = image
            self.isLarge = isLarge
            self.title = title
            self.value = value
        }
    }
    
    public struct Product: Equatable {
        
        public let title: String
        public let icon: Image?
        public let name: String
        public let formattedBalance: String
        public let description: String
        
        public init(
            title: String,
            icon: Image?,
            name: String,
            formattedBalance: String,
            description: String
        ) {
            self.title = title
            self.icon = icon
            self.name = name
            self.formattedBalance = formattedBalance
            self.description = description
        }
    }
}
