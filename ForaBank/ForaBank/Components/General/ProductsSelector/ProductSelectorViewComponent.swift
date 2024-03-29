//
//  ProductSelectorView.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 24.09.2022.
//

import SwiftUI
import Combine

// MARK: - ViewModel

extension ProductSelectorView {
    
    class ViewModel: ObservableObject, Identifiable {
        
        let action: PassthroughSubject<Action, Never> = .init()
        
        @Published var content: Content
        @Published var productCarouselViewModel: ProductCarouselView.ViewModel?
        
        let id: UUID = .init()
        let context: CurrentValueSubject<Context, Never>
        
        private let model: Model
        private var bindings = Set<AnyCancellable>()
        
        enum Content {
            
            case product(ProductViewModel)
            case placeholder(PlaceholderViewModel)
        }
        
        var productViewModel: ProductViewModel? {
            
            guard case let .product(productViewModel) = content else {
                return nil
            }
            
            return productViewModel
        }
        
        var selectedProductId: ProductData.ID? { productViewModel?.id }
        
        init(_ model: Model, content: Content, productCarouselViewModel: ProductCarouselView.ViewModel?, context: Context) {
            
            self.model = model
            self.content = content
            self.productCarouselViewModel = productCarouselViewModel
            self.context = .init(context)
            
            LoggerAgent.shared.log(level: .debug, category: .ui, message: "ProductSelectorView.ViewModel initialized")
        }
        
        deinit {
            
            LoggerAgent.shared.log(level: .debug, category: .ui, message: "ProductSelectorView.ViewModel deinitialized")
        }
        
        convenience init(_ model: Model, productData: ProductData, context: Context, isListOpen: Bool = false) {
            
            let productViewModel: ProductViewModel = .init(model, productData: productData, context: context)
            
            if isListOpen == false {
                
                self.init(model, content: .product(productViewModel), productCarouselViewModel: nil, context: context)
                
            } else {
                
                let productCarouselViewModel = ProductCarouselView.ViewModel(
                    selectedProductId: productData.id,
                    mode: .filtered(context.filter),
                    isScrollChangeSelectorEnable: true,
                    style: .small,
                    model: model
                )
                self.init(model, content: .product(productViewModel), productCarouselViewModel: productCarouselViewModel, context: context)
            }
            
            bind()
            bind(productCarouselViewModel: productCarouselViewModel)
        }
        
        convenience init(_ model: Model, context: Context) {
            
            self.init(model, content: .placeholder(.init(context)), productCarouselViewModel: nil, context: context)
            bind()
        }
        
        convenience init(_ model: Model, parameterProduct: Payments.ParameterProduct) {
            
            let context = Context(title: parameterProduct.title, direction: .from, style: .regular, filter: parameterProduct.filter)
            
            if let productId = parameterProduct.productId,
               let productData = model.product(productId: productId) {
                
                self.init(model, productData: productData, context: context)
                
            } else if let productData = model.firstProduct(with: .generalFrom) {
                self.init(model, productData: productData, context: context)
                
            } else {
                self.init(model, context: context)
            }
        }
        
        private func bind() {
            
            action
                .compactMap { $0 as? ProductSelectorAction.Product.Tap }
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    
                    self?.toggleCarousel()
                }
                .store(in: &bindings)
            
            context
                .receive(on: DispatchQueue.main)
                .sink { [weak self] context in
                    
                    self?.updateContent(with: context)
                }
                .store(in: &bindings)
        }
        
        func bind(productCarouselViewModel: ProductCarouselView.ViewModel?) {
            
            typealias CarouselProductDidTapped = ProductCarouselViewModelAction.Products.ProductDidTapped
            
            productCarouselViewModel?.action
                .compactMap { $0 as? CarouselProductDidTapped }
                .map(\.productId)
                .sink { [weak self] productID in
                    
                    self?.selectProduct(withID: productID)
                }
                .store(in: &bindings)
        }
        
        private func toggleCarousel() {
            
            if productCarouselViewModel == nil {
                
                withAnimation {
                    
                    self.productCarouselViewModel = .init(
                        selectedProductId: selectedProductId,
                        mode: .filtered(context.value.filter),
                        isScrollChangeSelectorEnable: true,
                        style: .small,
                        model: model
                    )
                }
                
                bind(productCarouselViewModel: productCarouselViewModel)
                
            } else {
                
                collapseList()
            }
            
            setCollapsed(to: productCarouselViewModel == nil)
        }
        
