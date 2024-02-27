//
//  SliderViewModel.swift
//
//
//  Created by Andryusina Nataly on 21.02.2024.
//

import Foundation
import SwiftUI

final class SliderViewModel: ObservableObject {
    
    @Published private(set) var offsetX: CGFloat
    private let maxOffsetX: CGFloat
    
    private let didSwitchOn: () -> Void

    init(
        offsetX: CGFloat = 0,
        maxOffsetX: CGFloat,
        didSwitchOn: @escaping () -> Void
    ) {
        self.offsetX = offsetX
        self.maxOffsetX = maxOffsetX
        self.didSwitchOn = didSwitchOn
    }
    
    func dragOnChanged(_ translationWidth: CGFloat) {
        
        if translationWidth > 0 && translationWidth <= maxOffsetX {
            
            offsetX = translationWidth
        }
    }
    
    func dragOnEnded() {
        if offsetX > maxOffsetX/2 {
            offsetX = maxOffsetX
            didSwitchOn()
        } else {
            offsetX = 0
        }
    }
    
    func reset() {
        offsetX = 0
    }
}

