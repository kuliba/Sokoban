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
                .frame(width: 40, height: 40)
                .background(backgroundColor)
            
            icon
                .frame(width: 24, height: 24)
                .foregroundColor(.white)
        }
    }
}
