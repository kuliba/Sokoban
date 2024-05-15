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
        
        if let product = viewModel.model.product(productId: productID) {
            AnyView(itemView(MyProductsSectionItemViewModel.init(productData: product, model: viewModel.model)))
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
                .accessibilityIdentifier("DefaultMainCardName")
                .font(.textH4M16240())
                .foregroundColor(.mainColorsBlack)
        }
        .listRowInsets(EdgeInsets())
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 72)
        .padding(.leading, 12)
        .background(Color.mainColorsGrayLightest)
    }
}
