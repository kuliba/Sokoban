//
//  ProductViewComponent.swift
//  ForaBank
//
//  Created by Дмитрий on 21.02.2022.
//

import Foundation
import Combine
import SwiftUI

//MARK: - ViewModel

extension ProductView {
    
    class ViewModel: MainSectionProductsListItemViewModel, ObservableObject, Hashable {
        
        let productId: Int
        let header: HeaderViewModel
        @Published var name: String
        @Published var footer: FooterViewModel
        @Published var statusAction: StatusActionViewModel?
        let appearance: Appearance
        @Published var isUpdating: Bool
        let productType: ProductType
        let action: () -> Void
        let style: Style
        
        internal init(id: String = UUID().uuidString, productId: Int = 0, header: HeaderViewModel, name: String, footer: FooterViewModel, statusAction: StatusActionViewModel?, appearance: Appearance, isUpdating: Bool, productType: ProductType, action: @escaping () -> Void) {
            
            self.productId = productId
            self.header = header
            self.name = name
            self.footer = footer
            self.statusAction = statusAction
            self.appearance = appearance
            self.isUpdating = isUpdating
            self.productType = productType
            self.action = action
            self.style = .main
            super.init(id: id)
        }
        
        convenience init(with productData: ProductData, statusAction: @escaping () -> Void, action: @escaping () -> Void) {
            
            let number = productData.viewNumber
            
            let name = productData.viewName
            let textColor = productData.fontDesignColor.color
            let productType = productData.productType
            
            self.init(header: .init(logo: nil, number: number, period: nil), name: name, footer: .init(balance: "nil", paymentSystem: nil), statusAction: nil, appearance: .init(textColor: textColor, background: .init(color: .bGIconBlack, image: nil), size: .normal), isUpdating: false, productType: productType, action: {})
            
            guard let balance = productData.balance?.currencyFormatter(symbol: productData.currency),
                  let backgroundImage = productData.extraLargeDesign.image,
                  let backgroundColor = productData.background.first?.color  else { return }
            
            self.init(header: .init(logo: nil, number: number, period: nil), name: name, footer: .init(balance: balance, paymentSystem: nil), statusAction: nil, appearance: .init(textColor: textColor, background: .init(color: backgroundColor, image: backgroundImage), size: .normal), isUpdating: false, productType: productType, action: {})
        }
        
        //        convenience init(with productData: ProductData) {
        //
        //            //TODO: make switch with productData subclass
        //        }
        
        func update(with productData: ProductData) {
            
            if let customName = productData.customName {
                
                name = customName
            }
            
            if let balance = productData.balance {
                
                footer.balance = balance.currencyFormatter(symbol: productData.currency)
            }
        }
        
        struct HeaderViewModel {
            
            let logo: Image?
            let number: String?
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
        }
        
        enum Style {
            
            case main
            case profile
        }
        
        struct Appearance {
            
            let textColor: Color
            let background: Background
            var size: Size = .normal
            
            struct Background {
                
                let color: Color
                let image: Image?
            }
            
            enum Size {
                
                case normal
                case small
            }
        }
    }
}

extension ProductView.ViewModel {
    
    func hash(into hasher: inout Hasher) {
        
        hasher.combine(id)
    }
    
    static func == (lhs: ProductView.ViewModel, rhs: ProductView.ViewModel) -> Bool {
        
        return lhs.id == rhs.id
    }
}

//MARK: - View

struct ProductView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        if viewModel.isUpdating == true {
            
            ZStack {
                
                ContentView(viewModel: viewModel)
                AnimatedGradientView(duration: 3.0)
                    .blendMode(.colorDodge)
            }
            .clipped()
            
        } else {
            
            ContentView(viewModel: viewModel)
        }
    }
}

//MARK: - Internal Views

extension ProductView {
    
    struct ContentView: View {
        
        @ObservedObject var viewModel: ViewModel
        
        var headerPaddingLeading: CGFloat {
            
            switch viewModel.appearance.size {
            case .normal: return 43
            case .small: return 29
            }
        }
        
