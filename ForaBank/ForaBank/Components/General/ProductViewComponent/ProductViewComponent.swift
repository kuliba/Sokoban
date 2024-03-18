//
//  ProductViewComponent.swift
//  ForaBank
//
//  Created by Дмитрий on 21.02.2022.
//

import Foundation
import Combine
import SwiftUI
import Tagged
import PinCodeUI
import CardUI

//MARK: - ViewModel

extension ProductView {
    
    class ViewModel: Identifiable, ObservableObject, Hashable {
        
        @AppStorage(.isNeedOnboardingShow) var isNeedOnboardingShow: Bool = true
        typealias ShowCVV = (CardDomain.CardId, @escaping (CardInfo.CVV?) -> Void) -> Void
        typealias CardAction = (CardDomain.CardEvent) -> Void
        let action: PassthroughSubject<Action, Never> = .init()
        
        let id: ProductData.ID
        let header: HeaderViewModel
        @Published var cardInfo: CardInfo
        @Published var footer: FooterViewModel
        @Published var statusAction: StatusActionViewModel?
        @Published var isChecked: Bool
        @Published var isUpdating: Bool
        
        var appearance: Appearance
        let productType: ProductType
        let cardAction: CardAction?
        let showCvv: ShowCVV?

        private var bindings = Set<AnyCancellable>()
        private let pasteboard = UIPasteboard.general
        
        internal init(
            id: ProductData.ID,
            header: HeaderViewModel,
            cardInfo: CardInfo,
            footer: FooterViewModel,
            statusAction: StatusActionViewModel?,
            isChecked: Bool = false,
            appearance: Appearance,
            isUpdating: Bool,
            productType: ProductType,
            cardAction: CardAction? = nil,
            showCvv: ShowCVV? = nil
        ) {
            self.id = id
            self.header = header
            self.cardInfo = cardInfo
            self.footer = footer
            self.statusAction = statusAction
            self.isChecked = isChecked
            self.appearance = appearance
            self.isUpdating = isUpdating
            self.productType = productType
            self.cardAction = cardAction
            self.showCvv = showCvv
        }
        
        convenience init(
            with productData: ProductData,
            isChecked: Bool = false,
            size: Appearance.Size,
            style: Appearance.Style,
            model: Model,
            cardAction: CardAction? = nil,
            showCvv: ShowCVV? = nil
        ) {
            let balance = Self.balanceFormatted(product: productData, style: style, model: model)
            let number = productData.displayNumber
            let numberMasked = Self.maskedValue(
                productData.numberMasked,
                replacements: .replacements)
            
            let period = Self.period(product: productData, style: style)
            let name = Self.name(product: productData, style: style, creditProductName: .navigationTitle)
            let owner = Self.owner(from: productData)
            let cvvTitle = (productData is ProductCardData) ? .cvvTitle : ""
            let cardInfo: CardInfo = .init(
                name: name,
                owner: owner,
                cvvTitle: .init(value: cvvTitle),
                cardWiggle: false,
                fullNumber: .init(value: productData.number ?? ""),
                numberMasked: .init(value: numberMasked)
            )
            let textColor = productData.fontDesignColor.color
            let productType = productData.productType
            let backgroundColor = productData.backgroundColor
            let backgroundImage = Self.backgroundImage(with: productData, size: size)
            let statusAction = Self.statusAction(product: productData)
            let interestRate = Self.rateFormatted(product: productData)
            self.init(
                id: productData.id,
                header: .init(number: number, period: period),
                cardInfo: cardInfo,
                footer: .init(balance: balance, interestRate: interestRate),
                statusAction: statusAction,
                isChecked: isChecked,
                appearance: .init(
                    textColor: textColor,
                    background: .init(
                        color: backgroundColor,
                        image: backgroundImage),
                    size: size,
                    style: style
                ),
                isUpdating: false,
                productType: productType,
                cardAction: cardAction,
                showCvv: showCvv
            )
            
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
            
            // CVV

            action
                .compactMap { $0 as? ProductViewModelAction.ShowCVV }
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] action in
                    if action.cardId.rawValue == self.id {
                        self.cardInfo.state = .maskedNumberCVV(.init(action.cvv.rawValue))
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
            
            cardInfo.name = Self.name(product: productData, style: appearance.style, creditProductName: .cardTitle)
            cardInfo.owner = Self.owner(from: productData)
            statusAction = Self.statusAction(product: productData)
            footer.balance = Self.balanceFormatted(product: productData, style: appearance.style, model: model)
            
            bind(statusAction)
        }
        
