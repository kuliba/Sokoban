//
//  DisableCorCardsView.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 21.08.2024.
//

import SwiftUI

struct DisableCorCardsView: View {
    
    let text: String
    
    var body: some View {
        
        ZStack {
            
            Color.mainColorsGrayLightest
                .cornerRadius(90)
            
            HStack(spacing: 12) {
                
                ZStack {
                    
                    Circle()
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                    
                    Image.ic24SmsColor
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                }
                Text(text)
                    .font(.textBodyMR14180())
                    .lineLimit(3)
                    .foregroundColor(.mainColorsBlack)
                    .padding(.vertical, 8)
            }
            .padding(.horizontal, 8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 70)
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 0)
    }
}

struct DisableCorCardsView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        DisableCorCardsView(text: .disableForCorCards)
    }
}