        func collapseList() {
            
            withAnimation {
                productCarouselViewModel = nil
            }
        }
        
        private func setCollapsed(to isCollapsed: Bool) {
            
            withAnimation {
                
                switch content {
                case let .product(productViewModel):
                    productViewModel.isCollapsed = isCollapsed
                    
                case let .placeholder(placeholderViewModel):
                    placeholderViewModel.isCollapsed = isCollapsed
                }
            }
        }
        
        private func updateContent(with context: Context) {
            
            switch content {
            case let .product(productViewModel):
                productViewModel.update(context: context)
                
            case let .placeholder(placeholderViewModel):
                placeholderViewModel.update(context: context)
            }
        }
        
        private func selectProduct(withID productID: ProductData.ID) {
            
            guard let product = model.product(productId: productID) else {
                return
            }
            
            let productViewModel = ProductViewModel(
                model,
                productData: product,
                context: context.value
            )
            
            content = .product(productViewModel)
            collapseList()
            
            action.send(ProductSelectorAction.Selected(id: product.id))
        }
    }
}

extension ProductSelectorView.ViewModel {
    
    static func degreesForChevron(isCollapsed: Bool) -> Double {
        
      return isCollapsed ? 0 : 180
    }
}

extension ProductSelectorView.ViewModel {
    
    // MARK: - Context
    
    struct Context {
        
        // Product
        var title: String
        var direction: Direction
        var style: Style
        var isUserInteractionEnabled: Bool = true
        
        // ProductsList
        var filter: ProductData.Filter
        
        enum Direction {
            
            case from
            case to
        }
        
        enum Style {
            
            case regular
            case me2me
        }
    }
    
    // MARK: - Product
    
    class ProductViewModel: ObservableObject {
        
        let action: PassthroughSubject<Action, Never> = .init()
        
        let id: ProductData.ID
        @Published var title: String
        @Published var cardIcon: Image?
        @Published var paymentIcon: Image?
        @Published var name: String
        @Published var balance: String
        @Published var numberCard: String?
        @Published var description: String?
        @Published var isCollapsed: Bool
        @Published var isUserInteractionEnabled: Bool
        let style: Context.Style
        
        init(id: Int, title: String = "", cardIcon: Image? = nil, paymentIcon: Image? = nil, name: String, balance: String, numberCard: String? = nil, description: String? = nil, isCollapsed: Bool = true, isUserInteractionEnabled: Bool = true, style: Context.Style = .regular) {
            
            self.id = id
            self.title = title
            self.cardIcon = cardIcon
            self.paymentIcon = paymentIcon
            self.name = name
            self.balance = balance
            self.numberCard = numberCard
            self.description = description
            self.isCollapsed = isCollapsed
            self.isUserInteractionEnabled = isUserInteractionEnabled
            self.style = style
        }
        
        convenience init(_ model: Model, productData: ProductData, context: Context) {
            
            let name = ProductView.ViewModel.name(product: productData, style: .main, creditProductName: .cardTitle)
            let balance = ProductView.ViewModel.balanceFormatted(product: productData, style: .main, model: model)
            
            var paymentSystemImage: Image?
            
            if let product = productData as? ProductCardData {
                paymentSystemImage = model.images.value[product.paymentSystemMd5Hash]?.image
            }
            let cardIcon = model.images.value[productData.smallDesignMd5hash]?.image
            
            self.init(id: productData.id, title: context.title, cardIcon: cardIcon, paymentIcon: paymentSystemImage, name: name, balance: balance, numberCard: productData.displayNumber, description: productData.additionalField, isUserInteractionEnabled: context.isUserInteractionEnabled, style: context.style)
        }
        
        func update(context: ProductSelectorView.ViewModel.Context) {
            title = context.title
            isUserInteractionEnabled = context.isUserInteractionEnabled
        }
    }
    
    // MARK: - Placeholder
    
    class PlaceholderViewModel: ObservableObject {
        
