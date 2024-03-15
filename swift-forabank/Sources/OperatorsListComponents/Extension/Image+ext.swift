//
//  Image+ext.swift
//
//
//  Created by Дмитрий Савушкин on 27.02.2024.
//

import SwiftUI

public extension Image {
    
    static func defaultIcon(
        backgroundColor: Color,
        foregroundColor: Color,
        icon: Image
    ) -> some View {
        
        ZStack {
            
            Circle()
                .frame(width: 32, height: 32)
                .foregroundColor(backgroundColor)
                .background(backgroundColor)
            
            icon
                .resizable()
                .renderingMode(.template)
                .frame(width: 24, height: 24)
                .foregroundColor(foregroundColor)
        }
    }
}
