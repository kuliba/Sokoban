//
//  ProductViewComponent.swift
//  ForaBank
//
//  Created by Дмитрий on 21.02.2022.
//

import Foundation
import SwiftUI

//MARK: - ViewModel

extension ProductView {
    
    class ViewModel: MainSectionProductsListItemViewModel, ObservableObject {

        let style: Style
        let logo: Image
        @Published var name: String
        @Published var balance: String
        @Published var status: Status
        let cardNumber: String
        let paymentSystem: Image?
        let appearance: Appearance
        let action: () -> Void
        
        internal init(style: Style, logo: Image, name: String, balance: String, status: Status, cardNumber: String, paymentSystem: Image?, appearance: Appearance, action: @escaping () -> Void) {
            
            self.style = style
            self.logo = logo
            self.name = name
            self.balance = balance
            self.status = status
            self.cardNumber = cardNumber
            self.paymentSystem = paymentSystem
            self.appearance = appearance
            self.action = action
        }

        enum Style {
            
            case main
            case profile
        }
        
        enum Status {
            
            case active
            case notActivated
            case blocked
            
            var image: Image? {
                
                switch self {
                    case .active: return nil
                    case .notActivated: return Image.ic24ArrowRight
                    case .blocked: return Image.ic24Lock
                }
            }
        }
        
        struct Appearance {
            
            let textColor: Color
            let background: Background
            
            struct Background {
                
                let color: Color
                let image: Image?
            }
        }
    }
}

//MARK: - View

struct ProductView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var size: CGSize {
        switch viewModel.style {
        case .main: return .init(width: 164, height: 104)
        case .profile: return .init(width: 268, height: 160)
        }
    }
    
    var body: some View {
            
        Button(action: viewModel.action) {
            
            ZStack {
                
                // background
                if let backgroundImage = viewModel.appearance.background.image {
                    
                    backgroundImage
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundColor(viewModel.appearance.background.color)
                }
 
                VStack(alignment: .leading) {
                    
                    HStack(alignment: .center, spacing: 8) {
                        
                        viewModel.logo
                            .frame(width: 18.8, height: 18.8, alignment: .center)
                            .foregroundColor(viewModel.appearance.textColor)
                        
                        Circle()
                            .frame(width: 2.27, height: 2.38, alignment: .center)
                            .foregroundColor(viewModel.appearance.textColor)
                        
                        Text(viewModel.cardNumber)
                            .font(.system(size: 12))
                            .foregroundColor(viewModel.appearance.textColor)
                    }
                    .padding(.leading, 5)

                    Spacer()
                    
                    HStack(alignment: .bottom){
                        
                        VStack(alignment: .leading, spacing: 0) {
                            
                            Spacer()
                            
                            Text(viewModel.name)
                                .font(.system(size: 14))
                                .foregroundColor(viewModel.appearance.textColor)
                                .fixedSize(horizontal: false, vertical: true)
                                .opacity(0.5)
                                .multilineTextAlignment(.leading)

                            HStack(alignment: .bottom) {
                                
                                Text(viewModel.balance)
                                    .font(.system(size: 14))
                                    .fontWeight(.semibold)
                                    .foregroundColor(viewModel.appearance.textColor)
                                
                                Spacer()
                                
                                if let paymentSystem = viewModel.paymentSystem {
                                    
                                    paymentSystem
                                        .frame(width: 28, height: 20, alignment: .bottom)
                                    
                                }
                            }
                        }
                    }
                }
                .padding(.leading, 12)
                .padding(.trailing, 16)
                .padding(.top, 12)
                .padding(.bottom, 11)

                switch viewModel.status {
                case .active:
                    EmptyView()
                    
                case .notActivated:
                    switch viewModel.style {
                    case .main:
                        Button {
                            
                        } label: {
                            
                            ZStack {
                                
                                Circle()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(.iconWhite)
                                
                                Image.ic16ArrowRight
                                    .renderingMode(.template)
                                    .foregroundColor(viewModel.appearance.background.color)
                            }
                        }
                        
                    case .profile:
                        SliderButtonComponent(viewModel: SliderButtonComponent.ViewModel(alertPresented: false, sliderState: .normal, foregroundColor: viewModel.appearance.background.color))
                    }
                    
                case .blocked:
                    switch viewModel.style {
                    case .main:
                        Button {
                            
                        } label: {
                            
                            ZStack {
                                
                                Circle()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(.iconWhite)
                                
                                Image.ic16Lock
                                    .renderingMode(.template)
                                    .foregroundColor(viewModel.appearance.background.color)
                            }
                        }
                        
                    case .profile:
                        Button {
                            
                        } label: {
                            
                            ZStack {
                                
                                Circle()
                                    .frame(width: 64, height: 64)
                                    .foregroundColor(.iconWhite)
                                
                                Image.ic24Lock
                                    .renderingMode(.template)
                                    .foregroundColor(viewModel.appearance.background.color)
                            }
                        }
                    }
                }
            }
        }
    }
}

