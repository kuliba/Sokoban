//
//  CVVView.swift
//  
//
//  Created by Andryusina Nataly on 18.03.2024.
//

import SwiftUI

struct CVVView: View {
    
    let cardInfo: CardInfo
    @State private var showDotsAnimation: Bool
    let config: Config
    let action: () -> Void
    
    init(
        cardInfo: CardInfo,
        showDotsAnimation: Bool = false,
        config: Config,
        action: @escaping () -> Void
    ) {
        self.cardInfo = cardInfo
        self.showDotsAnimation = showDotsAnimation
        self.config = config
        self.action = action
    }
    
    var body: some View {
        
        VStack {
            
            ZStack {
                
                Button(cardInfo.cvvToDisplay, action: action)
                    .font(config.fonts.card)
                    .foregroundColor(config.colors.foreground)
                
                if showDotsAnimation { DotsAnimations() }
            }
            .frame(width: 76, height: 40)
            .background(RoundedRectangle(cornerRadius: 8)
                .foregroundColor(config.colors.background)
                .opacity(0.5)
            )
            .padding(.trailing, 12 / UIScreen.main.scale)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
}

struct CVVView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        CVVView(
            cardInfo: .previewWiggleTrue,
            config: .config(.preview),
            action: { print("cvv tap")})
    }
}