        let action: PassthroughSubject<Action, Never> = .init()
        
        @Published var title: String
        @Published var isCollapsed: Bool
        
        let description: String
        
        init(title: String = "", isCollapsed: Bool = true, description: String = "Номер карты или счета") {
            
            self.title = title
            self.isCollapsed = isCollapsed
            self.description = description
        }
        
        convenience init(_ context: Context) {
            self.init(title: context.title)
        }
        
        func update(context: ProductSelectorView.ViewModel.Context) {
            title = context.title
        }
    }
}

// MARK: - Action

enum ProductSelectorAction {
    
    struct Selected: Action {
        
        let id: ProductData.ID
    }
    
    enum Product {
        
        struct Tap: Action {
            
            let id: UUID
        }
    }
}

// MARK: - View

struct ProductSelectorView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 13) {
            
            Group(content: content)
                .padding(.leading, 12)
                .padding(.trailing, 16)
            
            viewModel.productCarouselViewModel
                .map(ProductCarouselView.init(viewModel:))
                .animation(nil)
                .accessibilityIdentifier("ProductSelectorCarousel")
        }
        .padding(.top, 13)
        .padding(.bottom, bottomPadding)
    }
    
    @ViewBuilder
    private func content() -> some View {
        
        switch viewModel.content {
        case let .product(productViewModel):
            SelectedProductView(viewModel: productViewModel)
                .onTapGesture {
                    if productViewModel.isUserInteractionEnabled == true {
                        viewModel.action.send(ProductSelectorAction.Product.Tap(id: viewModel.id))
                    }
                }
            
        case let .placeholder(placeholderViewModel):
            ProductPlaceholderView(viewModel: placeholderViewModel)
                .onTapGesture {
                    viewModel.action.send(ProductSelectorAction.Product.Tap(id: viewModel.id))
                }
        }
    }
    
    private var bottomPadding: CGFloat {
        
        viewModel.productCarouselViewModel == nil ? 13 : 5
    }
}

extension ProductSelectorView {
    
    // MARK: - Selected Product
    
    struct SelectedProductView: View {
        
        @ObservedObject var viewModel: ViewModel.ProductViewModel
        
        var body: some View {
            
            VStack(alignment: .leading, spacing: 0) {
                
                titleView
                
                HStack(spacing: 12) {
                    
                    cardIconView
                        .frame(width: 32, height: 22)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        
                        
                        HStack(spacing: 8) {
                            
                            paymentIconView
                                .frame(width: 24, height: 24)
                            
                            HStack(spacing: 0) {
                                
                                Text(viewModel.name)
                                    .lineLimit(1)
                                    .accessibilityIdentifier("ProductSelectorProductName")
                                
                                Spacer(minLength: 8)
                                
                                Text(viewModel.balance)
                                    .layoutPriority(1)
                                    .accessibilityIdentifier("ProductSelectorProductBalance")
                            }
                            .font(.textH4M16240())
                            .foregroundColor(.textSecondary)
                            
                            chevron
                                .frame(width: 24, height: 24)
                        }
                        
                        productDetailView
                    }
                }
            }
        }
        
        @ViewBuilder
        private var titleView: some View {
            
            Text(viewModel.title)
                .font(.textBodyMR14180())
                .foregroundColor(.textPlaceholder)
        }
        
        @ViewBuilder
        private var cardIconView: some View {
            
            if let cardIcon = viewModel.cardIcon {
                
                cardIcon
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .accessibilityIdentifier("ProductSelectorProductIcon")
                
            } else {
                
                RoundedRectangle(cornerRadius: 3)
                    .foregroundColor(.mainColorsGrayLightest)
            }
        }
        
        @ViewBuilder
        private var paymentIconView: some View {
            
            if let paymentIcon = viewModel.paymentIcon {
                
                paymentIcon
                    .resizable()
                    .accessibilityIdentifier("ProductSelectorPaymentSystemIcon")
            }
        }
        
        @ViewBuilder
        private var chevron: some View {
            
            let foregroundColor: Color = viewModel.isUserInteractionEnabled ? .mainColorsGray : .blurGray20
            let degrees = ProductSelectorView.ViewModel.degreesForChevron(isCollapsed: viewModel.isCollapsed)
            
            Image.ic24ChevronDown
                .renderingMode(.template)
                .resizable()
                .foregroundColor(foregroundColor)
                .rotationEffect(.degrees(degrees))
        }
        
