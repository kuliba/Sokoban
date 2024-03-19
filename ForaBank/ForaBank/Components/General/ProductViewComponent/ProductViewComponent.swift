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
        let header: HeaderDetails
        @Published var cardInfo: CardInfo
        @Published var footer: FooterDetails
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
            header: HeaderDetails,
            cardInfo: CardInfo,
            footer: FooterDetails,
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
        
        FrontView(
            name: viewModel.cardInfo.name,
            balance: .init(viewModel.footer.balance),
            isChecked: viewModel.isChecked,
            isUpdating: viewModel.isUpdating,
            opacity: viewModel.appearance.opacity,
            isShowingCardBack: viewModel.cardInfo.isShowingCardBack,
            cardWiggle: viewModel.cardInfo.cardWiggle,
            config: config,
            headerView: { HeaderView(config: config, header: viewModel.header) },
            footerView: { balance in
                
                FooterView(
                    config: config,
                    footer: .init(
                        balance: balance.rawValue,
                        interestRate: viewModel.footer.interestRate,
                        paymentSystem: viewModel.footer.paymentSystem
                    )
                )
            },
            statusActionView: statusView, 
            action: viewModel.productDidTapped
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
        
        BackView(
            isChecked: viewModel.isChecked,
            isUpdating: viewModel.isUpdating,
            opacity: viewModel.appearance.opacity,
            isShowingCardBack: viewModel.cardInfo.isShowingCardBack,
            config: config,
            header: {
                
                HeaderBackView.init(
                    cardInfo: viewModel.cardInfo,
                    action: viewModel.copyCardNumberToClipboard,
                    config: config
                )
            },
            cvv: {
                
                CVVView.init(cardInfo: viewModel.cardInfo, config: config, action: viewModel.showCVVButtonTap)
            }, 
            action: viewModel.productDidTapped
        )
    }
    
    @ViewBuilder
    private func statusView() -> (some View)? {
        
        viewModel.statusAction.map {
            
            return ProductView.StatusActionView(
                viewModel: $0,
                color: config.appearance.textColor,
                style: config.appearance.style)
        }
    }
}

//MARK: - Internal Views

extension ProductView {
    
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
