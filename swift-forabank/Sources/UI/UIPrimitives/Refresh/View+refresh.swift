//
//  View+refresh.swift
//
//
//  Created by Andryusina Nataly on 24.09.2024.
//

import SwiftUI

public extension View {
    
    func refresh(
        action: @escaping () -> Void,
        nameCoordinateSpace: String = "scroll",
        offsetForStartUpdate: CGFloat = -100
    ) -> some View {
        
        modifier(RefreshModifier(
            action: action,
            nameCoordinateSpace: nameCoordinateSpace,
            offsetForStartUpdate: offsetForStartUpdate)
        )
    }
}
