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
    
    func dragOnChanged(_ value: DragGesture.Value) {
        
        if value.translation.width > 0 && offsetX <= maxOffsetX {
            
            offsetX = value.translation.width
        }
    }
    
    func dragOnEnded() {
        if offsetX > maxOffsetX/2 {
            didSwitchOn()
        } else {
            offsetX = 0
        }
    }
    
    func reset() {
        offsetX = 0
    }
}

