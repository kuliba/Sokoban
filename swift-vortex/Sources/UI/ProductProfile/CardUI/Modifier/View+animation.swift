//
//  View+animation.swift
//  
//
//  Created by Andryusina Nataly on 19.03.2024.
//

import SwiftUI

extension View {
    
    func animation(
        isShowingCardBack: Bool,
        cardWiggle: Bool,
        opacity: Values,
        radians: Values
    ) -> some View {
        
        self
            .modifier(FlipOpacity(
                percentage: isShowingCardBack ? opacity.startValue : opacity.endValue))
            .rotation3DEffect(
                .radians(isShowingCardBack ? radians.startValue : radians.endValue),
                axis: (0,1,0),
                perspective: 0.1)
            .rotation3DEffect(
                .degrees(cardWiggle ? -20 : 0),
                axis: (0, 1, 0))
    }
}
