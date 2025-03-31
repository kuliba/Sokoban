//
//  SwiftUIView.swift
//  
//
//  Created by Igor Malyarov on 31.03.2025.
//

import SwiftUI

public struct FAQPlaceholderViewConfig: Equatable {
    
    public let background: Color
    public let cornerRadius: CGFloat
    public let count: Int
    public let item: Item
    public let edges: EdgeInsets
    public let spacing: CGFloat
    
    public  init(
        background: Color,
        cornerRadius: CGFloat,
        count: Int,
        item: Item,
        edges: EdgeInsets,
        spacing: CGFloat
    ) {
        self.background = background
        self.cornerRadius = cornerRadius
        self.count = count
        self.item = item
        self.edges = edges
        self.spacing = spacing
    }
}

extension FAQPlaceholderViewConfig {
    
    public struct Item: Equatable {
        
        public let cornerRadius: CGFloat
        public let height: CGFloat
        
        public init(
            cornerRadius: CGFloat,
            height: CGFloat
        ) {
            self.cornerRadius = cornerRadius
            self.height = height
        }
    }
}
