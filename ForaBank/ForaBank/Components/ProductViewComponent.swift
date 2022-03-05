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

        let header: HeaderViewModel
        @Published var name: String
        var footer: FooterViewModel
        @Published var statusAction: StatusActionViewModel?
        let appearance: Appearance
        let action: () -> Void
        
        internal init(header: HeaderViewModel, name: String, footer: FooterViewModel, statusAction: StatusActionViewModel?, appearance: Appearance, action: @escaping () -> Void) {
            
            self.header = header
            self.name = name
            self.footer = footer
            self.statusAction = statusAction
            self.appearance = appearance
            self.action = action
        }
        
        struct HeaderViewModel {
            
            let logo: Image
            let number: String
            let period: String?
        }
        
        class FooterViewModel: ObservableObject {
            
            @Published var balance: String
            let paymentSystem: Image?
            
            init(balance: String, paymentSystem: Image?) {
                
                self.balance = balance
                self.paymentSystem = paymentSystem
            }
        }

        struct StatusActionViewModel {
            
            let status: Status
            let style: Style
            let action: () -> Void
            
            var icon: Image {
                
                switch status {
                case .activation:
                    switch style {
                    case .main: return .ic16ArrowRight
                    case .profile: return .ic24ArrowRight
                    }
                    
                case .unblock:
                    switch style {
                    case .main: return .ic16Lock
                    case .profile: return .ic24Lock
                    }
                }
            }
            
            var iconSize: CGSize {
                
                switch style {
                case .main: return .init(width: 24, height: 24)
                case .profile: return .init(width: 64, height: 64)
                }
            }
    
            enum Status {
                
                case activation
                case unblock
            }
            
            enum Style {
                
                case main
                case profile
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
    
    var body: some View {
            
        Button(action: viewModel.action) {
            
            ZStack {
                
                if let backgroundImage = viewModel.appearance.background.image {
                    
                    backgroundImage
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundColor(viewModel.appearance.background.color)
                }
 
                VStack(alignment: .leading) {
                    
                    HeaderView(viewModel: viewModel.header, textColor: viewModel.appearance.textColor)

                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 0) {
                        
                        Text(viewModel.name)
                            .font(.textBodyMR14200())
                            .foregroundColor(viewModel.appearance.textColor)
                            .fixedSize(horizontal: false, vertical: true)
                            .opacity(0.5)
                            .multilineTextAlignment(.leading)
                        
                        FooterView(viewModel: viewModel.footer, textColor: viewModel.appearance.textColor)
                    }
                }
                .padding(.leading, 12)
                .padding(.trailing, 16)
                .padding(.vertical, 12)

                if let statusActionViewModel = viewModel.statusAction {
                    
                    ProductView.StatusActionView(viewModel: statusActionViewModel, color: viewModel.appearance.background.color)
                }
            }
        }
    }
}

//MARK: - Internal Views

extension ProductView {
    
    struct HeaderView: View {
        
        let viewModel: ViewModel.HeaderViewModel
        let textColor: Color
        
        var body: some View {
            
            HStack(alignment: .center, spacing: 8) {
                
                viewModel.logo
                    .frame(width: 18.8, height: 18.8)
                    .foregroundColor(textColor)
                
                Circle()
                    .frame(width: 2.38, height: 2.38)
                    .foregroundColor(textColor)
                
                Text(viewModel.number)
                    .font(.textBodySR12160())
                    .foregroundColor(textColor)
                
                if let period = viewModel.period {
                    
                    Rectangle()
                        .frame(width: 1, height: 16)
                        .foregroundColor(textColor)
                    
                    Text(period)
                        .font(.textBodySR12160())
                        .foregroundColor(textColor)
                }
            }
        }
    }
    
    struct FooterView: View {
        
        @ObservedObject var viewModel: ViewModel.FooterViewModel
        let textColor: Color
        
        var body: some View {
            
            HStack(alignment: .bottom) {
                
                Text(viewModel.balance)
                    .font(.textBodyMSB14200())
                    .fontWeight(.semibold)
                    .foregroundColor(textColor)
                
                Spacer()
                
                if let paymentSystem = viewModel.paymentSystem {
                    
                    paymentSystem
                        .renderingMode(.template)
                        .frame(width: 28, height: 20)
                        .foregroundColor(textColor)
                }
            }
        }
    }
    
    struct StatusActionView: View {
        