        private var productDetailView: some View {
            
            HStack(spacing: 8) {
                
                if let numberCard = viewModel.numberCard {
                    
                    circle
                    
                    Text(numberCard)
                        .accessibilityIdentifier("ProductSelectorProductNumber")
                }
                
                if let description = viewModel.description {
                    
                    circle
                    
                    Text(description)
                        .accessibilityIdentifier("ProductSelectorProductDescription")
                }
            }
            .font(.textBodyMR14180())
            .foregroundColor(.mainColorsGray)
        }
        
        private var circle: some View {
            
            Circle()
                .frame(width: 3, height: 3)
                .foregroundColor(.mainColorsGray)
        }
    }
    
    // MARK: - Placeholder
    
    struct ProductPlaceholderView: View {
        
        @ObservedObject var viewModel: ViewModel.PlaceholderViewModel
        
        var body: some View {
            
            VStack(alignment: .leading, spacing: 14) {
                
                Text(viewModel.title)
                    .font(.textBodySR12160())
                    .foregroundColor(.mainColorsBlack)
                
                HStack {
                    
                    Text(viewModel.description)
                        .font(.textBodyMR14200())
                        .foregroundColor(.mainColorsGray)
                    
                    Spacer()
                    
                    let degrees = ProductSelectorView.ViewModel.degreesForChevron(isCollapsed: viewModel.isCollapsed)

                    Image.ic24ChevronDown
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.mainColorsGray)
                        .rotationEffect(.degrees(degrees))
                }
            }
        }
    }
}

// MARK: - Previews

struct ProductSelectorView_Previews: PreviewProvider {
    
    static func previewsGroup() -> some View {
        
        Group {
            
            ProductSelectorView(viewModel: .sampleRegularCollapsed)
            ProductSelectorView(
                viewModel: .sampleRegularCollapsed(
                    .sampleRegularLong
                )
            )
            ProductSelectorView(viewModel: .sampleMe2MeCollapsed)
            ProductSelectorView(viewModel: .sample2)
            ProductSelectorView(viewModel: .sample3)
        }
    }
    
    static var previews: some View {
        
        Group {
            previewsGroup()
            
            // Xcode 14
            VStack(spacing: 32, content: previewsGroup)
                .previewDisplayName("For Xcode 14 and later")
        }
        .previewLayout(.sizeThatFits)
    }
}

// MARK: - Preview Content

extension ProductSelectorView.ViewModel.ProductViewModel {
    
    typealias ProductViewModel = ProductSelectorView.ViewModel.ProductViewModel
    
    static let sample1: ProductViewModel = .init(
        id: 10002585801,
        title: "Откуда",
        cardIcon: .init("Platinum Card"),
        paymentIcon: .init("Platinum Logo"),
        name: "Platinum",
        balance: "2,71 млн ₽",
        numberCard: "2953",
        description: "Все включено",
        style: .me2me)
    
    static let sample2: ProductViewModel = .init(
        id: 10002585802,
        title: "Куда",
        cardIcon: .init("Platinum Card"),
        paymentIcon: .init("Platinum Logo"),
        name: "Platinum",
        balance: "2,71 млн ₽",
        numberCard: "2953",
        description: "Все включено",
        style: .me2me)
    
    static let sampleRegular: ProductViewModel = .init(
        id: 10002585801,
        title: "Счет списания",
        cardIcon: .init("Platinum Card"),
        paymentIcon: .init("Platinum Logo"),
        name: "Platinum",
        balance: "2,71 млн ₽",
        numberCard: "2953",
        description: "Все включено",
        style: .regular)
    
    static let sampleRegularLong: ProductViewModel = .init(
        id: 10002585801,
        title: "Счет списания",
        cardIcon: .init("Platinum Card"),
        paymentIcon: .init("Platinum Logo"),
        name: "Platinum Super Extra Dry",
        balance: "2,71 млн ₽",
        numberCard: "2953",
        description: "Все включено",
        style: .regular
    )
}
