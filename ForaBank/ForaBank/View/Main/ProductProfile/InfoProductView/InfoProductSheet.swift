//
//  InfoProductSheet.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 26.06.2023.
//

import SwiftUI

struct InfoProductSheet: View {
    
    let sendAll: InfoProductViewModel.ButtonModel
    let sendSelected: InfoProductViewModel.ButtonModel
    
    var body: some View {
        
        VStack {
            
            Image.ic24FileText
                .resizable()
                .padding(16)
                .frame(width: 64, height: 64, alignment: .center)
                .background(Color.mainColorsGrayLightest)
                .cornerRadius(90)
            
            Text("Реквизиты карты")
                .font(.textH3UnderlineM18240())
                .multilineTextAlignment(.center)
                .foregroundColor(Color.textSecondary)
                .frame(width: 310, height: 24, alignment: .center)
                .padding(.top, 10)
            
            Text("Вы можете поделиться всеми реквизитами (кроме CVV кода) или выбрать некоторые")
                .font(.textBodyMR14180())
                .multilineTextAlignment(.center)
                .foregroundColor(Color.textPlaceholder)
                .frame(width: 344, height: 40, alignment: .top)
                .padding(.top, 20)
            
            Button(action: sendSelected.action) {
                
                Text(sendSelected.title)
                    .font(.textH3UnderlineSB18240())
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color.textSecondary)
                    .frame(width: 328, height: 24, alignment: .center)
            }
            .frame(height: 56)
            .background(Color.mainColorsGrayLightest)
            .cornerRadius(12)
            .foregroundColor(Color.mainColorsBlack)
            .padding(.top, 35)
            
            Button(action: sendAll.action) {
                
                Text(sendAll.title)
                    .font(.textH3UnderlineSB18240())
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color.textSecondary)
                    .frame(width: 328, height: 24, alignment: .center)
            }
            .frame(height: 56)
            .background(Color.mainColorsGrayLightest)
            .cornerRadius(12)
            .foregroundColor(Color.mainColorsBlack)
            .padding(.top, 8)
        }
        .frame(width: 375, height: 397)
    }
}

struct InfoProductSheet_Previews: PreviewProvider {
    static var previews: some View {
        InfoProductSheet(
            sendAll: .init(id: .sendSelected, action: {}),
            sendSelected: .init(id: .sendAll, action: {})
        )
    }
}
