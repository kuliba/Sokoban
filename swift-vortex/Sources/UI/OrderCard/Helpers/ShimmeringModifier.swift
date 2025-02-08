//
//  ShimmeringModifier.swift
//
//
//  Created by Дмитрий Савушкин on 09.12.2024.
//

import SwiftUI

struct ShimmeringModifier: ViewModifier {
    
    let needShimmering: Bool
    let color: Color
    
    init(
        _ needShimmering: Bool = false,
        _ color: Color
    ) {
        self.needShimmering = needShimmering
        self.color = color
    }
    
    func body(content: Content) -> some View {
        if needShimmering {
            content
                .background(color)
                .cornerRadius(90)
                .shimmering()
        } else {
            content
        }
    }
}
