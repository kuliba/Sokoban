//
//  CardViewComponent.swift
//  ForaBank
//
//  Created by Дмитрий on 21.02.2022.
//

import Foundation
import SwiftUI

extension MainCardComponentView {
    
    class ViewModel: Identifiable, ObservableObject {
        
        let logo: Image
        @Published var name: String
        @Published var balance: String
        @Published var status: Status
        let fontColor: Color
        let cardNumber: String
        let backgroundColor: Color
        let paymentSystem: Image?
        let backgroundImage: Image?
        
        
        
        internal init(logo: Image, name: String, balance: String, fontColor: Color, cardNumber: String, backgroundColor: Color, paymentSystem: Image?, status: Status, backgroundImage: Image?) {
            
            self.logo = logo
            self.name = name
            self.balance = balance
            self.fontColor = fontColor
            self.cardNumber = cardNumber
            self.backgroundColor = backgroundColor
            self.status = status
            self.backgroundImage = backgroundImage
            self.paymentSystem = paymentSystem
            
        }
        
        enum Status {
            case active
            case notActivated
            case blocked
            
            var image: Image? {
                switch self {
                    case .active: return nil
                    case .notActivated: return Image.ic16ArrowRight
                    case .blocked: return Image.ic16Lock
                }
            }
        }
    }
}

struct MainCardComponentView: View {
    
    @ObservedObject var viewModel: MainCardComponentView.ViewModel
    
    var body: some View {
        Button {
            
        } label: {
            
            ZStack {
                if let backgtoundImage = viewModel.backgroundImage {
                   
                    backgtoundImage
                        .renderingMode(.original)
                        .scaledToFill()
                }
                
                VStack(alignment: .leading) {
                    
                    HStack(alignment: .center, spacing: 8) {
                        
                        viewModel.logo
                            .frame(width: 18.8, height: 18.8, alignment: .center)
                            .foregroundColor(viewModel.fontColor)
                        
                        Circle()
                            .frame(width: 2.27, height: 2.38, alignment: .center)
                            .foregroundColor(viewModel.fontColor)
                        
                        Text(viewModel.cardNumber)
                            .font(.system(size: 12))
                            .foregroundColor(viewModel.fontColor)
                    }
                    .padding(.leading, 5)
                    
                    
                        Spacer()
                    
                        Text(viewModel.name)
                            .font(.system(size: 14))
                            .foregroundColor(viewModel.fontColor)
                            .fixedSize(horizontal: false, vertical: true)
                            .opacity(0.5)
                            .multilineTextAlignment(.leading)

                        HStack(alignment: .center){
                            
                            Text(viewModel.balance)
                                .font(.system(size: 14))
                                .fontWeight(.semibold)
                                .foregroundColor(viewModel.fontColor)
                            
                            
                            Spacer()
                            
                            if let paymentSystem = viewModel.paymentSystem {
                                
                                paymentSystem
                                    .frame(width: 28, height: 28, alignment: .center)
                            }
                        }
                }
                .padding(.leading, 12)
                .padding(.trailing, 16)
                .padding(.top, 12)
                .padding(.bottom, 11)
                .frame(width: 164, height: 104)
                
                if let stutus = viewModel.status.image{
                    
                    ZStack{
                        
                        Rectangle()
                            .opacity(0.2)
                            
                        Button {
                            
                        } label: {
                            
                            stutus
                                .renderingMode(.original)
                                .foregroundColor(viewModel.backgroundColor)
                        }
                        .frame(width: 24, height: 24, alignment: .center)
                        .background(Color.white)
                        .cornerRadius(90)
                    }
                }
            }
            .frame(width: 164, height: 104)
            .background(viewModel.backgroundColor)
            .cornerRadius(12)
        }
        .foregroundColor(.black)
        .background(Color.white
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.2), radius: 12, x: 0, y: 15))
    }
    
}

struct MainCardView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group{
            MainCardComponentView(viewModel: .notActivate)
                .previewLayout(.fixed(width: 170, height: 120))
            
            MainCardComponentView(viewModel: .blocked)
                .previewLayout(.fixed(width: 170, height: 120))
            
            MainCardComponentView(viewModel: .classic)
                            .previewLayout(.fixed(width: 170, height: 120))
            
            MainCardComponentView(viewModel: .account)
                            .previewLayout(.fixed(width: 170, height: 120))
        }
    }
}

extension MainCardComponentView.ViewModel {

    static let notActivate = MainCardComponentView.ViewModel(logo: .ic24LogoForaColor, name: "Classic", balance: "170 897 ₽", fontColor: .white, cardNumber: "7854", backgroundColor: .cardClassic, paymentSystem:  Image(uiImage: UIImage(named: "card_visa_logo")!), status: .notActivated, backgroundImage: Image(""))
    
    static let blocked = MainCardComponentView.ViewModel(logo: .ic24LogoForaColor, name: "Infinity", balance: "170 897 ₽", fontColor: .white, cardNumber: "7854", backgroundColor: .cardInfinite, paymentSystem:  Image(uiImage: UIImage(named: "card_mastercard_logo")!), status: .blocked, backgroundImage: Image(""))
    
    static let classic = MainCardComponentView.ViewModel(logo: .ic24LogoForaColor, name: "Rio", balance: "170 897 ₽", fontColor: .white, cardNumber: "7854", backgroundColor: .cardRIO, paymentSystem: Image(uiImage: UIImage(named: "card_visa_logo")!), status: .active, backgroundImage: Image(""))
    
    static let account = MainCardComponentView.ViewModel(logo: .ic24LogoForaColor, name: "Текущий зарплатный счет", balance: "170 897 ₽", fontColor: .white, cardNumber: "7854", backgroundColor: .cardAccount, paymentSystem: .init(systemName: "card_mastercard_logo"), status: .active ,backgroundImage: Image(""))

}

