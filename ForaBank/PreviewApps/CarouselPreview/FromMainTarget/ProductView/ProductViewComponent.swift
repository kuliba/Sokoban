//
//  ProductViewComponent.swift
//  ForaBank
//
//  Created by Дмитрий on 21.02.2022.
//

import Combine
import SwiftUI
import Tagged
import PinCodeUI
import ForaTools

protocol Action {}

//MARK: - ViewModel

extension ProductView {
    
    class ViewModel: Identifiable, ObservableObject, Hashable {
        
        var isNeedOnboardingShow: Bool = false
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

        private var bindings = Set<AnyCancellable>()
        private let pasteboard = UIPasteboard.general
        
        init(
            id: ProductData.ID,
            header: HeaderViewModel,
            cardInfo: CardInfo,
            footer: FooterViewModel,
            statusAction: StatusActionViewModel?,
            isChecked: Bool = false,
            appearance: Appearance,
            isUpdating: Bool,
            productType: ProductType,
            cardAction: CardAction? = nil
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
        
        static func owner(from productData: ProductData) -> String {
            
            switch productData {
                
            case let card as ProductCardData:
                return card.holderName ?? ""
                
            default:
                return ""
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
            return image(from: cardData.paymentSystemImage)
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
            case .large: return image(from: productData.extraLargeDesign)
            case .normal: return image(from: productData.largeDesign)
            case .small: return image(from: productData.mediumDesign)
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
        
        private static func image(from imageString: String?) -> Image? {
        
            guard let imageString else { return nil }
            
            return SwiftUI.Image(svg: imageString)
        }
    }
}

//MARK: - Action

enum ProductViewModelAction {
    
    struct ProductDidTapped: Action {}
    
    struct OnboardingShow: Action {}
    
    struct ShowCVV: Action {
        let cardId: CardDomain.CardId
        let cvv: ProductView.ViewModel.CardInfo.CVV
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
        
        func icon(with style: ProductView.ViewModel.Appearance.Style) -> Image {
            
            switch status {
            case .activation:
                switch style {
                case .main: return Image("ic24ArrowRightCircle")
                case .profile: return Image("ic24ArrowRightCircle")
                }
                
            case .unblock:
                switch style {
                case .main: return Image("ic24Lock")
                case .profile: return Image("ic40Lock")
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
            
            init(color: Color, image: Image?) {
                self.color = color
                self.image = image
            }
            
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
        
        enum NameOfCreditProduct {
            
            case navigationTitle
            case cardTitle
        }
        
        init(
            textColor: Color,
            background: Background,
            opacity: Double = 1,
            size: Size = .normal,
            style: Style = .main
        ) {
            self.textColor = textColor
            self.background = background
            self.opacity = opacity
            self.size = size
            self.style = style
        }
    }
    
    struct CardInfo: Equatable {
        
        typealias CVV = Tagged<_CVV, String>
        enum _CVV {}

        var name: String
        var owner: String
        
        let cvvTitle: CVVTitle
        var cardWiggle: Bool
        let fullNumber: FullNumber
        let numberMasked: MaskedNumber
        var state: State = .showFront

        init(
            name: String,
            owner: String,
            cvvTitle: CVVTitle,
            cardWiggle: Bool,
            fullNumber: FullNumber,
            numberMasked: MaskedNumber,
            state: State = .showFront
        ) {
            self.name = name
            self.owner = owner
            self.cvvTitle = cvvTitle
            self.cardWiggle = cardWiggle
            self.fullNumber = fullNumber
            self.numberMasked = numberMasked
            self.state = state
        }
        
        enum State: Equatable {
            
            case awaitingCVV
            case fullNumberMaskedCVV
            case maskedNumberCVV(CVV)
            case showFront
        }
        
        struct FullNumber: Equatable {
            
            init(value: String) {
                self.value = value
            }
            
            let value: String
        }
        
        struct MaskedNumber: Equatable {
            
            init(value: String) {
                self.value = value
            }
            
            let value: String
        }
                
        struct CVVTitle: Equatable {
            
            init(value: String) {
                self.value = value
            }
            
            let value: String
        }
        
        mutating func stateToggle() {
            
            switch state {
                
            case .showFront:
                
                state = .fullNumberMaskedCVV
                
            default:
                
                state = .showFront
            }
        }
    }
}

extension ProductView.ViewModel.CardInfo {
    
    var numberToDisplay: String {
        
        switch state {
            
        case .maskedNumberCVV, .awaitingCVV:
            return numberMasked.value
            
        case .fullNumberMaskedCVV, .showFront:
            return fullNumber.value.formatted()
        }
    }
    
    var cvvToDisplay: String {
        
        switch state {
            
        case .fullNumberMaskedCVV, .showFront, .awaitingCVV:
            return cvvTitle.value
            
        case let .maskedNumberCVV(value):
            return value.rawValue
        }
    }
    
    var isShowingCardBack: Bool {
        
        return state != .showFront
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
        config: ProductView.Config,
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

struct ProductView: View {
    
    @StateObject private var viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self._viewModel = .init(wrappedValue: viewModel)
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
            config: viewModel.config,
            headerView: {
                
                ProductView.HeaderView(config: viewModel.config, header: viewModel.header)
            },
            footerView: { balance in
                
                ProductView.FooterView(
                    config: viewModel.config,
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
            config: viewModel.config,
            isFrontView: true,
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
    }
}

//MARK: - Internal Views

extension ProductView {
    
    struct HeaderView: View {
        
        let config: ProductView.Config
        let header: ProductView.ViewModel.HeaderViewModel
        var body: some View {
            
            HStack(alignment: .center, spacing: 8) {
                
                if let number = header.number {
                    
                    Text(number)
                        .font(config.fontConfig.nameFontForHeader)
                        .foregroundColor(config.appearance.textColor)
                        .accessibilityIdentifier("productNumber")
                }
                
                if let period = header.period {
                    
                    Rectangle()
                        .frame(width: 1, height: 16)
                        .foregroundColor(config.appearance.textColor)
                    
                    Text(period)
                        .font(config.fontConfig.nameFontForHeader)
                        .foregroundColor(config.appearance.textColor)
                        .accessibilityIdentifier("productPeriod")
                }
            }
        }
    }
    
    struct FooterView: View {
        
        let config: ProductView.Config
        @Binding var footer: ProductView.ViewModel.FooterViewModel
        
        var body: some View {
            
            if let paymentSystem = footer.paymentSystem {
                
                HStack {
                    
                    Text(footer.balance)
                        .font(config.fontConfig.nameFontForFooter)
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
                            .frame(width: config.sizeConfig.paymentSystemIconSize.width, height: config.sizeConfig.paymentSystemIconSize.height)
                            .foregroundColor(config.appearance.textColor)
                            .accessibilityIdentifier("productPaymentSystemIcon")
                    }
                )
                
            } else {
                
                HStack {
                    
                    Text(footer.balance)
                        .font(config.fontConfig.nameFontForFooter)
                        .fontWeight(.semibold)
                        .foregroundColor(config.appearance.textColor)
                        .accessibilityIdentifier("productBalance")
                    
                    Spacer()
                    if let text = footer.interestRate {
                        
                        ZStack {
                            
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color("mainColorsGrayMedium"))
                                .frame(width: 56, height: 20)
                            Text(text)
                                .font(Font.custom("Inter-Medium", size: 12.0))
                                .fontWeight(.regular)
                                .foregroundColor(Color("textSecondary"))
                        }
                    }
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
        
        let sizeConfig: SizeConfig
        
        var body: some View {
            
            ZStack {
                
                Circle()
                    .frame(
                        width: sizeConfig.checkViewSize.width,
                        height: sizeConfig.checkViewSize.height
                    )
                    .foregroundColor(Color("mainColorsBlack").opacity(0.12))
                
                Image("ic16Check")
                    .resizable()
                    .foregroundColor(Color("mainColorsWhite"))
                    .background(Color.clear)
                    .frame(width: sizeConfig.checkViewImageSize.width, height: sizeConfig.checkViewImageSize.height)
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
        let config: ProductView.Config
        
        @ViewBuilder
        private func checkView() -> some View {
            
            if viewModel.isChecked {
                CheckView(sizeConfig: config.sizeConfig)
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity,
                        alignment: .topTrailing
                    )
                    .padding(config.cardViewConfig.checkPadding)
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
                        .clipShape(RoundedRectangle(cornerRadius: config.cardViewConfig.cornerRadius))
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
                .padding(config.cardViewConfig.cardPadding)
                .background(background())
                .overlay(checkView(), alignment: .topTrailing)
                .overlay(statusActionView(), alignment: .center)
                .overlay(updatingView(), alignment: .center)
                .clipShape(RoundedRectangle(cornerRadius: config.cardViewConfig.cornerRadius, style: .circular))
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

extension String {
    
    func formatted(
        withChunkSize chunkSize: Int = 4,
        withSeparator separator: String = " "
    ) -> String {
        var stringWithAddedSpaces = ""
        
        for i in Swift.stride(from: 0, to: self.count, by: 1) {
            if i > 0 && (i % chunkSize) == 0 {
                stringWithAddedSpaces.append(contentsOf: separator)
            }
            let characterToAdd = self[self.index(self.startIndex, offsetBy: i)]
            stringWithAddedSpaces.append(characterToAdd)
        }
        
        return stringWithAddedSpaces
    }
}
