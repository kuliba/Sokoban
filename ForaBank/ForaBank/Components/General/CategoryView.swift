//
//  CategoryView.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 02.11.2024.
//

import SwiftUI

struct CategoryView: View {
    
    let newImplementation: Bool
    let isSelected: Bool
    let title: String
    
    @ViewBuilder
    var body: some View {
        
        if newImplementation {
            category()
        } else {
            categoryWithDots()
        }
    }
    
    @ViewBuilder
    private func category() -> some View {
        
        let capsuleColor = isSelected ? Color.mainColorsGrayLightest : .clear
        let textColor = isSelected ? Color.textSecondary : .textPlaceholder
        
        Text(title)
            .font(.textBodySM12160())
            .foregroundColor(textColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Capsule().foregroundColor(capsuleColor))
    }
    
    @ViewBuilder
    private func categoryWithDots() -> some View {
        
        let circleColor = isSelected ? Color.mainColorsRed : .mainColorsGrayLightest
        let textColor = isSelected ? Color.textSecondary : .textPlaceholder
        
        HStack(spacing: 4) {
            
            Circle()
                .frame(width: 4, height: 4, alignment: .center)
                .foregroundColor(circleColor)
            
            Text(title)
                .font(.textBodySM12160())
                .foregroundColor(textColor)
                .padding(.vertical, 6)
        }
    }
}

#Preview {
    Group {
        CategoryView(newImplementation: true, isSelected: true, title: "title")
        CategoryView(newImplementation: false, isSelected: true, title: "title")
        CategoryView(newImplementation: true, isSelected: false, title: "title")
        CategoryView(newImplementation: false, isSelected: false, title: "title")
    }
}
