//
//  PaddingModifier.swift
//
//
//  Created by Valentin Ozerov on 06.12.2024.
//

import SwiftUI
import Foundation

struct PaddingsModifier: ViewModifier {
    
    let top: CGFloat?
    let bottom: CGFloat?
    let horizontal: CGFloat?
    let vertical: CGFloat?
    
    init(
        top: CGFloat? = nil,
        bottom: CGFloat? = nil ,
        horizontal: CGFloat? = nil,
        vertical: CGFloat? = nil
    ) {
        self.top = top
        self.bottom = bottom
        self.horizontal = horizontal
        self.vertical = vertical
    }
    
    @ViewBuilder
    func body(content: Content) -> some View {

        switch (top, bottom, horizontal, vertical) {
        case (.none, .none, .none, .none):
            content
                        
        case let (.none, .none, horizontal, vertical):
            content
                .padding(.horizontal, horizontal)
                .padding(.vertical, vertical)
            
        case let (.none, bottom, .none, vertical):
            content
                .padding(.vertical, vertical)
                .padding(.bottom, bottom)
            
        case let (.none, bottom, horizontal, .none):
            content
                .padding(.horizontal, horizontal)
                .padding(.bottom, bottom)
            
        case let (.none, bottom, horizontal, vertical):
            content
                .padding(.horizontal, horizontal)
                .padding(.vertical, vertical)
                .padding(.bottom, bottom)
            
        case let (top, .none, horizontal, vertical):
            content
                .padding(.top, top)
                .padding(.horizontal, horizontal)
                .padding(.vertical, vertical)

        default:
            content
        }
    }
}