        var cardPadding: CGFloat {
            
            switch viewModel.appearance.size {
            case .normal: return 12
            case .small: return 8
            }
        }
        
        var nameFont: Font {
            
            switch viewModel.appearance.size {
            case .normal: return .textBodyMR14200()
            case .small: return .textBodyXSR11140()
            }
        }
        
        var nameSpacing: CGFloat {
            
            switch viewModel.appearance.size {
            case .normal: return 6
            case .small: return 4
            }
        }
        
        var cornerRadius: CGFloat {
            
            switch viewModel.appearance.size {
            case .normal: return 12
            case .small: return 8
            }
        }
        
        var body: some View {
            
            ZStack {
                
                if let backgroundImage = viewModel.appearance.background.image {
                    
                    backgroundImage
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .foregroundColor(viewModel.appearance.background.color)
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    
                    ProductView.HeaderView(viewModel: viewModel.header, appearance: viewModel.appearance)
                        .padding(.leading, headerPaddingLeading)
                        .padding(.top, 4)
                    
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: nameSpacing) {
                        
                        Text(viewModel.name)
                            .font(nameFont)
                            .foregroundColor(viewModel.appearance.textColor)
                            .opacity(0.5)
                        
                        ProductView.FooterView(viewModel: viewModel.footer, appearance: viewModel.appearance)
                    }
                }
                .padding(cardPadding)
                
                if viewModel.isUpdating == true {
                    
                    HStack(spacing: 3) {
                        
                        ProductView.AnimatedDotView(duration: 0.6, delay: 0)
                        ProductView.AnimatedDotView(duration: 0.6, delay: 0.2)
                        ProductView.AnimatedDotView(duration: 0.6, delay: 0.4)
                    }
                }
                
                if let statusActionViewModel = viewModel.statusAction {
                    
                    ProductView.StatusActionView(viewModel: statusActionViewModel, color: viewModel.appearance.background.color)
                }
            }
            .onTapGesture {
                viewModel.action()
            }
        }
    }
    
    struct HeaderView: View {
        
        let viewModel: ViewModel.HeaderViewModel
        let appearance: ViewModel.Appearance
        
        var textFont: Font {
            
            switch appearance.size {
            case .normal: return .textBodySR12160()
            case .small: return .textBodyXSR11140()
            }
        }
        
        var body: some View {
            
            HStack(alignment: .center, spacing: 8) {
                
                if let number = viewModel.number {
                    Text(number)
                        .font(textFont)
                        .foregroundColor(appearance.textColor)
                }
                
                if let period = viewModel.period {
                    
                    Rectangle()
                        .frame(width: 1, height: 16)
                        .foregroundColor(appearance.textColor)
                    
                    Text(period)
                        .font(textFont)
                        .foregroundColor(appearance.textColor)
                }
            }
        }
    }
    
    struct FooterView: View {
        
        @ObservedObject var viewModel: ViewModel.FooterViewModel
        let appearance: ViewModel.Appearance
        
        var textFont: Font {
            
            switch appearance.size {
            case .normal: return .textBodyMSB14200()
            case .small: return .textBodyXSR11140()
            }
        }
        
        var paymentSystemIconSize: CGSize {
            
            switch appearance.size {
            case .normal: return .init(width: 28, height: 28)
            case .small: return .init(width: 20, height: 20)
            }
        }
        
        var body: some View {
            
            if let paymentSystem = viewModel.paymentSystem {
                
                HStack {
                    
                    Text(viewModel.balance)
                        .font(textFont)
                        .fontWeight(.semibold)
                        .foregroundColor(appearance.textColor)
                    
                    Spacer()
                    
                }.overlay(
                    
                    HStack {
                        Spacer()
                        paymentSystem
                            .renderingMode(.template)
                            .resizable()
                            .frame(width: paymentSystemIconSize.width, height: paymentSystemIconSize.height)
                            .foregroundColor(appearance.textColor)
                    }
                )
                
            } else {
                
                HStack {
                    
                    Text(viewModel.balance)
                        .font(textFont)
                        .fontWeight(.semibold)
                        .foregroundColor(appearance.textColor)
                    
                    Spacer()
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

//MARK: - Animated Views

extension ProductView {
    
    struct AnimatedGradientView: View {
        
        var duration: TimeInterval = 1.0
        @State private var isAnimated: Bool = false
        
        var body: some View {
            
            GeometryReader { proxy in
                
                LinearGradient(colors: [.white.opacity(0), .white.opacity(0.5)], startPoint: .leading, endPoint: .trailing)
                    .offset(.init(width: isAnimated ? proxy.frame(in: .local).width * 2 : -proxy.frame(in: .local).width, height: 0))
                    .animation(.easeInOut(duration: duration).repeatForever(autoreverses: false))
                    .onAppear {
                        withAnimation {
                            isAnimated = true
                        }
                    }
            }
        }
    }
    
    struct AnimatedDotsView: View {
        
        var body: some View {
            
            HStack(spacing: 3) {
                
                ProductView.AnimatedDotView(duration: 0.6, delay: 0)
                ProductView.AnimatedDotView(duration: 0.6, delay: 0.2)
                ProductView.AnimatedDotView(duration: 0.6, delay: 0.4)
            }
        }
    }
    
    struct AnimatedDotView: View {
        
        var color: Color = .white
        var size: CGFloat = 3.0
        var duration: TimeInterval = 1.0
        var delay: TimeInterval = 0
        @State private var isAnimated: Bool = false
        
        var body: some View {
            
            Circle()
                .frame(width: size, height: size)
                .foregroundColor(color)
                .opacity(isAnimated ? 1 : 0)
                .animation(.easeInOut(duration: duration).repeatForever(autoreverses: true).delay(delay))
                .onAppear {
                    withAnimation {
                        isAnimated = true
                    }
                }
        }
    }
}

//MARK: - Preview

struct ProductView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            ProductView(viewModel: .updating)
                .previewLayout(.fixed(width: 164, height: 104))
            
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
            Group {

            ProductView(viewModel: .accountProfile)
                .previewLayout(.fixed(width: 268, height: 160))
            
            ProductView(viewModel: .depositProfile)
                .previewLayout(.fixed(width: 228, height: 160))
            
            ProductView(viewModel: .classicSmall)
                .previewLayout(.fixed(width: 112, height: 72))
            
            ProductView(viewModel: .accountSmall)
                .previewLayout(.fixed(width: 112, height: 72))
            }
        }
    }
}

//MARK: - Preview Content

extension ProductView.ViewModel {
    
    static let notActivate = ProductView.ViewModel(header: .init(logo: .ic24LogoForaColor, number: "7854", period: nil), name: "Classic", footer: .init(balance: "170 897 ₽", paymentSystem: Image("Payment System Visa")), statusAction: .init(status: .activation, style: .main, action: {}), appearance: .init(textColor: .white, background: .init(color: .cardInfinite, image: Image("Product Background Sample"))), isUpdating: false, productType: .card, action: {})
    
    static let blocked = ProductView.ViewModel(id: "1", header: .init(logo: .ic24LogoForaColor, number: "7854", period: nil), name: "Classic", footer: .init(balance: "170 897 ₽", paymentSystem: Image("Payment System Mastercard")), statusAction: .init(status: .unblock, style: .main, action: {}), appearance: .init(textColor: .white, background: .init(color: .cardInfinite, image: nil)), isUpdating: true, productType: .card, action: {})
    
    static let classic = ProductView.ViewModel(id: "2", header: .init(logo: .ic24LogoForaColor, number: "7854", period: nil), name: "Classic", footer: .init(balance: "170 897 ₽", paymentSystem: Image("Payment System Mastercard")), statusAction: nil, appearance: .init(textColor: .white, background: .init(color: .mainColorsRed, image: nil)), isUpdating: false,  productType: .card, action: {})
    
    static let account = ProductView.ViewModel(header: .init(logo: .ic24LogoForaColor, number: "7854", period: nil), name: "Текущий зарплатный счет", footer: .init(balance: "170 897 ₽", paymentSystem: Image("Payment System Mastercard")), statusAction: nil, appearance: .init(textColor: .white, background: .init(color: .cardRIO, image: nil)), isUpdating: false, productType: .card, action: {})
    
    static let notActivateProfile = ProductView.ViewModel(header: .init(logo: .ic24LogoForaColor, number: "7854", period: "12/24"), name: "Classic", footer: .init(balance: "170 897 ₽", paymentSystem: Image("Payment System Visa")), statusAction: .init(status: .activation, style: .profile, action: {}), appearance: .init(textColor: .white, background: .init(color: .cardInfinite, image: Image("Product Background Large Sample"))), isUpdating: false, productType: .deposit, action: {})
    
    static let blockedProfile = ProductView.ViewModel(header: .init(logo: .ic24LogoForaColor, number: "7854", period: "12/24"), name: "Classic", footer: .init(balance: "170 897 ₽", paymentSystem: Image("Payment System Mastercard")), statusAction: .init(status: .unblock, style: .profile, action: {}), appearance: .init(textColor: .white, background: .init(color: .cardInfinite, image: nil)), isUpdating: false, productType: .card, action: {})
    
    static let classicProfile = ProductView.ViewModel(header: .init(logo: .ic24LogoForaColor, number: "7854", period: "12/24"), name: "Classic", footer: .init(balance: "170 897 ₽", paymentSystem: Image("Payment System Mastercard")), statusAction: nil, appearance: .init(textColor: .white, background: .init(color: .cardRIO, image: nil)), isUpdating: false, productType: .card, action: {})
    
    static let accountProfile = ProductView.ViewModel(header: .init(logo: .ic24LogoForaColor, number: "7854", period: "12/24"), name: "Текущий зарплатный счет", footer: .init(balance: "170 897 ₽", paymentSystem: Image("Payment System Mastercard")), statusAction: nil, appearance: .init(textColor: .white, background: .init(color: .cardRIO, image: nil)), isUpdating: false, productType: .account, action: {})
    
    static let depositProfile = ProductView.ViewModel(header: .init(logo: .ic24LogoForaColor, number: "7854", period: "12/24"), name: "Стандарный вклад", footer: .init(balance: "170 897 ₽", paymentSystem: Image("Payment System Mastercard")), statusAction: nil, appearance: .init(textColor: .mainColorsBlackMedium, background: .init(color: .cardRIO, image: Image( "Cover Deposit"))), isUpdating: false, productType: .deposit, action: {})
    
    static let updating = ProductView.ViewModel(id: "0", header: .init(logo: .ic24LogoForaColor, number: "7854", period: nil), name: "Classic", footer: .init(balance: "170 897 ₽", paymentSystem: Image("Payment System Visa")), statusAction: nil, appearance: .init(textColor: .white, background: .init(color: .cardInfinite, image: Image("Product Background Sample"))), isUpdating: true, productType: .card, action: {})
    
    static let classicSmall = ProductView.ViewModel(id: "2", header: .init(logo: .ic24LogoForaColor, number: "7854", period: nil), name: "Classic", footer: .init(balance: "170 897 ₽", paymentSystem: Image("Payment System Mastercard")), statusAction: nil, appearance: .init(textColor: .white, background: .init(color: .mainColorsRed, image: nil), size: .small), isUpdating: false,  productType: .card, action: {})
    
    static let accountSmall = ProductView.ViewModel(id: "3", header: .init(logo: .ic24LogoForaColor, number: "7854", period: nil), name: "Текущий зарплатный счет", footer: .init(balance: "170 897 ₽", paymentSystem: Image("Payment System Mastercard")), statusAction: nil, appearance: .init(textColor: .white, background: .init(color: .cardRIO, image: nil), size: .small), isUpdating: false, productType: .account, action: {})
}
