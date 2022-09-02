//
//  ProductsListViewComponent.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 11.07.2022.
//

import SwiftUI
import Combine
import Shimmer

typealias ProductSelectorViewModel = ProductSelectorView.ViewModel
typealias ProductContentViewModel = ProductSelectorViewModel.ProductContentViewModel
typealias ProductListViewModel = ProductsListView.ViewModel

// MARK: - ViewModel

extension ProductSelectorView {

    class ViewModel: ObservableObject {
        
        let action: PassthroughSubject<Action, Never> = .init()
        
        @Published var title: String
        @Published var currency: Currency
        @Published var currencyOperation: CurrencyOperation
        @Published var isDividerHiddable: Bool
        @Published var productViewModel: ProductContentViewModel?
        @Published var listViewModel: ProductsListView.ViewModel?
        @Published var excludeProductId: ProductData.ID?
        @Published var isUserInteractionEnabled: Bool
        @Published var backgroundColor: Color
        
        var bindings = Set<AnyCancellable>()
        
        lazy var dividerViewModel: DividerViewModel = .init()
        
        private let model: Model
        
        init(_ model: Model,
             title: String,
             currency: Currency,
             currencyOperation: CurrencyOperation,
             productViewModel: ProductContentViewModel? = nil,
             listViewModel: ProductsListView.ViewModel? = nil,
             backgroundColor: Color = .mainColorsGrayLightest,
             isUserInteractionEnabled: Bool = true,
             isDividerHiddable: Bool = false) {
            
            self.model = model
            self.title = title
            self.currency = currency
            self.currencyOperation = currencyOperation
            self.productViewModel = productViewModel
            self.listViewModel = listViewModel
            self.backgroundColor = backgroundColor
            self.isUserInteractionEnabled = isUserInteractionEnabled
            self.isDividerHiddable = isDividerHiddable
            
            bind()
        }
        
        convenience init(
            _ model: Model,
            currency: Currency,
            currencyOperation: CurrencyOperation,
            productViewModel: ProductContentViewModel? = nil,
            listViewModel: ProductsListView.ViewModel? = nil,
            backgroundColor: Color = .mainColorsGrayLightest,
            isDividerHiddable: Bool = false) {
            
                self.init(model, title: "", currency: currency, currencyOperation: currencyOperation, productViewModel: productViewModel, listViewModel: listViewModel, backgroundColor: backgroundColor, isDividerHiddable: isDividerHiddable)
        }
        
        convenience init(_ model: Model, product: ProductData, backgroundColor: Color) {
            
            let currency: Currency = .init(description: product.currency)
            let productViewModel: ProductContentViewModel = .init(productId: product.id, productData: product, model: model)
            
            self.init(model, title: "", currency: currency, currencyOperation: .buy, productViewModel: productViewModel, backgroundColor: backgroundColor)
        }
        
        private func bind() {
            
            model.products
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] products in
                    
                    let products = model.products(currency: currency, currencyOperation: currencyOperation, products: products)
                    
                    if let productViewModel = productViewModel {
                        setProductSelectorData(products: products, productId: productViewModel.productId)
                    }
                    
                }.store(in: &bindings)
            
