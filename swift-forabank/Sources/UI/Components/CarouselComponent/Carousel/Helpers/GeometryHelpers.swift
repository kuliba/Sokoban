//
//  GeometryHelpers.swift
//
//
//  Created by Disman Dmitry on 28.02.2024.
//

import SwiftUI

struct GeometryHelpers {
    
    static func getSpoilerUnitPoint(
        screenWidth: CGFloat,
        xOffset: CGFloat
    ) -> UnitPoint {
                
        guard
            xOffset > 0,
            screenWidth > 0
        else { return .zero }
        
        let xUnitPoint = xOffset/screenWidth
        
        return UnitPoint(x: xUnitPoint, y: 0)
    }
}
