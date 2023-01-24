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
    
    class ViewModel: Identifiable, ObservableObject, Hashable {
        
        let action: PassthroughSubject<Action, Never> = .init()

        let id: ProductData.ID
        let header: HeaderViewModel
        @Published var name: String
        @Published var footer: FooterViewModel
        @Published var statusAction: StatusActionViewModel?
        @Published var isChecked: Bool
        @Published var isUpdating: Bool
        var appearance: Appearance
        let productType: ProductType
        
        private var bindings = Set<AnyCancellable>()
        
        internal init(id: ProductData.ID, header: HeaderViewModel, name: String, footer: FooterViewModel, statusAction: StatusActionViewModel?, isChecked: Bool = false, appearance: Appearance, isUpdating: Bool, productType: ProductType) {
            
            self.id = id
            self.header = header
            self.name = name
            self.footer = footer
            self.statusAction = statusAction
            self.isChecked = isChecked
            self.appearance = appearance
            self.isUpdating = isUpdating
            self.productType = productType
        }
       
        convenience init(with productData: ProductData, isChecked: Bool = false, size: Appearance.Size, style: Appearance.Style, model: Model) {
            
            let balance = Self.balanceFormatted(product: productData, style: style, model: model)
            let number = productData.displayNumber
            let period = Self.period(product: productData, style: style)
            let name = Self.name(product: productData, style: style)
            let textColor = productData.fontDesignColor.color
            let productType = productData.productType
            let backgroundColor = productData.backgroundColor
            let backgroundImage = Self.backgroundImage(with: productData, size: size)
            let statusAction = Self.statusAction(product: productData)
            
            self.init(id: productData.id, header: .init(number: number, period: period), name: name, footer: .init(balance: balance), statusAction: statusAction, isChecked: isChecked, appearance: .init(textColor: textColor, background: .init(color: backgroundColor, image: backgroundImage), size: size, style: style), isUpdating: false, productType: productType)
            
            bind()
            bind(statusAction)
        }
        
        private func bind() {
            
            action
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] action in
                    
                    switch action {
                    case _ as ProductViewModelAction.CardActivation.Complete:
                        statusAction?.action.send(ProductView.ViewModel.StatusActionViewModelAction.CardActivation.Complete())
                        
                    case _ as ProductViewModelAction.CardActivation.Failed:
                        statusAction?.action.send(ProductView.ViewModel.StatusActionViewModelAction.CardActivation.Failed())
                        
                    default:
                        return
                    }
                    
                }.store(in: &bindings)
            
            $statusAction
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] statusAction in
                    
                    if statusAction != nil {
                        self.appearance.opacity = 0.5
                        
                    } else {
                        self.appearance.opacity = 1
                    }
                    
                }.store(in: &bindings)
            
        }
        
        private func bind(_ statusAction: StatusActionViewModel?) {
            
            statusAction?.action
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { [unowned self] action in
                    
                    switch action {
                    case _ as ProductView.ViewModel.StatusActionViewModelAction.CardActivation.Started:
                        self.action.send(ProductViewModelAction.CardActivation.Started())
                        
                    default:
                        break
                    }
                    
                }).store(in: &bindings)
        }

        func update(with productData: ProductData, model: Model) {
            
            name = Self.name(product: productData, style: appearance.style)
            statusAction = Self.statusAction(product: productData)
            footer.balance = Self.balanceFormatted(product: productData, style: appearance.style, model: model)
            
            bind(statusAction)
        }

        static func balanceFormatted(product: ProductData, style: Appearance.Style, model: Model) -> String {
            
            switch product {
            case let loanProduct as ProductLoanData:
                return Self.balanceFormatted(amount: loanProduct.amount,
                                             debt: loanProduct.totalAmountDebtValue,
                                             currency: loanProduct.currency,
                                             style: style, model: model)
            default:
                return Self.balanceFormatted(balance: product.balanceValue,
                                             currency: product.currency,
                                             style: style, model: model)
            }
        }
        
        static func balanceFormatted(balance: Double, currency: String, style: Appearance.Style, model: Model) -> String {
            
            switch style {
            case .main:
                return model.amountFormatted(amount: balance, currencyCode: currency, style: .clipped) ?? String(balance)
                
            case .profile:
                return model.amountFormatted(amount: balance, currencyCode: currency, style: .normal) ?? String(balance)
            }
        }
        
        static func balanceFormatted(amount: Double, debt: Double, currency: String, style: Appearance.Style, model: Model) -> String {
            
            switch style {
            case .main:
                return model.amountFormatted(amount: debt, currencyCode: currency, style: .clipped) ?? String(amount)
                
            case .profile:
                let debtFormatted = model.amountFormatted(amount: debt, currencyCode: currency, style: .normal) ?? String(debt)
                let amountFormatted = model.amountFormatted(amount: amount, currencyCode: currency, style: .normal) ?? String(amount)
                
                return debtFormatted + " / " + amountFormatted
            }
        }
        
        static func createSubtitle(from data: ProductData) -> String? {
            
            switch data {
                
            case let cardProduct as ProductCardData:
                guard let subtitle = cardProduct.additionalField else { return nil }
                return subtitle
                
            case let depositProduct as ProductDepositData:
                let subtitle = depositProduct.interestRate
                return "Ставка \(subtitle)%"
                
            case let loanProduct as ProductLoanData:
                let subtitle = loanProduct.currentInterestRate
                return "Ставка \(subtitle)%"
                
            default: return nil
            }
        }
        
        
        static func name(product: ProductData, style: Appearance.Style) -> String {
            
            switch product {
            case let cardProduct as ProductCardData:
                switch style {
                case .main:
                    return cardProduct.isCreditCard ? "Кредитная карта" : cardProduct.displayName
                    
                case .profile:
                    return cardProduct.isCreditCard ? "Кредитная\n\(cardProduct.displayName)" : cardProduct.displayName
                }
                
            case let loanProduct as ProductLoanData:
                switch style {
                case .main:
                    switch loanProduct.loanType {
                    case .consumer:
                        return loanProduct.displayName
                        
                    case .mortgage:
                        return loanProduct.additionalField ?? loanProduct.displayName
                    }
                    
                case .profile:
                    return loanProduct.displayName
                }
                
            default:
                return product.displayName
            }
        }
        
        static func dateLong(from data: ProductData) -> String? {
            
            switch data {
                
            case let depositProduct as ProductDepositData:
                guard let endDate = depositProduct.endDate else { return nil }
                return DateFormatter.shortDate.string(from: endDate)
                
            case let loanProduct as ProductLoanData:
                return DateFormatter.shortDate.string(from: loanProduct.dateLong)
                
            default: return nil
            }
        }
        
        static func period(product: ProductData, style: Appearance.Style) -> String? {
            
            switch style {
            case .profile: return product.displayPeriod
            default: return nil
            }
        }
        
        static func paymentSystemIcon(from data: ProductData) -> Image? {
            
            guard let cardData = data as? ProductCardData else { return nil }
            return cardData.paymentSystemImage?.image
        }
        
        static func statusAction(product: ProductData) -> StatusActionViewModel? {
            
            guard let cardProduct = product as? ProductCardData else {
                return nil
            }

            if cardProduct.isActivated == false {
                
                return .init(status: .activation(.init(state: .notActivated)))
                
            } else if cardProduct.isBlocked == true {
                
                return .init(status: .unblock)
                
            } else {
                
                return nil
            }
        }
        
        static func backgroundImage(with productData: ProductData, size: Appearance.Size) -> Image? {
            
            switch size {
            case .large: return productData.extraLargeDesign.image
            case .normal: return productData.largeDesign.image
            case .small: return productData.mediumDesign.image
            }
        }
    }
}