            action
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] action in
                    
                    switch action {
                        
                    case _ as ProductSelectorView.ProductAction.Toggle:
                        
                        withAnimation {
                            
                            switch listViewModel == nil {
                            case true:
                                
                                self.listViewModel = makeProductsList()
                                bindList()
                                
                                listViewModel?.$products
                                    .receive(on: DispatchQueue.main)
                                    .sink { [unowned self] products in
                                        
                                        if products.isEmpty == true {
                                            setProductSelectorData()
                                        }
                                        
                                    }.store(in: &bindings)
                                
                            case false: listViewModel = nil
                            }
                        }
                        
                    case let payload as ProductSelectorView.ProductAction.Selected:
                        
                        withAnimation { listViewModel = nil }
                        setProductSelectorData(productId: payload.productId)
                        
                    default:
                        break
                    }

                }.store(in: &bindings)
            
            listViewModel?.action
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] action in
                    
                    switch action {
                   
                    case let payload as ProductSelectorView.ProductAction.Selected:
                        
                        withAnimation { listViewModel = nil }
                        setProductSelectorData(productId: payload.productId)
                        
                    default:
                        break
                    }
                    
                }.store(in: &bindings)
            
            $listViewModel
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] listViewModel in
                    
                    withAnimation {
                        if let productViewModel = productViewModel {
                            productViewModel.isCollapsed = listViewModel == nil ? true : false
                        }
                    }
                    
                }.store(in: &bindings)
            
            $currency
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] currency in
                    
                    guard let listViewModel = listViewModel else {
                        return
                    }
                    
                    listViewModel.currency = currency
                    
                }.store(in: &bindings)
            
            $currencyOperation
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] currencyOperation in
                    
                    if let listViewModel = listViewModel {
                        listViewModel.currencyOperation = currencyOperation
                    } else {
                        updateProductViewModel()
                    }
                    
                }.store(in: &bindings)
        }
        
        private func bind(_ products: [ProductView.ViewModel]) {
            
            for product in products {
                
                product.action
                    .receive(on: DispatchQueue.main)
                    .sink { [unowned self] action in
                        
                        switch action {
                        case _ as ProductViewModelAction.ProductDidTapped:
                            self.action.send(ProductSelectorView.ProductAction.Selected(productId: product.id))
                            
                        default:
                            break
                        }
                        
                    }.store(in: &bindings)
            }
        }
        
        private func bindList() {
            
            if let listViewModel = listViewModel {
                
                listViewModel.action
                    .receive(on: DispatchQueue.main)
                    .sink { [unowned self] action in
                        
                        switch action {
                            
                        case let payload as ProductSelectorView.ProductAction.Selected:
                            
                            withAnimation { self.listViewModel = nil }
                            setProductSelectorData(productId: payload.productId)
                            
                        default:
                            break
                        }
                        
                    }.store(in: &bindings)
            }
        }
        
        private func makeProductsList() -> ProductsListView.ViewModel? {
            
            guard let productViewModel = productViewModel, let productData = model.product(productId: productViewModel.productId) else {
                return nil
            }
            
            let products = Self.reduce(model, currency: currency, currencyOperation: currencyOperation, productType: productData.productType)
            bind(products)
            
            let listViewModel: ProductsListView.ViewModel = .init(model, currencyOperation: currencyOperation, currency: currency, productType: productData.productType, products: products)
            
            return listViewModel
        }
        
        static func reduce(_ model: Model, currency: Currency, currencyOperation: CurrencyOperation, productType: ProductType) -> [ProductView.ViewModel] {
            
            let filterredProducts = model.products(currency: currency, currencyOperation: currencyOperation, productType: productType).sorted { $0.productType.order < $1.productType.order }
            
            let products = filterredProducts.map { ProductView.ViewModel(with: $0, size: .small, style: .main, model: model)}
            
            return products
        }
        
        private func setProductSelectorData(products: [ProductData], productId: ProductData.ID) {
            
            let productData = products.first(where: { $0.id == productId })
            
            guard let productData = productData else {
                return
            }
            
            self.productViewModel = .init(productId: productId, productData: productData, model: model)
        }
        
        func setProductSelectorData(productId: ProductData.ID) {
            
            let productData = model.products.value.values.flatMap { $0 }.first(where: { $0.id == productId })
            
            guard let productData = productData else {
                return
            }
            
            self.productViewModel = .init(productId: productId, productData: productData, model: model)
        }
        
        private func setProductSelectorData() {
            
            if let listViewModel = listViewModel,
               let optionSelector = listViewModel.optionSelector,
               let option = optionSelector.options.first {
                
                let productsData = model.products.value.values.flatMap { $0 }.filter { $0.productType.rawValue == option.id }.sorted { $0.productType.order < $1.productType.order }
                
                if let productData = productsData.first {
                    self.productViewModel = .init(productId: productData.id, productData: productData, model: model)
                }
                
            } else {
                
                let products = model.products(currency: currency, currencyOperation: currencyOperation).sorted { $0.productType.order < $1.productType.order }
                
                guard let productData = products.first else {
                    return
                }
                
                self.productViewModel = .init(productId: productData.id, productData: productData, model: model)
            }
        }
        
        private func updateProductViewModel() {
            
            guard let productViewModel = productViewModel else {
                return
            }
            
            let productData = model.products(currency: currency, currencyOperation: currencyOperation).filter { $0.id == productViewModel.productId }
            
            if productData.isEmpty == true {
                setProductSelectorData()
            }
        }
    }
}

