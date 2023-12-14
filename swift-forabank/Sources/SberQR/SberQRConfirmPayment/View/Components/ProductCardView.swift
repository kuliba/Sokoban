//
//  ProductCardView.swift
//
//
//  Created by Igor Malyarov on 14.12.2023.
//

import SwiftUI

struct ProductCardView: View {
    
    let productCard: ProductCard
    let config: ProductCardConfig
    
    private let cardSize = CGSize(width: 112, height: 71)
    private let logoSize = CGSize(width: 22, height: 36)
    private let shadowSize = CGSize(width: 88, height: 54)
    private let cardInsets = EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
    
    private var offsetY: CGFloat {
        
        (cardSize.height - shadowSize.height) + 4
    }
    
    var body: some View {
        
        ZStack(alignment: .top) {
            
            shadow
            
            ZStack(alignment: .topTrailing) {
                
                cardView()
                    .frame(cardSize)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                
                selectedCardMarkView()
            }
        }
    }
    
    private func cardView() -> some View {
        
        HStack(alignment: .top) {
            
            cardDataView()
                .frame(maxWidth: .infinity, alignment: .leading)
            
            logoView()
                .padding(.top, 4)
        }
        .padding(cardInsets)
        .background(background)
    }
    
    private func cardDataView() -> some View {
        
        VStack(alignment: .leading) {
            
            HStack(spacing: 9) {
                
                cardIcon()
                    .frame(.size16)
                    .frame(.size20)
                                
                cardNumber()
            }
            
            Spacer()
            
            cardTitle()
            balanceView()
        }
    }
    
    @ViewBuilder
    private func cardIcon() -> some View {
        
        productCard.look.cardIcon.image(orColor: .clear)
    }
    
    private func cardNumber() -> some View {
        
        text(productCard.data.number, config: config.number)
    }
    
    private func cardTitle() -> some View {
        
        text(productCard.data.title, config: config.title)
    }
    
    private func balanceView() -> some View {
        
        text(productCard.data.balanceFormatted, config: config.balance)
    }
    
    private func logoView() -> some View {
        
        productCard.look.logo.image(orColor: .clear)
            .frame(logoSize)
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
            .blur(radius: 12)
    }
    
    private func text(
        _ text: String,
        config: TextConfig
    ) -> some View {
        
        Text(text)
            .font(config.textFont)
            .foregroundColor(config.textColor)
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