//MARK: - Action

enum ProductViewModelAction {

    struct ProductDidTapped: Action {}
    
    enum CardActivation {
        
        struct Started: Action {}
        
        struct Complete: Action {}
        
        struct Failed: Action {}
    }
}

//MARK: - Internal ViewModels

extension ProductView.ViewModel {
    
    struct HeaderViewModel {
        
        var logo: Image? = nil
        let number: String?
        var period: String? = nil
    }
    
    class FooterViewModel: ObservableObject {
        
        @Published var balance: String
        let paymentSystem: Image?
        
        init(balance: String, paymentSystem: Image? = nil) {
            
            self.balance = balance
            self.paymentSystem = paymentSystem
        }
    }
    
    class StatusActionViewModel {

        let action: PassthroughSubject<Action, Never> = .init()
        
        let status: Status
        
        private var bindings = Set<AnyCancellable>()
        
        init(status: Status) {
            
            self.status = status
            
            switch status {
            case .activation(let cardActivateSliderViewModel):
                bind(cardActivateSliderViewModel)
                
            default:
                break
            }
        }
        
        func bind() {
            
            action
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] action in
                    
                    switch action {
                    case _ as ProductView.ViewModel.StatusActionViewModelAction.CardActivation.Complete:
                        switch status {
                        case .activation(let cardActivateSliderViewModel):
                            cardActivateSliderViewModel.state = .activated
                            
                        default:
                            break
                        }
                        
                    case _ as ProductView.ViewModel.StatusActionViewModelAction.CardActivation.Failed:
                        switch status {
                        case .activation(let cardActivateSliderViewModel):
                            cardActivateSliderViewModel.state = .notActivated
                            
                        default:
                            break
                        }
                        
                    default:
                        break
                    }
                    
                }.store(in: &bindings)
        }
        
        private func bind(_ cardActivateSliderViewModel: CardActivateSliderView.ViewModel) {
            
            cardActivateSliderViewModel.$state
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] state in
                    
                    if state == .activating {
                        
                        action.send(ProductView.ViewModel.StatusActionViewModelAction.CardActivation.Started())
                    }
                    
                }.store(in: &bindings)
        }
        
        func icon(with style: ProductView.ViewModel.Appearance.Style) -> Image {
            
            switch status {
            case .activation:
                switch style {
                case .main: return .ic24ArrowRightCircle
                case .profile: return .ic24ArrowRightCircle
                }
                
            case .unblock:
                switch style {
                case .main: return .ic24Lock
                case .profile: return .ic40Lock
                }
            }
        }
        
        func iconSize(with style: ProductView.ViewModel.Appearance.Style) -> CGSize {
            
            switch style {
            case .main: return .init(width: 24, height: 24)
            case .profile: return .init(width: 40, height: 40)
            }
        }
        
        enum Status {
            
            case activation(CardActivateSliderView.ViewModel)
            case unblock
        }
    }
    
    enum StatusActionViewModelAction {
    
        enum CardActivation {
            
            struct Started: Action {}
            
            struct Complete: Action {}
            
            struct Failed: Action {}
        }
    }
    
    struct Appearance {
        
        let textColor: Color
        let background: Background
        var opacity: Double = 1
        var size: Size = .normal
        var style: Style = .main
        
        struct Background {
            
            let color: Color
            let image: Image?
        }
        
        enum Size {
            
            case large
            case normal
            case small
        }
        
        enum Style {
            
            case main
            case profile
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
    
    var headerPaddingLeading: CGFloat {
        
        switch viewModel.appearance.size {
        case .large: return 43
        case .normal: return 43
        case .small: return 29
        }
    }
    
    var cardPadding: CGFloat {
        
        switch viewModel.appearance.size {
        case .large: return 12
        case .normal: return 12
        case .small: return 8
        }
    }
    
    var nameFont: Font {
        
        switch viewModel.appearance.size {
        case .large: return .textBodyMR14200()
        case .normal: return .textBodyMR14200()
        case .small: return .textBodyXSR11140()
        }
    }
    
    var nameSpacing: CGFloat {
        
        switch viewModel.appearance.size {
        case .large: return 6
        case .normal: return 6
        case .small: return 4
        }
    }
    
    var cornerRadius: CGFloat {
        
        switch viewModel.appearance.size {
        case .large: return 12
        case .normal: return 12
        case .small: return 8
        }
    }
    
    var checkPadding: CGFloat {
        
        switch viewModel.appearance.size {
            
        case .large: return 10
        case .normal: return 10
        case .small: return 8
        }
    }
    
    var body: some View {
        
        ZStack {
            
            if let backgroundImage = viewModel.appearance.background.image {
                
                backgroundImage
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .zIndex(0)
                
            } else {
                
                RoundedRectangle(cornerRadius: cornerRadius)
                    .foregroundColor(viewModel.appearance.background.color)
                    .zIndex(0)
            }
            
            VStack(alignment: .leading, spacing: 0) {
                
                ProductView.HeaderView(viewModel: viewModel.header, appearance: viewModel.appearance)
                    .padding(.leading, headerPaddingLeading)
                    .padding(.top, viewModel.appearance.size == .small ? 4 : 6.2)
                    
                Spacer()
                
                VStack(alignment: .leading, spacing: nameSpacing) {
                    
                    Text(viewModel.name)
                        .font(nameFont)
                        .foregroundColor(viewModel.appearance.textColor)
                        .opacity(0.5)
                        .accessibilityIdentifier("productName")
                    
                    ProductView.FooterView(viewModel: viewModel.footer, appearance: viewModel.appearance)
                }
            }
            .opacity(viewModel.appearance.opacity)
            .padding(cardPadding)
            .zIndex(1)
                            
            if let statusActionViewModel = viewModel.statusAction {
                
                ProductView.StatusActionView(viewModel: statusActionViewModel,
                                             color: viewModel.appearance.textColor,
                                             style: viewModel.appearance.style)
                    .zIndex(2)
            }
            
            if viewModel.isUpdating == true {
                
                HStack(spacing: 3) {
                    
                    ProductView.AnimatedDotView(duration: 0.6, delay: 0)
                    ProductView.AnimatedDotView(duration: 0.6, delay: 0.2)
                    ProductView.AnimatedDotView(duration: 0.6, delay: 0.4)
                }
                .zIndex(3)
                
                AnimatedGradientView(duration: 3.0)
                    .blendMode(.colorDodge)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                    .zIndex(4)
            }
            
            if viewModel.isChecked == true {
                
                VStack {
                    
                    HStack {
                        
                        Spacer()
                        CheckView(appearance: viewModel.appearance)
                    }
                    
                    Spacer()
                    
                }.padding(checkPadding)
            }
        }
        .onTapGesture {
           
            viewModel.action.send(ProductViewModelAction.ProductDidTapped())
        }
    }
}

//MARK: - Internal Views

extension ProductView {
    
    struct HeaderView: View {
        
        let viewModel: ViewModel.HeaderViewModel
        let appearance: ViewModel.Appearance
        
        var textFont: Font {
            
            switch appearance.size {
            case .large: return .textBodySR12160()
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
                        .accessibilityIdentifier("productNumber")
                }
                
                if let period = viewModel.period {
                    
                    Rectangle()
                        .frame(width: 1, height: 16)
                        .foregroundColor(appearance.textColor)
                    
                    Text(period)
                        .font(textFont)
                        .foregroundColor(appearance.textColor)
                        .accessibilityIdentifier("productPeriod")
                }
            }
        }
    }
    
    struct FooterView: View {
        
        @ObservedObject var viewModel: ViewModel.FooterViewModel
        let appearance: ViewModel.Appearance
        
        var textFont: Font {
            
            switch appearance.size {
            case .large: return .textBodyMSB14200()
            case .normal: return .textBodyMSB14200()
            case .small: return .textBodyXSR11140()
            }
        }
        
        var paymentSystemIconSize: CGSize {
            
            switch appearance.size {
            case .large: return .init(width: 28, height: 28)
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
                        .accessibilityIdentifier("productBalance")
                    
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
                        .accessibilityIdentifier("productBalance")
                    
                    Spacer()
                }
            }
        }
    }
    
    struct StatusActionView: View {
        
        let viewModel: ViewModel.StatusActionViewModel
        let color: Color
        let style: ViewModel.Appearance.Style
        
        var body: some View {
            
            switch viewModel.status {
            case .activation(let cardActivateViewModel):
                switch style {
                case .main:
                    ProductView.StatusView(icon: viewModel.icon(with: style),
                                           color: color,
                                           size: viewModel.iconSize(with: style))
                    
                case .profile:
                    CardActivateSliderView(viewModel: cardActivateViewModel)
                }
                
            case .unblock:
                ProductView.StatusView(icon: viewModel.icon(with: style),
                                       color: color,
                                       size: viewModel.iconSize(with: style))
            }
        }
    }
    
    struct StatusView: View {
        
        let icon: Image
        let color: Color
        let size: CGSize
        
        var body: some View {
            
            icon.resizable()
                .renderingMode(.template)
                .foregroundColor(color)
                .frame(width: size.width, height: size.height)
        }
    }
    
    // MARK: - Check
    
    struct CheckView: View {
        
        let appearance: ViewModel.Appearance
        
        var size: CGSize {
            
            switch appearance.size {
            case .large: return .init(width: 18, height: 18)
            case .normal: return .init(width: 18, height: 18)
            case .small: return .init(width: 16, height: 16)
            }
        }
        
        var imageSize: CGSize {
            
            switch appearance.size {
            case .large: return .init(width: 12, height: 12)
            case .normal: return .init(width: 12, height: 12)
            case .small: return .init(width: 10, height: 10)
            }
        }
        
        var body: some View {
            
            ZStack {

                Circle()
                    .frame(width: size.width, height: size.height)
                    .foregroundColor(.mainColorsBlack.opacity(0.12))
                
                Image.ic16Check
                    .resizable()
                    .foregroundColor(.mainColorsWhite)
                    .background(Color.clear)
                    .frame(width: imageSize.width, height: imageSize.height)
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
                .frame(width: 268, height: 160)
                .previewLayout(.fixed(width: 375, height: 200))
            
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
    
    static let notActivate = ProductView.ViewModel
        .init(id: 0,
              header: .init(logo: .ic24LogoForaColor, number: "7854", period: nil),
              name: "Classic",
              footer: .init(balance: "170 897 ₽", paymentSystem: Image("Payment System Visa")),
              statusAction: .init(status: .activation(.init(state: .notActivated))),
              appearance: .init(textColor: .white,
                                background: .init(color: .cardInfinite,
                                                  image: Image("Product Background Sample")),
                                opacity: 0.5,
                                style: .main),
              isUpdating: false,
              productType: .card)
    
    static let blocked = ProductView.ViewModel
        .init(id: 1,
              header: .init(logo: .ic24LogoForaColor,
                            number: "7854",
                            period: nil),
              name: "Classic",
              footer: .init(balance: "170 897 ₽",
                            paymentSystem: Image("Payment System Mastercard")),
              statusAction: .init(status: .unblock),
              appearance: .init(textColor: .white,
                                background: .init(color: .cardInfinite, image: nil),
                                opacity: 0.5,
                                style: .main),
              isUpdating: false,
              productType: .card)
    
    static let classic = ProductView.ViewModel(id: 2, header: .init(logo: .ic24LogoForaColor, number: "7854", period: nil), name: "Classic", footer: .init(balance: "170 897 ₽", paymentSystem: Image("Payment System Mastercard")), statusAction: nil, appearance: .init(textColor: .white, background: .init(color: .mainColorsRed, image: nil)), isUpdating: false,  productType: .card)
    
    static let account = ProductView.ViewModel(id: 3, header: .init(logo: .ic24LogoForaColor, number: "7854", period: nil), name: "Текущий зарплатный счет", footer: .init(balance: "170 897 ₽", paymentSystem: Image("Payment System Mastercard")), statusAction: nil, appearance: .init(textColor: .white, background: .init(color: .cardRIO, image: nil)), isUpdating: false, productType: .card)
    
    static let notActivateProfile = ProductView.ViewModel(id: 4, header: .init(logo: .ic24LogoForaColor, number: "7854", period: "12/24"), name: "Classic", footer: .init(balance: "170 897 ₽", paymentSystem: Image("Payment System Visa")), statusAction: .init(status: .activation(.init(state: .notActivated))), appearance: .init(textColor: .white, background: .init(color: .cardInfinite, image: Image("Product Background Large Sample")), style: .profile), isUpdating: false, productType: .deposit)
    
    static let blockedProfile = ProductView.ViewModel(id: 5, header: .init(logo: .ic24LogoForaColor, number: "7854", period: "12/24"), name: "Classic", footer: .init(balance: "170 897 ₽", paymentSystem: Image("Payment System Mastercard")), statusAction: .init(status: .unblock), appearance: .init(textColor: .white, background: .init(color: .cardInfinite, image: nil), style: .profile), isUpdating: false, productType: .card)
    
    static let classicProfile = ProductView.ViewModel(id: 6, header: .init(logo: .ic24LogoForaColor, number: "7854", period: "12/24"), name: "Classic\nФОРА-Премиум", footer: .init(balance: "170 897 ₽", paymentSystem: Image("Payment System Mastercard")), statusAction: nil, appearance: .init(textColor: .white, background: .init(color: .cardRIO, image: nil)), isUpdating: false, productType: .card)
    
    static let accountProfile = ProductView.ViewModel(id: 7, header: .init(logo: .ic24LogoForaColor, number: "7854", period: "12/24"), name: "Текущий зарплатный счет", footer: .init(balance: "170 897 ₽", paymentSystem: Image("Payment System Mastercard")), statusAction: nil, appearance: .init(textColor: .white, background: .init(color: .cardRIO, image: nil)), isUpdating: false, productType: .account)
    
    static let depositProfile = ProductView.ViewModel(id: 8, header: .init(logo: .ic24LogoForaColor, number: "7854", period: "12/24"), name: "Стандарный вклад", footer: .init(balance: "170 897 ₽", paymentSystem: Image("Payment System Mastercard")), statusAction: nil, appearance: .init(textColor: .mainColorsBlackMedium, background: .init(color: .cardRIO, image: Image( "Cover Deposit"))), isUpdating: false, productType: .deposit)
    
    static let updating = ProductView.ViewModel(id: 9, header: .init(logo: .ic24LogoForaColor, number: "7854", period: nil), name: "СБЕРЕГАТЕЛЬНЫЙ ОН-ЛАЙН", footer: .init(balance: "170 897 ₽", paymentSystem: Image("Payment System Visa")), statusAction: nil, appearance: .init(textColor: .white, background: .init(color: .cardInfinite, image: Image("Product Background Sample"))), isUpdating: true, productType: .card)
    
    static let classicSmall = ProductView.ViewModel(id: 10, header: .init(logo: .ic24LogoForaColor, number: "7854", period: nil), name: "Classic", footer: .init(balance: "170 897 ₽", paymentSystem: Image("Payment System Mastercard")), statusAction: nil, isChecked: true, appearance: .init(textColor: .white, background: .init(color: .mainColorsRed, image: nil), size: .small), isUpdating: false,  productType: .card)
    
    static let accountSmall = ProductView.ViewModel(id: 11, header: .init(logo: .ic24LogoForaColor, number: "7854", period: nil), name: "Текущий зарплатный счет", footer: .init(balance: "170 897 ₽", paymentSystem: Image("Payment System Mastercard")), statusAction: nil, isChecked: true, appearance: .init(textColor: .white, background: .init(color: .cardRIO, image: nil), size: .small), isUpdating: false, productType: .account)
}
