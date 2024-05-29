//
//  ProductCardView.swift
//
//
//  Created by Igor Malyarov on 14.12.2023.
//

import SharedConfigs
import SwiftUI
import UIPrimitives

public struct ProductCardView: View {
    
    let productCard: ProductCard
    let config: ProductCardConfig
    let isSelected: Bool
    
    public init(
        productCard: ProductCard,
        config: ProductCardConfig,
        isSelected: Bool
    ) {
        self.productCard = productCard
        self.config = config
        self.isSelected = isSelected
    }
    
    private let logoSize = CGSize(width: 22, height: 36)
    private let shadowSize = CGSize(width: 88, height: 54)
    private let cardInsets = EdgeInsets(top: 12, leading: 8, bottom: 8, trailing: 8)
    
    private var offsetY: CGFloat {
        
        (config.cardSize.height - shadowSize.height) + 4
    }
    
    public var body: some View {
        
        ZStack(alignment: .topLeading){
            
            ZStack(alignment: .topTrailing) {
                
                cardView()
                
                mainCardMarkView()
            }
            selectedCardMarkView()
        }
    }
    
    private func cardView() -> some View {
        
        VStack(alignment: .leading, spacing: 4) {
            
            cardNumber()
                .padding(.leading, 29)
            
            cardTitle()
                .frame(maxHeight: .infinity, alignment: .bottom)
            balanceView()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(cardInsets)
        .background(background)
        .frame(config.cardSize)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private func cardNumber() -> some View {
        
        productCard.data.number.text(withConfig: config.number)
    }
    
    private func cardTitle() -> some View {
        
        productCard.data.title.text(withConfig: config.title)
    }
    
    private func balanceView() -> some View {
        
        productCard.data.balanceFormatted.text(withConfig: config.balance)
    }
    
    private func mainCardMarkView() -> some View {
        
        productCard.look.mainCardMark.image(orColor: .clear)
            .frame(.size16)
            .padding(.top, 8)
            .padding(.trailing, 8)
    }
    
    @ViewBuilder
    private func selectedCardMarkView() -> some View {
        
        if isSelected {
            
            ZStack {
                Rectangle()
                    .fill(productCard.look.backgroundColor)
                config.selectedImage
                    .renderingMode(.original)
                    .opacity(0.9)
            }
            .frame(.size18)
            .padding(.top, 8)
            .padding(.leading, 8)
        }
    }
    
    @ViewBuilder
    private var background: some View {
        
        productCard.look.background
            .image(orColor: productCard.look.backgroundColor)
            .background(Color.white)
    }
}

struct ProductCardView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        VStack(spacing: 32) {
            
            productCardView(.preview, true)
            productCardView(.preview2, false)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
    
    private static func productCardView(
        _ productCard: ProductCard,
        _ isSelected: Bool
    ) -> some View {
        
        ProductCardView(productCard: productCard, config: .preview, isSelected: isSelected)
    }
}
