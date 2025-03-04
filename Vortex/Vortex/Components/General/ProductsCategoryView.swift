//
//  ProductsCategoryView.swift
//  Vortex
//
//  Created by Andryusina Nataly on 02.11.2024.
//

import SwiftUI

class ProductsCategorySettings {
    
    static let shared = ProductsCategorySettings()
    var savingsAccountWasShown: Bool = false
}

struct ProductsCategoryView: View {
    
    let newImplementation: Bool
    let isSelected: Bool
    let title: String
    let isSavingsAccount: Bool
    
    var isShowingDot: Bool {
        isSavingsAccount && !isSelected && !ProductsCategorySettings.shared.savingsAccountWasShown
    }
    
    init(
        newImplementation: Bool,
        isSelected: Bool,
        title: String,
        isSavingsAccount: Bool
    ) {
        self.newImplementation = newImplementation
        self.isSelected = isSelected
        self.title = title
        self.isSavingsAccount = isSavingsAccount
        if isSavingsAccount, isSelected {
            ProductsCategorySettings.shared.savingsAccountWasShown = true
        }
    }
    
    var body: some View {
        
        if newImplementation {
            category()
        } else {
            categoryWithDots()
        }
    }
    
    @ViewBuilder
    private func category() -> some View {
        
        let textColor = isSelected ? Color.textSecondary : .textPlaceholder
        
        Text(title)
            .font(.textBodySM12160())
            .foregroundColor(textColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(capsuleWithDots())
    }
    
    @ViewBuilder
    private func capsuleWithDots() -> some View {
        
        let capsuleColor = isSelected ? Color.mainColorsGrayLightest : .clear
        let circleColor = isShowingDot ? Color.mainColorsRed : .mainColorsGrayLightest

        ZStack(alignment: .topTrailing) {
            Capsule().foregroundColor(capsuleColor)
            Circle()
                .frame(width: 4, height: 4, alignment: .center)
                .foregroundColor(circleColor)
        }
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
        ProductsCategoryView(newImplementation: true, isSelected: true, title: "title", isSavingsAccount: true)
        ProductsCategoryView(newImplementation: false, isSelected: true, title: "title", isSavingsAccount: true)
        ProductsCategoryView(newImplementation: true, isSelected: false, title: "title", isSavingsAccount: false)
        ProductsCategoryView(newImplementation: false, isSelected: false, title: "title", isSavingsAccount: false)
    }
}
