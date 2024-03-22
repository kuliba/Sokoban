//
//  HeaderBackView.swift
//
//
//  Created by Andryusina Nataly on 18.03.2024.
//

import SwiftUI

public struct HeaderBackView: View {
    
    let cardInfo: CardInfo
    let action: () -> Void
    let config: Config
    
    public init(
        cardInfo: CardInfo,
        action: @escaping () -> Void,
        config: Config
    ) {
        self.cardInfo = cardInfo
        self.action = action
        self.config = config
    }
    
    public var body: some View {
        
        VStack (alignment: .leading) {
            
            if !cardInfo.numberToDisplay.isEmpty {
                
                HStack {
                    
                    Text(cardInfo.numberToDisplay)
                        .font(config.fonts.number)
                        .foregroundColor(config.colors.foreground)
                        .accessibilityIdentifier("numberToDisplay")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Button(action: action) {
                        
                        config.images.copy
                            .resizable()
                            .frame(width: 24, height: 24, alignment: .center)
                            .foregroundColor(config.colors.foreground)
                    }
                }
            }
            
            Text(cardInfo.owner)
                .font(config.fonts.card)
                .foregroundColor(config.colors.foreground)
                .accessibilityIdentifier("ownerName")
                .padding(.top, 12 / UIScreen.main.scale)
        }
    }
}

struct HeaderBackView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ZStack {
            
            Color.gray
            HeaderBackView(
                cardInfo: .previewWiggleFalse,
                action: { print("action") },
                config: .config(.previewCard)
            )
        }
    }
}
