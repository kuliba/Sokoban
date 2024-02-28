//
//  SliderViewModel.swift
//
//
//  Created by Andryusina Nataly on 21.02.2024.
//

import Foundation
import SwiftUI

public final class SliderViewModel: ObservableObject {
    
    @Published private(set) var offsetX: CGFloat
    private let maxOffsetX: CGFloat
    
    public init(
        offsetX: CGFloat = 0,
        maxOffsetX: CGFloat
    ) {
        self.offsetX = offsetX
        self.maxOffsetX = maxOffsetX
    }
}