extension ProductSelectorView.ViewModel {
    
    // MARK: - ProductContent
    
    class ProductContentViewModel: ObservableObject {
        
        @Published var cardIcon: Image?
        @Published var paymentSystemIcon: Image?
        @Published var name: String
        @Published var balance: String
        @Published var numberCard: String
        @Published var description: String?
        @Published var isCollapsed: Bool
        
        let productId: Int
        
        init(productId: Int, cardIcon: Image? = nil, paymentSystemIcon: Image? = nil, name: String, balance: String, numberCard: String, description: String? = nil, isCollapsed: Bool = true) {
            
            self.productId = productId
            self.cardIcon = cardIcon
            self.paymentSystemIcon = paymentSystemIcon
            self.name = name
            self.balance = balance
            self.numberCard = numberCard
            self.description = description
            self.isCollapsed = isCollapsed
        }
        
        convenience init(productId: Int, productData: ProductData, model: Model) {
            
            switch productData {
            case let product as ProductCardData:
                
                let numberCard = product.displayNumber ?? "XXXX"
                let name = ProductView.ViewModel.name(product: productData, style: .main)
                let description = product.additionalField
                let balance = ProductView.ViewModel.balanceFormatted(product: productData, style: .main, model: model)
                
                self.init(productId: productId, cardIcon: product.smallDesign.image, paymentSystemIcon: product.paymentSystemImage?.image, name: name, balance: balance, numberCard: numberCard, description: description)
                
            case let product as ProductAccountData:
                
                let numberCard = product.displayNumber ?? "XXXX"
                let balance = ProductView.ViewModel.balanceFormatted(product: productData, style: .main, model: model)
                
                self.init(productId: productId, cardIcon: product.smallDesign.image, paymentSystemIcon: nil, name: product.displayName, balance: balance, numberCard: numberCard, description: nil)
                
            default:
                
                // TODO: Implementation required
                
                let numberCard = productData.displayNumber ?? "XXXX"
                
                self.init(productId: productId, name: productData.displayName, balance: NumberFormatter.decimal(productData.balanceValue), numberCard: numberCard)
            }
        }
    }
    
    // MARK: - Divider
    
    class DividerViewModel: ObservableObject {
        
        @Published var pathInset: Double
        
        init(pathInset: Double = 5) {
            self.pathInset = pathInset
        }
    }
}

// MARK: - View

struct ProductSelectorView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 12) {
            
            ProductCardView(viewModel: viewModel)
            
            if let listViewModel = viewModel.listViewModel {
                
                ProductsListView(viewModel: listViewModel)
                    .padding(.top, 8)
                
            } else {
                
                if viewModel.isDividerHiddable == false {
                    
                    DividerView(viewModel: viewModel.dividerViewModel)
                }
            }
        }
        .disabled(viewModel.isUserInteractionEnabled == false)
        .background(viewModel.backgroundColor)
    }
}

extension ProductSelectorView {
    
    // MARK: - Action
    
    enum ProductAction {
    
        struct Toggle: Action {}
        
        struct Selected: Action {
            
            let productId: ProductData.ID
        }
    }
    
    // MARK: - ProductView
    
    struct ProductCardView : View {
        
        @ObservedObject var viewModel: ViewModel
        