//MARK: - Preview

extension ProductView {
    
    class CollapsedButtonViewModel: MainSectionProductsListItemViewModel, ObservableObject {
    
        var title: String
        
        internal init(id: UUID = UUID(), title: String) {
            
            self.title = title
            super.init(id: id)
        }
    }
    
    struct CollapsedButtonView: View {
        
        @ObservedObject var viewModel: CollapsedButtonViewModel
        
        var body: some View {
            
            Button {
                
            } label: {
                
                VStack(alignment: .center) {
                    
                    Spacer()
                    
                    Text(viewModel.title)
                        .font(.system(size: 14))
                    
                    Spacer()
                }
                .padding(12)
                .foregroundColor(.black)
                .background(Color.mainColorsGrayLightest
                                .cornerRadius(12))
                .frame(width: 48, height: 104)
            }
        }
    }
}

//MARK: - Preview Content

struct MainCardView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group{
            ProductView(viewModel: .notActivate)
                .previewLayout(.fixed(width: 164, height: 104))
            
            ProductView(viewModel: .blocked)
                .previewLayout(.fixed(width: 164, height: 104))

            ProductView(viewModel: .classic)
                .previewLayout(.fixed(width: 164, height: 104))

            ProductView(viewModel: .account)
                .previewLayout(.fixed(width: 164, height: 104))
            
            ProductView(viewModel: .notActivateProfile)
                .previewLayout(.fixed(width: 268, height: 160))
            
            ProductView(viewModel: .blockedProfile)
                .previewLayout(.fixed(width: 268, height: 160))

            ProductView(viewModel: .classicProfile)
                .previewLayout(.fixed(width: 268, height: 160))

            ProductView(viewModel: .accountProfile)
                .previewLayout(.fixed(width: 268, height: 160))
        }
    }
}

extension ProductView.ViewModel {
    
    static let notActivate = ProductView.ViewModel(style: .main, logo: .ic24LogoForaColor, name: "Classic", balance: "170 897 ₽", status: .notActivated, cardNumber: "7854", paymentSystem: Image("card_visa_logo"), appearance: .init(textColor: .white, background: .init(color: .cardInfinite, image: Image("Product Background Sample"))), action: {})

    static let blocked = ProductView.ViewModel(style: .main, logo: .ic24LogoForaColor, name: "Classic", balance: "170 897 ₽", status: .blocked, cardNumber: "7854", paymentSystem: Image("card_mastercard_logo"), appearance: .init(textColor: .white, background: .init(color: .cardInfinite, image: nil)), action: {})

    static let classic = ProductView.ViewModel(style: .main, logo: .ic24LogoForaColor, name: "Classic", balance: "170 897 ₽", status: .active, cardNumber: "7854", paymentSystem: Image("card_visa_logo"), appearance: .init(textColor: .white, background: .init(color: .cardRIO, image: nil)), action: {})
    
    static let account = ProductView.ViewModel(style: .main, logo: .ic24LogoForaColor, name: "Текущий зарплатный счет", balance: "170 897 ₽", status: .active, cardNumber: "7854", paymentSystem: Image("card_mastercard_logo"), appearance: .init(textColor: .white, background: .init(color: .cardRIO, image: nil)), action: {})
    
    static let notActivateProfile = ProductView.ViewModel(style: .profile, logo: .ic24LogoForaColor, name: "Classic", balance: "170 897 ₽", status: .notActivated, cardNumber: "7854", paymentSystem: Image("card_visa_logo"), appearance: .init(textColor: .white, background: .init(color: .cardRIO, image: Image("Product Background Large Sample"))), action: {})
    
    static let blockedProfile = ProductView.ViewModel(style: .profile, logo: .ic24LogoForaColor, name: "Classic", balance: "170 897 ₽", status: .blocked, cardNumber: "7854", paymentSystem: Image("card_mastercard_logo"), appearance: .init(textColor: .white, background: .init(color: .cardInfinite, image: nil)), action: {})
    
    static let classicProfile = ProductView.ViewModel(style: .profile, logo: .ic24LogoForaColor, name: "Classic", balance: "170 897 ₽", status: .active, cardNumber: "7854", paymentSystem: Image("card_visa_logo"), appearance: .init(textColor: .white, background: .init(color: .cardRIO, image: nil)), action: {})
    
    static let accountProfile = ProductView.ViewModel(style: .main, logo: .ic24LogoForaColor, name: "Текущий зарплатный счет", balance: "170 897 ₽", status: .active, cardNumber: "7854", paymentSystem: Image("card_mastercard_logo"), appearance: .init(textColor: .white, background: .init(color: .cardRIO, image: nil)), action: {})
}

extension ProductView.CollapsedButtonViewModel {
    
    static let moreCards = ProductView.CollapsedButtonViewModel(id: UUID(), title: "+ 5")
}

