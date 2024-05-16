//
//  MyProductsSectionView+mainCard.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 15.05.2024.
//

import SwiftUI

extension MyProductsSectionView {
    
    func mainCardView(
        _ productID: ProductData.ID
    ) -> some View {
        
        if let product = viewModel.productByID(productID) {
            AnyView(itemView(viewModel.createSectionItemViewModel(product)))
        } else {
            AnyView(defaultMainCard())
        }
    }
    
    private func defaultMainCard() -> some View {
        
        HStack(spacing: 16) {
            
            Image.cardPlaceholder
                .renderingMode(.original)
                .resizable()
                .scaledToFit()
                .frame(width: 32)
                .accessibilityIdentifier("DefaultMainCardProductIcon")
            
            Image.ic16MainCardGrey
                .renderingMode(.template)
                .resizable()
                .aspectRatio(1, contentMode: .fit)
                .frame(width: 16, height: 16, alignment: .center)
                .foregroundColor(.mainColorsGray)
                .accessibilityIdentifier("DefaultMainCardCloverIcon")
            
            Text("Основная карта")
                .lineLimit(1)
                .font(.textH4M16240())
                .foregroundColor(.mainColorsBlack)
                .accessibilityIdentifier("DefaultMainCardName")
        }
        .listRowInsets(EdgeInsets())
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 72)
        .padding(.leading, 12)
        .background(Color.barsBars)
        .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onEnded({ value in
                // disable right swipe
                if value.translation.width > 0 {
                }
            }))
    }
}
