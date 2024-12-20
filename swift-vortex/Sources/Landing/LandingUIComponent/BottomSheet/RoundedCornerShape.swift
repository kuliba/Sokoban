//
<<<<<<<< HEAD:swift-forabank/Sources/UI/Components/BottomSheetComponent/RoundedCorner.swift
//  RoundedCorner.swift
========
//  RoundedCornerShape.swift
//  Vortex
>>>>>>>> origin/trunk:swift-vortex/Sources/Landing/LandingUIComponent/BottomSheet/RoundedCornerShape.swift
//
//
//  Created by Valentin Ozerov on 11.12.2024.
//

import SwiftUI

struct RoundedCorner: Shape {
    
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        
        return Path(path.cgPath)
    }
}