        static func rateFormatted(product: ProductData) -> String? {
            
            switch product {
            case let depositProduct as ProductDepositData:
                return String(format: "%.2f", depositProduct.interestRate) + "%"
                
            default:
                return nil
            }
        }
        
        static func balanceFormatted(product: ProductData, style: Appearance.Style, model: Model) -> String {
            
            switch product {
            case let loanProduct as ProductLoanData:
                return Self.balanceFormatted(
                    amount: loanProduct.amount,
                    debt: loanProduct.totalAmountDebtValue,
                    currency: loanProduct.currency,
                    style: style, 
                    model: model
                )
            default:
                return Self.balanceFormatted(
                    balance: product.balanceValue,
                    currency: product.currency,
                    style: style,
                    model: model
                )
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
        
        static func name(product: ProductData, style: Appearance.Style, creditProductName: Appearance.NameOfCreditProduct) -> String {
            
            switch product {
            case let cardProduct as ProductCardData:
                switch style {
                case .main:
                    return !cardProduct.displayName.isEmpty ? cardProduct.displayName : "Кредитная карта"
                    
                case .profile:
                    switch creditProductName {
                        
                    case .cardTitle:
                        return cardProduct.isCreditCard ? "Кредитная\n\(cardProduct.displayName)" : cardProduct.displayName
                        
                    case .navigationTitle:
                        return cardProduct.isCreditCard ? cardProduct.displayName : cardProduct.displayName
                    }
                }
                
            case let loanProduct as ProductLoanData:
                switch style {
                case .main:
                    return loanProduct.displayName
                    
                case .profile:
                    return loanProduct.additionalField ?? loanProduct.displayName
                }
                
            default:
                return product.displayName
            }
        }
        
        static func owner(from productData: ProductData) -> String {
            
            switch productData {
                
            case let card as ProductCardData:
                return card.holderName ?? ""
                
            default:
                return ""
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
        
        static func maskedValue(_ value: String?, replacements: [(String, String)]) -> String {
            
            if let value {
                
                return replacements.reduce(value) { string, replacement in
                    
                    string.replacingOccurrences(
                        of: replacement.0,
                        with: replacement.1
                    )
                }
            }
            
            return ""
        }
        
        func resetToFront() {
            Task { @MainActor [weak self] in
                
                self?.cardInfo.state = .showFront
            }
        }
        
        func resetToFrontIfNotAwaiting() {
            
            if cardInfo.state != .awaitingCVV {
                resetToFront()
            }
        }
    }
}

//MARK: - Action

enum ProductViewModelAction {
    
    struct ProductDidTapped: Action {}
    
    struct OnboardingShow: Action {}
    
    struct ShowCVV: Action {
        let cardId: CardDomain.CardId
        let cvv: CardInfo.CVV
    }
    
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
        @Published var interestRate: String?
        let paymentSystem: Image?
        
        init(balance: String, interestRate: String? = nil, paymentSystem: Image? = nil) {
            
            self.balance = balance
            self.interestRate = interestRate
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
        
        func icon(with style: Appearance.Style) -> Image {
            
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
        
        func iconSize(with style: Appearance.Style) -> CGSize {
            
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

private extension View {
    
    func card(
        viewModel: ProductView.ViewModel,
        config: CardUI.Config,
        isFrontView: Bool,
        action: @escaping () -> Void
    ) -> some View {
        
        self
            .modifier(
                ProductView.CardModifier(
                    viewModel: viewModel,
                    isFrontView: isFrontView,
                    config: config
                )
            )
            .onTapGesture(perform: action)
    }
}

private extension View {
    
    func animation(
        isShowingCardBack: Bool,
        cardWiggle: Bool,
        opacity: Values,
        radians: Values
    ) -> some View {
        
        self
            .modifier(ProductView.FlipOpacity(
                percentage: isShowingCardBack ? opacity.startValue : opacity.endValue))
            .rotation3DEffect(
                .radians(isShowingCardBack ? radians.startValue : radians.endValue),
                axis: (0,1,0),
                perspective: 0.1)
            .rotation3DEffect(
                .degrees(cardWiggle ? -20 : 0),
                axis: (0, 1, 0))
    }
}

struct ProductView: View {
    
    @StateObject private var viewModel: ViewModel
    let config: CardUI.Config
    
    init(
        viewModel: ViewModel
    ) {
        self._viewModel = .init(wrappedValue: viewModel)
        self.config = .config(appearance: viewModel.appearance)
    }

    var body: some View {
        
        ProductFrontView(
            name: $viewModel.cardInfo.name,
            balance: .init(
                get: {
                    .init(viewModel.footer.balance)
                },
                set: { _ in }
            ),
            config: config,
            headerView: {
                
                ProductView.HeaderView(config: config, header: viewModel.header)
            },
            footerView: { balance in
                
                ProductView.FooterView(
                    config: config,
                    footer: .init(
                        get: {
                            .init(
                                balance: balance.rawValue,
                                interestRate: viewModel.footer.interestRate,
                                paymentSystem: viewModel.footer.paymentSystem
                            )
                        },
                        set: { _ in }
                    )
                )
            })
        .card(
            viewModel: viewModel,
            config: config,
            isFrontView: true,
            action: viewModel.productDidTapped
        )
        .animation(
            isShowingCardBack: viewModel.cardInfo.isShowingCardBack,
            cardWiggle: viewModel.cardInfo.cardWiggle,
            opacity: .init(
                startValue: 0,
                endValue: viewModel.appearance.opacity),
            radians: .init(startValue: .pi, endValue: 2 * .pi)
        )
        .animation(
            .linear(duration: 0.5),
            value: viewModel.cardInfo.cardWiggle
        )
        .onAppear {
            
            viewModel.animationAtFisrtShowCard()
        }
        .onDisappear {
            
            viewModel.resetToFrontIfNotAwaiting()
        }
        
        ProductBackView(
            backViewConfig: config.back,
            headerView: {
                
                ProductView.HeaderBackView.init(
                    cardInfo: $viewModel.cardInfo,
                    action: viewModel.copyCardNumberToClipboard
                )
            },
            cvvView: {
                
                ProductView.CVVView.init(cardInfo: $viewModel.cardInfo, action: viewModel.showCVVButtonTap)
            }
        )
        .card(
            viewModel: viewModel,
            config: config,
            isFrontView: false,
            action: viewModel.productDidTapped
        )
        .animation(
            isShowingCardBack: viewModel.cardInfo.isShowingCardBack,
            cardWiggle: false,
            opacity: .init(startValue: viewModel.appearance.opacity, endValue: 0),
            radians: .init(startValue: 0, endValue: .pi)
        )
    }
}

//MARK: - Internal Views

extension ProductView {
    
    struct HeaderView: View {
        
        let config: CardUI.Config
        let header: ProductView.ViewModel.HeaderViewModel
        var body: some View {
            
            HStack(alignment: .center, spacing: 8) {
                
                if let number = header.number {
                    
                    Text(number)
                        .font(config.fonts.header)
                        .foregroundColor(config.appearance.textColor)
                        .accessibilityIdentifier("productNumber")
                }
                
                if let period = header.period {
                    
                    Rectangle()
                        .frame(width: 1, height: 16)
                        .foregroundColor(config.appearance.textColor)
                    
                    Text(period)
                        .font(config.fonts.header)
                        .foregroundColor(config.appearance.textColor)
                        .accessibilityIdentifier("productPeriod")
                }
            }
        }
    }
    
    struct FooterView: View {
        
        let config: CardUI.Config
        @Binding var footer: ProductView.ViewModel.FooterViewModel
        
        var body: some View {
            
            if let paymentSystem = footer.paymentSystem {
                
                HStack {
                    
                    Text(footer.balance)
                        .font(config.fonts.footer)
                        .fontWeight(.semibold)
                        .foregroundColor(config.appearance.textColor)
                        .accessibilityIdentifier("productBalance")
                    
                    Spacer()
                    
                }.overlay(
                    
                    HStack {
                        Spacer()
                        paymentSystem
                            .renderingMode(.template)
                            .resizable()
                            .frame(width: config.sizes.paymentSystemIcon.width, height: config.sizes.paymentSystemIcon.height)
                            .foregroundColor(config.appearance.textColor)
                            .accessibilityIdentifier("productPaymentSystemIcon")
                    }
                )
                
            } else {
                
                HStack {
                    
                    Text(footer.balance)
                        .font(config.fonts.footer)
                        .fontWeight(.semibold)
                        .foregroundColor(config.appearance.textColor)
                        .accessibilityIdentifier("productBalance")
                    
                    Spacer()
                    if let text = footer.interestRate {
                        
                        ZStack {
                            
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.mainColorsGrayMedium)
                                .frame(width: 56, height: 20)
                            Text(text)
                                .font(.textBodySM12160())
                                .fontWeight(.regular)
                                .foregroundColor(Color.textSecondary)
                        }
                    }
                }
            }
        }
    }
    
    struct StatusActionView: View {
        
        let viewModel: ViewModel.StatusActionViewModel
        let color: Color
        let style: Appearance.Style
        
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
        
        let sizeConfig: CardUI.Config.Sizes
        
        var body: some View {
            
            ZStack {
                
                Circle()
                    .frame(
                        width: sizeConfig.checkView.width,
                        height: sizeConfig.checkView.height
                    )
                    .foregroundColor(.mainColorsBlack.opacity(0.12))
                
                Image.ic16Check
                    .resizable()
                    .foregroundColor(.mainColorsWhite)
                    .background(Color.clear)
                    .frame(width: sizeConfig.checkViewImage.width, height: sizeConfig.checkViewImage.height)
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

//MARK: - Modifiers

extension ProductView {
    
    struct FlipOpacity: AnimatableModifier {
        
        var percentage: CGFloat = 0
        
        var animatableData: CGFloat {
            get { percentage }
            set { percentage = newValue }
        }
        
        func body(content: Content) -> some View {
            content
                .opacity(percentage.rounded())
        }
    }
}

extension ProductView {
    
    struct CardModifier: ViewModifier {
        
        @ObservedObject var viewModel: ViewModel
        
        let isFrontView: Bool
        let config: CardUI.Config
        
        @ViewBuilder
        private func checkView() -> some View {
            
            if viewModel.isChecked {
                CheckView(sizeConfig: config.sizes)
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity,
                        alignment: .topTrailing
                    )
                    .padding(config.front.checkPadding)
            }
        }
        
        @ViewBuilder
        private func statusActionView() -> some View {
            
            if let statusActionViewModel = viewModel.statusAction {
                
                ProductView.StatusActionView(
                    viewModel: statusActionViewModel,
                    color: config.appearance.textColor,
                    style: config.appearance.style
                )
            }
        }
        
        @ViewBuilder
        private func updatingView() -> some View {
            
            if viewModel.isUpdating == true {
                ZStack {
                    
                    HStack(spacing: 3) {
                        
                        ProductView.AnimatedDotView(duration: 0.6, delay: 0)
                        ProductView.AnimatedDotView(duration: 0.6, delay: 0.2)
                        ProductView.AnimatedDotView(duration: 0.6, delay: 0.4)
                    }
                    .zIndex(3)
                    
                    AnimatedGradientView(duration: 3.0)
                        .blendMode(.colorDodge)
                        .clipShape(RoundedRectangle(cornerRadius: config.front.cornerRadius))
                        .zIndex(4)
                }
            }
        }
        
        @ViewBuilder
        private func background() -> some View {
            
            if isFrontView, let backgroundImage = config.appearance.background.image {
                
                backgroundImage
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                
            } else {
                
                config.appearance.background.color
            }
        }
        
        func body(content: Content) -> some View {
            
            content
                .padding(config.front.cardPadding)
                .background(background())
                .overlay(checkView(), alignment: .topTrailing)
                .overlay(statusActionView(), alignment: .center)
                .overlay(updatingView(), alignment: .center)
                .clipShape(RoundedRectangle(cornerRadius: config.front.cornerRadius, style: .circular))
        }
    }
}

extension ProductView.ViewModel {
    
    func productDidTapped() {
        
        if productType == .card, appearance.size == .large {
            withAnimation(.spring(response: 1.0, dampingFraction: 1, blendDuration: 0)) {
                self.cardInfo.stateToggle()
            }
        }
        action.send(ProductViewModelAction.ProductDidTapped())
    }
    
    func onboardingDidShow() {
        
        isNeedOnboardingShow = false
    }
    
    func copyCardNumberToClipboard() {
        
        pasteboard.string = self.cardInfo.fullNumber.value
        self.cardInfo.state = .fullNumberMaskedCVV
        cardAction?(.copyCardNumber("Номер карты скопирован"))
    }
    
    func showCVVButtonTap() {
        let cardId = CardDomain.CardId.init(self.id)
        cardInfo.state = .awaitingCVV
        showCvv?(cardId) { cvv in
            
            Task { @MainActor [weak self] in
                if let cvv {
                    self?.cardInfo.state = .maskedNumberCVV(.init(cvv.rawValue))
                } else {
                    self?.cardInfo.state = .fullNumberMaskedCVV
                }
            }
        }
    }
    
    func animationAtFisrtShowCard() {
        
        let animationDuration: Double = 0.5
        
        let shouldOnBoard = isNeedOnboardingShow
        && productType == .card
        && appearance.size == .large
        
        if shouldOnBoard {
            
            onboardingDidShow()
            cardInfo.cardWiggle.toggle()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
                
                self.cardInfo.cardWiggle.toggle()
            }
        }
    }
}

//MARK: - Preview

struct ProductView_Previews: PreviewProvider {
    
    static func previewsGroup() -> some View {
        
        Group {
            
            Group {
                
                ProductView(viewModel: .updating)
                    .previewDisplayName("updating")
                ProductView(viewModel: .notActivate)
                    .previewDisplayName("notActivate")
                ProductView(viewModel: .blocked)
                    .previewDisplayName("blocked")
                ProductView(viewModel: .classic)
                    .previewDisplayName("classic")
                ProductView(viewModel: .account)
                    .previewDisplayName("account")
            }
            .frame(width: 164, height: 104)
            
            ProductView(viewModel: .notActivateProfile)
                .previewDisplayName("notActivateProfile")
                .frame(width: 268, height: 160)
            
            ProductView(viewModel: .blockedProfile)
                .previewDisplayName("blockedProfile")
                .frame(width: 268, height: 160)
                .frame(width: 375, height: 200)
            
            Group {
                
                ProductView(viewModel: .classicProfile)
                    .previewDisplayName("classicProfile")
                ProductView(viewModel: .accountProfile)
                    .previewDisplayName("accountProfile")
            }
            .frame(width: 268, height: 160)
            
            ProductView(viewModel: .depositProfile)
                .previewDisplayName("depositProfile")
                .frame(width: 228, height: 160)
            
            Group {
                
                ProductView(viewModel: .classicSmall)
                    .previewDisplayName("classicSmall")
                ProductView(viewModel: .accountSmall)
                    .previewDisplayName("accountSmall")
            }
            .frame(width: 112, height: 72)
        }
        .previewLayout(.sizeThatFits)
    }
    
    static var previews: some View {
        
        Group {
            previewsGroup()
            
            // Xcode 14
            VStack(content: previewsGroup)
                .previewDisplayName("For Xcode 14 and later")
                .previewLayout(.sizeThatFits)
        }
    }
}

extension Array where Element == (String, String) {
    
    static let replacements = [
        ("X", "*"),
        ("-", " ")
    ]
}
