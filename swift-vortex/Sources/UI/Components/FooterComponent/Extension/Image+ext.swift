//
//  Image+ext.swift
//
//
//  Created by Дмитрий Савушкин on 27.02.2024.
//

import SwiftUI

public extension Image {
    
    static func defaultIcon(
        foregroundColor: Color,
        backgroundColor: Color,
        icon: Image
    ) -> some View {
        
        ZStack {
            
            Circle()
                .foregroundColor(backgroundColor)
                .frame(width: 64, height: 64)
            
            icon
                .resizable()
                .renderingMode(.template)
                .foregroundColor(foregroundColor)
                .frame(width: 24, height: 24)
        }
    }
}
