//
//  ProductCardView.swift
//
//
//  Created by Igor Malyarov on 14.12.2023.
//

import PrimitiveComponents
import SwiftUI

public struct ProductCardView: View {
    
    let productCard: ProductCard
    let config: ProductCardConfig
    
    public init(
        productCard: ProductCard,
        config: ProductCardConfig
    ) {
        self.productCard = productCard
        self.config = config
    }
    
    private let cardSize = CGSize(width: 112, height: 71)
    private let logoSize = CGSize(width: 22, height: 36)
    private let shadowSize = CGSize(width: 88, height: 54)
    private let cardInsets = EdgeInsets(top: 12, leading: 8, bottom: 8, trailing: 8)
    
    private var offsetY: CGFloat {
        
        (cardSize.height - shadowSize.height) + 4
    }
    
    public var body: some View {
        
        ZStack(alignment: .top) {
            
            shadow
            
            ZStack(alignment: .topTrailing) {
                
                cardView()
                
                selectedCardMarkView()
            }
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
        .frame(cardSize)
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
    
    private func selectedCardMarkView() -> some View {
        
        productCard.look.mainCardMark.image(orColor: .clear)
            .frame(.size16)
            .padding(.top, 10)
            .padding(.trailing, 10)
    }
    
    @ViewBuilder
    private var background: some View {
        
        productCard.look.background
            .image(orColor: productCard.look.backgroundColor)
            .background(Color.white)
    }
    
    private var shadow: some View {
        
        config.shadowColor
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .frame(shadowSize)
            .padding(.top, offsetY)
            .padding(.bottom, 4)
            .blur(radius: 4)
    }
}

struct ProductCardView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        VStack(spacing: 32) {
            
            productCardView(.preview)
            productCardView(.preview2)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
    
    private static func productCardView(
        _ productCard: ProductCard
    ) -> some View {
        
        ProductCardView(productCard: productCard, config: .default)
    }
}
