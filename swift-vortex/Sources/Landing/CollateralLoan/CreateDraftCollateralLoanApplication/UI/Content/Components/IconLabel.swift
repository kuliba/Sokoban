//
//  IconLabel.swift
//
//
//  Created by Valentin Ozerov on 28.01.2025.
//

import SwiftUI

struct IconLabel<IconView: View>: View {
    
    let text: String
    let makeIconView: () -> IconView
    let iconColor: Color
    
    var body: some View {

        HStack(alignment: .top, spacing: 16) {
            
            makeIconView()
                .foregroundColor(iconColor)
                .frame(width: 24, height: 24)
            
            Text(text)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .contentShape(Rectangle())
    }
}