        var body: some View {
            
            Group {
                
                Text(viewModel.title)
                    .font(.textBodySR12160())
                    .foregroundColor(.textPlaceholder)
                
                if let productViewModel = viewModel.productViewModel {
                    
                    ProductSelectorView.ProductContentView(viewModel: productViewModel)
                        .onTapGesture {
                            viewModel.action.send(ProductSelectorView.ProductAction.Toggle())
                        }
                    
                } else {
                    
                    HStack(alignment: .top, spacing: 16) {
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.mainColorsGrayMedium)
                            .frame(width: 32, height: 22)
                            .shimmering(active: true, bounce: false)
                        
                        VStack(alignment: .leading) {
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.mainColorsGrayMedium)
                                .frame(height: 12)
                                .shimmering(active: true, bounce: false)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.mainColorsGrayMedium)
                                .frame(width: 130, height: 8)
                                .shimmering(active: true, bounce: false)
                        }
                    }
                }
                
            }.padding(.horizontal, 20)
        }
    }
    
    // MARK: - ProductContent
    
    struct ProductContentView: View {
        
        @ObservedObject var viewModel: ViewModel.ProductContentViewModel
        
        var body: some View {
            
            HStack(alignment: .top, spacing: 16) {
                
                if let cardIcon = viewModel.cardIcon {
                    
                    cardIcon
                        .resizable()
                        .frame(width: 32, height: 32)
                        .offset(y: -3)
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    
                    HStack(alignment: .center, spacing: 10) {
                        
                        viewModel.paymentSystemIcon
                            .frame(width: 24, height: 24)
                        
                        Text(viewModel.name)
                            .font(.textBodyMM14200())
                            .foregroundColor(.textSecondary)
                        
                        Spacer()
                        
                        Text(viewModel.balance)
                            .font(.textBodyMM14200())
                            .foregroundColor(.textSecondary)
                        
                        Image.ic24ChevronDown
                            .renderingMode(.template)
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.mainColorsGray)
                            .rotationEffect(viewModel.isCollapsed == false ? .degrees(0) : .degrees(-90))
                    }
                    
                    HStack {
                        
                        if viewModel.numberCard.isEmpty == false {
                            
                            Circle()
                                .frame(width: 3, height: 3)
                                .foregroundColor(.mainColorsGray)
                            
                            Text(viewModel.numberCard)
                                .font(.textBodySR12160())
                                .foregroundColor(.mainColorsGray)
                            
                            Circle()
                                .frame(width: 3, height: 3)
                                .foregroundColor(.mainColorsGray)
                        }
                        
                        if let description = viewModel.description {
                            
                            Text(description)
                                .font(.textBodySR12160())
                                .foregroundColor(.mainColorsGray)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Divider
    
    struct DividerView: View {
        
        @ObservedObject var viewModel: ViewModel.DividerViewModel
  
        var body: some View {
            
            GeometryReader { proxy in
                
                Path { path in
                    
                    let height = proxy.size.height / 2
                    
                    path.move(to: .init(x: 0, y: height))
                    path.addLine(to: .init(x: 10, y: height))
                    path.addLine(to: .init(x: 16, y: height + viewModel.pathInset))
                    path.addLine(to: .init(x: 22, y: height))
                    path.addLine(to: .init(x: proxy.size.width, y: height))
                }
                .stroke()
                .foregroundColor(.mainColorsGrayMedium)
                
            }.padding(.horizontal, 20)
        }
    }
}

// MARK: - Preview Content

extension ProductSelectorView.ViewModel {
    
    static let sample1 = ProductSelectorViewModel(
        .emptyMock,
        title: "Откуда",
        currency: .rub,
        currencyOperation: .buy,
        productViewModel: .init(
            productId: 1,
            cardIcon: Image("Platinum Card"),
            paymentSystemIcon: Image("Platinum Logo"),
            name: "Platinum",
            balance: "2,71 млн ₽",
            numberCard: "2953",
            description: "Все включено"))
    
    static let sample2 = ProductSelectorViewModel(
        .emptyMock,
        title: "Откуда",
        currency: .rub,
        currencyOperation: .buy,
        productViewModel: .init(
            productId: 2,
            cardIcon: Image("Platinum Card"),
            paymentSystemIcon: Image("Platinum Logo"),
            name: "Platinum",
            balance: "2,71 млн ₽",
            numberCard: "2953",
            description: "Все включено"),
        listViewModel: .sample)
    
    static let sample3 = ProductSelectorViewModel(
        .emptyMock,
        title: "Куда",
        currency: .rub,
        currencyOperation: .sell,
        productViewModel: .init(
            productId: 3,
            cardIcon: Image("RUB Account"),
            paymentSystemIcon: nil,
            name: "Текущий счет",
            balance: "0 $",
            numberCard: "",
            description: "Валютный"),
        isDividerHiddable: true)
}

// MARK: - Previews

struct ProductSelectorViewComponent_Previews: PreviewProvider {
    static var previews: some View {
        
        Group {
            
            ProductSelectorView(viewModel: .sample1)
                .previewLayout(.sizeThatFits)
                .fixedSize()
            
            ProductSelectorView(viewModel: .sample2)
                .previewLayout(.sizeThatFits)
            
            ProductSelectorView(viewModel: .sample3)
                .previewLayout(.sizeThatFits)
        }
        .padding(.vertical)
        .background(Color.mainColorsGrayLightest)
    }
}
