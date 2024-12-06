//
//  PaddingModifier.swift
//
//
//  Created by Valentin Ozerov on 06.12.2024.
//

import SwiftUI
import Foundation

struct PaddingsModifier: ViewModifier {
    
    let bottom: CGFloat?
    let horizontal: CGFloat?
    let vertical: CGFloat?
    
    init(
        bottom: CGFloat? = nil,
        horizontal: CGFloat? = nil,
        vertical: CGFloat? = nil
    ) {
        self.bottom = bottom
        self.horizontal = horizontal
        self.vertical = vertical
    }
    
    @ViewBuilder
    func body(content: Content) -> some View {
        
        switch (bottom, horizontal, vertical) {
        case (.none, .none, .none):
            content
            
        case let (.none, horizontal, vertical):
            content
                .padding(.horizontal, horizontal)
                .padding(.vertical, vertical)
            
        case let (bottom, .none, vertical):
            content
                .padding(.vertical, vertical)
                .padding(.bottom, bottom)
            
        case let (bottom, horizontal, .none):
            content
                .padding(.horizontal, horizontal)
                .padding(.bottom, bottom)
            
        case let (bottom, horizontal, vertical):
            content
                .padding(.horizontal, horizontal)
                .padding(.vertical, vertical)
                .padding(.bottom, bottom)
        }
    }
}
