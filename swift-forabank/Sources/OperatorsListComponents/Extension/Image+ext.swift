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
        icon: Image
    ) -> some View {
        
        ZStack {
            
            Circle()
                .frame(width: 32, height: 32)
                .foregroundColor(backgroundColor)
                .background(backgroundColor)
            
            icon
                .frame(width: 16, height: 16)
                .foregroundColor(.white)
        }
    }
}
