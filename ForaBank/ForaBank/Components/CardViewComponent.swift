//
//  CardViewComponent.swift
//  ForaBank
//
//  Created by Дмитрий on 21.02.2022.
//

import Foundation
import SwiftUI

extension MainCardComponentView {
   
    class ViewModel: ObservableObject {
        
        let logo: Image
        var name: String
        var balance: String
        let fontColor: Color
        let cardNumber: String
        let backgroundColor: Color
        let paymentSystem: Image
        

        internal init(logo: Image, name: String, balance: String, fontColor: Color, cardNumber: String, backgroundColor: Color, paymentSystem: Image) {
            
            self.logo = logo
            self.name = name
            self.balance = balance
            self.fontColor = fontColor
            self.cardNumber = cardNumber
            self.backgroundColor = backgroundColor
            self.paymentSystem = paymentSystem
        }
    }
}

struct MainCardComponentView: View {

    @ObservedObject var viewModel: MainCardComponentView.ViewModel
    
    var body: some View {
    
        VStack(alignment: .leading) {
            
            HStack(alignment: .center){
                
                Image.ic24LogoForaColor
                    .frame(width: 18.8, height: 18.8)
                    .foregroundColor(.white)
                
                Circle()
                    .frame(width: 2.27, height: 2.38, alignment: .center)
                    .foregroundColor(viewModel.fontColor)
                
                Text(viewModel.cardNumber)
                    .font(Font(.init(.system, size: 12)))
                    .foregroundColor(viewModel.fontColor)
            }
            .padding(.leading, 13)
            .padding(.top, 12)
            
            VStack(alignment: .leading, spacing: 4) {
                
                Spacer()
                
                Text(viewModel.name)
                    .font(Font(.init(.system, size: 14)))
                    .foregroundColor(viewModel.fontColor)
                    .fixedSize(horizontal: false, vertical: true)

                HStack{
                    Text(viewModel.balance)
                        .font(Font(.init(.system, size: 14)))
                        .foregroundColor(viewModel.fontColor)

                    Spacer()
                    
                    viewModel.paymentSystem
                        .frame(width: 28, height: 28, alignment: .center)
                }
            }
            .padding(.trailing, 16)
            .padding(.leading, 12)
            .padding(.bottom, 12)
        }
        .frame(width: 164, height: 104)
        .background(viewModel.backgroundColor)
        .cornerRadius(12)
    }
}

struct MainCardView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group{
            
            MainCardComponentView(viewModel: MainCardComponentView.ViewModel(logo: .ic16CreditCard, name: "Classic", balance: "170 897 ₽", fontColor: .white, cardNumber: "7854", backgroundColor: .cardClassic, paymentSystem: .init(systemName: "card_visa_logo")))
                .previewLayout(.fixed(width: 170, height: 120))

            MainCardComponentView(viewModel: MainCardComponentView.ViewModel(logo: .ic16CreditCard, name: "Infinity", balance: "170 897 ₽", fontColor: .white, cardNumber: "7854", backgroundColor: .cardInfinite, paymentSystem: .init(systemName: "card_visa_logo")))
                .previewLayout(.fixed(width: 170, height: 120))
            
            MainCardComponentView(viewModel: MainCardComponentView.ViewModel(logo: .ic16CreditCard, name: "Classic", balance: "170 897 ₽", fontColor: .white, cardNumber: "7854", backgroundColor: .cardGold, paymentSystem: .init(systemName: "card_mastercard_logo")))
                .previewLayout(.fixed(width: 170, height: 120))
            
            MainCardComponentView(viewModel: MainCardComponentView.ViewModel(logo: .ic16CreditCard, name: "Rio", balance: "170 897 ₽", fontColor: .white, cardNumber: "7854", backgroundColor: .cardRIO, paymentSystem: .init(systemName: "card_mastercard_logo")))
                .previewLayout(.fixed(width: 170, height: 120))
            
            MainCardComponentView(viewModel: MainCardComponentView.ViewModel(logo: .ic16CreditCard, name: "Текущий зарплатный счет", balance: "170 897 ₽", fontColor: .white, cardNumber: "7854", backgroundColor: .cardAccount, paymentSystem: .init(systemName: "card_mastercard_logo")))
                .previewLayout(.fixed(width: 170, height: 120))
        }
    }
}