        let viewModel: ViewModel.StatusActionViewModel
        let color: Color
        
        var body: some View {
            
            switch viewModel.status {
            case .activation:
                switch viewModel.style {
                case .main:
                    ProductView.StatusButtonView(icon: viewModel.icon, color: color, size: viewModel.iconSize, action: viewModel.action)
                    
                case .profile:
                    SliderButtonComponent(viewModel: .init(alertPresented: false, sliderState: .normal, foregroundColor: color))
                }
                
            case .unblock:
                ProductView.StatusButtonView(icon: viewModel.icon, color: color, size: viewModel.iconSize, action: viewModel.action)
            }
        }
    }
    
    struct StatusButtonView: View {
        
        let icon: Image
        let color: Color
        let size: CGSize
        let action: () -> Void
    
        var body: some View {
            
            Button(action: action){
                
                ZStack {
                    
                    Circle()
                        .frame(width: size.width, height: size.height)
                        .foregroundColor(.iconWhite)
                    
                    icon
                        .renderingMode(.template)
                        .foregroundColor(color)
                }
            }
        }
    }
}

//MARK: - Preview

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

//MARK: - Preview Content

extension ProductView.ViewModel {
    
    static let notActivate = ProductView.ViewModel(header: .init(logo: .ic24LogoForaColor, number: "7854", period: nil), name: "Classic", footer: .init(balance: "170 897 ₽", paymentSystem: Image("Payment System Visa")), statusAction: .init(status: .activation, style: .main, action: {}), appearance: .init(textColor: .white, background: .init(color: .cardInfinite, image: Image("Product Background Sample"))), action: {})

    static let blocked = ProductView.ViewModel(header: .init(logo: .ic24LogoForaColor, number: "7854", period: nil), name: "Classic", footer: .init(balance: "170 897 ₽", paymentSystem: Image("Payment System Mastercard")), statusAction: .init(status: .unblock, style: .main, action: {}), appearance: .init(textColor: .white, background: .init(color: .cardInfinite, image: nil)), action: {})
    
    static let classic = ProductView.ViewModel(header: .init(logo: .ic24LogoForaColor, number: "7854", period: nil), name: "Classic", footer: .init(balance: "170 897 ₽", paymentSystem: Image("Payment System Mastercard")), statusAction: nil, appearance: .init(textColor: .white, background: .init(color: .cardRIO, image: nil)), action: {})
    
    static let account = ProductView.ViewModel(header: .init(logo: .ic24LogoForaColor, number: "7854", period: nil), name: "Текущий зарплатный счет", footer: .init(balance: "170 897 ₽", paymentSystem: Image("Payment System Mastercard")), statusAction: nil, appearance: .init(textColor: .white, background: .init(color: .cardRIO, image: nil)), action: {})
    
    static let notActivateProfile = ProductView.ViewModel(header: .init(logo: .ic24LogoForaColor, number: "7854", period: "12/24"), name: "Classic", footer: .init(balance: "170 897 ₽", paymentSystem: Image("Payment System Visa")), statusAction: .init(status: .activation, style: .profile, action: {}), appearance: .init(textColor: .white, background: .init(color: .cardInfinite, image: Image("Product Background Large Sample"))), action: {})
    
    static let blockedProfile = ProductView.ViewModel(header: .init(logo: .ic24LogoForaColor, number: "7854", period: "12/24"), name: "Classic", footer: .init(balance: "170 897 ₽", paymentSystem: Image("Payment System Mastercard")), statusAction: .init(status: .unblock, style: .profile, action: {}), appearance: .init(textColor: .white, background: .init(color: .cardInfinite, image: nil)), action: {})
    
    static let classicProfile = ProductView.ViewModel(header: .init(logo: .ic24LogoForaColor, number: "7854", period: "12/24"), name: "Classic", footer: .init(balance: "170 897 ₽", paymentSystem: Image("Payment System Mastercard")), statusAction: nil, appearance: .init(textColor: .white, background: .init(color: .cardRIO, image: nil)), action: {})
    
    static let accountProfile = ProductView.ViewModel(header: .init(logo: .ic24LogoForaColor, number: "7854", period: "12/24"), name: "Текущий зарплатный счет", footer: .init(balance: "170 897 ₽", paymentSystem: Image("Payment System Mastercard")), statusAction: nil, appearance: .init(textColor: .white, background: .init(color: .cardRIO, image: nil)), action: {})
}

