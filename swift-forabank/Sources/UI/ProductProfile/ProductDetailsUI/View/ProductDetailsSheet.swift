//
//  ProductDetailsSheet.swift
//
//
//  Created by Andryusina Nataly on 12.03.2024.
//

import SwiftUI

struct ButtonModel {
    
    let id: ID
    
    enum ID {
        
        case sendSelected
        case sendAll
    }
    
    var title: String {
        
        switch id {
            
        case .sendSelected:
            return "Отправить выбранные"
        case .sendAll:
            return "Отправить все"
        }
    }
    
    let action: () -> Void
}

struct ProductDetailsSheet: View {
    
    let sendAll: ButtonModel
    let sendSelected: ButtonModel
    
    var body: some View {
        
        VStack {
            
            Image(systemName: "doc.text") //ic24FileText
                .resizable()
                .padding(16)
                .frame(width: 64, height: 64, alignment: .center)
                .background(Color(red: 0.965, green: 0.965, blue: 0.969))//Color.mainColorsGrayLightest)
                .cornerRadius(90)
                .accessibilityIdentifier("InfoProductSheetIcon")
            
            Text("Реквизиты карты")
                .font(.body)//.textH3UnderlineM18240())
                .multilineTextAlignment(.center)
                .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.11))//.textSecondary)
                .frame(width: 310, height: 24, alignment: .center)
                .padding(.top, 10)
                .accessibilityIdentifier("InfoProductSheetTitle")
            
            Text("Вы можете поделиться всеми реквизитами (кроме CVV кода) или выбрать некоторые")
                .font(.callout)//.textBodyMR14180())
                .multilineTextAlignment(.center)
                .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))//.textPlaceholder)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 20)
                .padding()
                .accessibilityIdentifier("InfoProductSheetSubtitle")
            
            Button(action: sendSelected.action) {
                
                Text(sendSelected.title)
                    .font(.body)//.textH3UnderlineSb18240())
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.11))//.textSecondary)
                    .frame(width: 328, height: 24, alignment: .center)
            }
            .frame(height: 56)
            .background(Color(red: 0.965, green: 0.965, blue: 0.969))//.mainColorsGrayLightest)
            .cornerRadius(12)
            .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.11))//.mainColorsBlack такой же как и textSecondary)
            .padding(.top, 35)
            .accessibilityIdentifier("InfoProductSheetTopButton")
            
            Button(action: sendAll.action) {
                
                Text(sendAll.title)
                    .font(.body)//.textH3UnderlineSb18240())
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.11))//.textSecondary)
                    .frame(width: 328, height: 24, alignment: .center)
            }
            .frame(height: 56)
            .background(Color(red: 0.965, green: 0.965, blue: 0.969))//.mainColorsGrayLightest)
            .cornerRadius(12)
            .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.11))//.mainColorsBlack)
            .padding(.top, 8)
            .accessibilityIdentifier("InfoProductSheetBottomButton")
        }
        .frame(height: 397)
        .frame(maxWidth: .infinity)
    }
}

struct ProductDetailsSheet_Previews: PreviewProvider {
    static var previews: some View {
        ProductDetailsSheet(
            sendAll: .init(id: .sendSelected, action: {}),
            sendSelected: .init(id: .sendAll, action: {})
        )
    }
}
