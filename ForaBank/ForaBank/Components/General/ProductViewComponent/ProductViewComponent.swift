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
import ActivateSlider
import UIKit

//MARK: - ViewModel
    
class ProductViewModel: Identifiable, ObservableObject, Hashable {
    
    @AppStorage(.isNeedOnboardingShow) var isNeedOnboardingShow: Bool = true
    typealias CardAction = (CardDomain.CardEvent) -> Void
    let action: PassthroughSubject<Action, Never> = .init()
    
    let id: ProductData.ID
    var header: HeaderDetails
    let isChecked: Bool
    let productType: ProductType
    
    let cardAction: CardAction?
    let cvvInfo: CvvInfo?
    
    @Published var cardInfo: CardInfo
    @Published var footer: FooterDetails
    @Published var statusAction: StatusActionViewModel?
    @Published var isUpdating: Bool
    
    var appearance: Appearance
    var config: CardUI.Config
    
    private var bindings = Set<AnyCancellable>()
    private let pasteboard = UIPasteboard.general
    
    private let event: (Event) -> Void
    
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
        cvvInfo: CvvInfo? = nil,
        event: @escaping (Event) -> Void = { _ in }
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
        self.cvvInfo = cvvInfo
        self.config = .config(appearance: appearance)
        self.event = event
    }
    
    convenience init(
        with productData: ProductData,
        isChecked: Bool = false,
        size: Appearance.Size,
        style: Appearance.Style,
        model: Model,
        cardAction: CardAction? = nil,
        cvvInfo: CvvInfo? = nil,
        event: @escaping (Event) -> Void = { _ in }
    ) {
        let balance = Self.balanceFormatted(product: productData, style: style, model: model)
        let number = productData.displayNumber
        let numberMasked = Self.maskedValue(
            productData.numberMasked,
            replacements: .replacements)
        
        let period = Self.period(product: productData, style: style)
        let name = Self.name(
            product: productData,
            style: style,
            creditProductName: .productView
        )
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
        let backgroundImage = Self.backgroundImage(with: productData, size: size, getImage: { model.images.value[.init($0)]?.image })
        let statusAction = Self.statusAction(product: productData)
        let interestRate = Self.rateFormatted(product: productData)
        self.init(
            id: productData.id,
            header: .init(number: number, period: period, icon: productData.cloverImage),
            cardInfo: cardInfo,
            footer: .init(balance: balance, interestRate: interestRate),
            statusAction: statusAction,
            isChecked: isChecked,
            appearance: .init(
                background: .init(
                    color: backgroundColor,
                    image: backgroundImage),
                colors: .init(text: textColor, checkBackground:  productType == .deposit ? .init(hex: "F6F6F7"): backgroundColor),
                size: size,
                style: style
            ),
            isUpdating: false,
            productType: productType,
            cardAction: cardAction,
            cvvInfo: cvvInfo,
            event: event
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
                    statusAction?.action.send(ProductViewModel.StatusActionViewModelAction.CardActivation.Complete())
                    
                case _ as ProductViewModelAction.CardActivation.Failed:
                    statusAction?.action.send(ProductViewModel.StatusActionViewModelAction.CardActivation.Failed())
                    
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
    }
    
    private func bind(_ statusAction: StatusActionViewModel?) {
        
        statusAction?.action
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [unowned self] action in
                
                switch action {
                case _ as ProductViewModel.StatusActionViewModelAction.CardActivation.Started:
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
        header.updateIcon(productData.cloverImage)
        footer.balance = Self.balanceFormatted(product: productData, style: appearance.style, model: model)
        let backgroundImage = Self.backgroundImage(with: productData, size: appearance.size, getImage: { model.images.value[.init($0)]?.image })
        appearance.background = .init(color: productData.backgroundColor, image: backgroundImage)
        config = .config(appearance: appearance)
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
    
    static func name(
        product: ProductData,
        style: Appearance.Style,
        creditProductName: Appearance.NameOfCreditProduct
    ) -> String {
      
        switch product {
            
        case let cardProduct as ProductCardData:
            switch style {
            case .main:
                return !cardProduct.displayName.isEmpty ? cardProduct.displayName : "Кредитная карта"
                
            case .profile:
                switch creditProductName {
                    
                case .cardTitle:
                    return cardProduct.isCreditCard ? "Кредитная\n\(cardProduct.displayName)" : cardProduct.displayName
                    
                case .myProductsSectionItem:
                    return cardProduct.displayName
                    
                case .productView:
                    return cardProduct.navigationBarName
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
    
    static func paymentSystemIcon(
        from data: ProductData,
        getImage: (MD5Hash) -> Image?
    ) -> Image? {
        
        guard let cardData = data as? ProductCardData else { return nil }
        return  getImage(.init(cardData.paymentSystemImageMd5Hash))
    }
    
    static func statusAction(product: ProductData) -> StatusActionViewModel? {
        
        guard let cardProduct = product as? ProductCardData, let statusCard = cardProduct.statusCard else {
            return nil
        }
        
        switch statusCard {
        case .active:
            if !cardProduct.isVisible { return .init(status: .show) }
            else { return nil }
            
        case .blockedUnlockAvailable, .blockedUnlockNotAvailable:
            if cardProduct.isVisible { return .init(status: .unblock) }
            else { return .init(status: .unblockShow) }
            
        case .notActivated:
            return .init(status: .activation(.init(state: .notActivated)))
        }
    }
    
    static func backgroundImage(with productData: ProductData, size: Appearance.Size, getImage: @escaping (MD5Hash) -> Image?) -> Image? {
        
        switch size {
        case .large: return getImage(.init(productData.xlDesignMd5Hash))
        case .normal:
            return getImage(.init(productData.largeDesignMd5Hash))
        case .small: return getImage(.init(productData.mediumDesignMd5Hash))
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

extension ProductViewModel {
            
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
                    case _ as ProductViewModel.StatusActionViewModelAction.CardActivation.Complete:
                        switch status {
                        case .activation(let cardActivateSliderViewModel):
                            cardActivateSliderViewModel.state = .activated
                            
                        default:
                            break
                        }
                        
                    case _ as ProductViewModel.StatusActionViewModelAction.CardActivation.Failed:
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
                        
                        action.send(ProductViewModel.StatusActionViewModelAction.CardActivation.Started())
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
            case .show:
                return .ic24EyeOff
                
            case .unblockShow:
                switch style {
                case .main: 
                    return .combineImages(
                        images: [
                            UIImage(named: "ic24Lock")!,
                            UIImage(named: "ic24EyeOff")!
                        ])!
                    // TODO: need ic40
                case .profile: return .combineImages(
                    images: [
                        UIImage(named: "ic24Lock")!,
                        UIImage(named: "ic24EyeOff")!
                    ])!
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
            case show
            case unblockShow
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

extension ProductViewModel {
    
    func hash(into hasher: inout Hasher) {
        
        hasher.combine(id)
    }
    
    static func == (lhs: ProductViewModel, rhs: ProductViewModel) -> Bool {
        
        return lhs.id == rhs.id
    }
}

//MARK: - View
struct ProductViewFactory<Slider: View> {
    
    let makeSlider: MakeSlider
    
    typealias MakeSlider = () -> Slider
}

extension GenericProductView where Slider == EmptyView {
    
    init(viewModel: ProductViewModel) {
        
        self.init(viewModel: viewModel, factory: .init(makeSlider: EmptyView.init))
    }
}

typealias ProductView = GenericProductView<EmptyView>

struct GenericProductView<Slider: View>: View {
    
    @StateObject private var viewModel: ProductViewModel
    private let factory: Factory
    
    typealias Factory = ProductViewFactory<Slider>
    
    init(
        viewModel: ProductViewModel,
        factory: Factory
    ) {
        self._viewModel = .init(wrappedValue: viewModel)
        self.factory = factory
    }

    var body: some View {
        
        ProductFrontView(
            name: viewModel.cardInfo.name,
            headerDetails: viewModel.header,
            footerDetails: viewModel.footer,
            modifierConfig: modifierConfig(viewModel.cardInfo.cardWiggle),
            activationView: factory.makeSlider,
            statusView: statusView,
            config: viewModel.config
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
        
        if viewModel.appearance.style == .profile {
         
            ProductBackView(
                cardInfo: viewModel.cardInfo,
                actions: .init(
                    header: viewModel.copyCardNumberToClipboard,
                    cvv: viewModel.showCVVButtonTap),
                modifierConfig: modifierConfig(false),
                config: viewModel.config
            )
        }
    }
    
    @ViewBuilder
    private func statusView() -> some View {
        
        viewModel.statusAction.map {
            
            return StatusActionView(
                viewModel: $0,
                color: viewModel.config.appearance.colors.text,
                style: viewModel.config.appearance.style)
        }
    }
    
    private func modifierConfig(_ cardWiggle: Bool) -> ModifierConfig {
        .init(
            isChecked: viewModel.isChecked,
            isUpdating: viewModel.isUpdating,
            opacity: viewModel.appearance.opacity,
            isShowingCardBack: viewModel.cardInfo.isShowingCardBack,
            cardWiggle: cardWiggle,
            action: viewModel.productDidTapped
        )
    }
}

//MARK: - Internal Views

extension GenericProductView {
    
    struct StatusActionView: View {
        
        let viewModel: ProductViewModel.StatusActionViewModel
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
                    EmptyView()
                }
                
            case .unblock:
                ProductView.StatusView(icon: viewModel.icon(with: style),
                                       color: color,
                                       size: viewModel.iconSize(with: style))
            case .show:
                if case .profile = style {
                    ProductView.StatusView(icon: viewModel.icon(with: style),
                                           color: color,
                                           size: viewModel.iconSize(with: style))
                }
            case .unblockShow:
                let countImages = 2.0 // 2 images: unblock + show
                let size = viewModel.iconSize(with: style)
                ProductView.StatusView(icon: viewModel.icon(with: style),
                                       color: color,
                                       size: CGSizeMake(size.width * countImages, size.height))
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

extension ProductViewModel {
    
    func productDidTapped() {
        
        if productType == .card, appearance.size == .large  {
            
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
         
        if cvvInfo?.cardStatus != .active {
            event(.delayAlert(.showBlockAlert))
        } else {
            
            if cvvInfo?.cardType == .additionalOther {
                event(.delayAlert(.showAdditionalOtherAlert))
            } else {
                
                let cardId = CardDomain.CardId.init(self.id)
                cardInfo.state = .awaitingCVV
                cvvInfo?.showCvv?(cardId) { cvv in
                    
                    Task { @MainActor [weak self] in
                        if let cvv {
                            self?.cardInfo.state = .maskedNumberCVV(.init(cvv.rawValue))
                        } else {
                            self?.cardInfo.state = .fullNumberMaskedCVV
                        }
                    }
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

extension ProductViewModel {
    
    typealias Event = AlertEvent
}

//MARK: - Preview

struct ProductView_Previews: PreviewProvider {
    
    private static func preview(
        _ viewModel: ProductViewModel
    ) -> some View {
        ProductView(viewModel: viewModel)
    }
    
    static func previewsGroup() -> some View {
        
        Group {
            
            GenericProductView(viewModel: .notActivateProfile, factory: .init(makeSlider: { Color.red.frame(width: 32, height: 32) }))
            
            Group {
                
                preview(.updating)
                    .previewDisplayName("updating")
                preview(.notActivate)
                    .previewDisplayName("notActivate")
                preview(.blocked)
                    .previewDisplayName("blocked")
                preview(.classic)
                    .previewDisplayName("classic")
                preview(.account)
                    .previewDisplayName("account")
            }
            .frame(width: 164, height: 104)
            
            preview(.notActivateProfile)
                .previewDisplayName("notActivateProfile")
                .frame(width: 268, height: 160)
            
            preview(.blockedProfile)
                .previewDisplayName("blockedProfile")
                .frame(width: 268, height: 160)
                .frame(width: 375, height: 200)
            
            Group {
                
                preview(.classicProfile)
                    .previewDisplayName("classicProfile")
                preview(.accountProfile)
                    .previewDisplayName("accountProfile")
            }
            .frame(width: 268, height: 160)
            
            preview(.depositProfile)
                .previewDisplayName("depositProfile")
                .frame(width: 228, height: 160)
            
            Group {
                
                preview(.classicSmall)
                    .previewDisplayName("classicSmall")
                preview(.accountSmall)
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
