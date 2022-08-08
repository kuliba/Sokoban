//
//  ProductsListViewComponent.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 11.07.2022.
//

import SwiftUI
import Combine

typealias ProductSelectorViewModel = ProductSelectorView.ViewModel

// MARK: - ViewModel

extension ProductSelectorView {

    class ViewModel: ObservableObject {
        
        let action: PassthroughSubject<Action, Never> = .init()
        
        @Published var title: String
        @Published var currency: Currency
        @Published var isDividerHiddable: Bool
        @Published var productViewModel: ProductContentViewModel
        @Published var listViewModel: ProductsListView.ViewModel?
        
        var bindings = Set<AnyCancellable>()
        
        lazy var dividerViewModel: DividerViewModel = .init()
        
        private let model: Model
        
        init(_ model: Model,
             title: String,
             currency: Currency,
             productViewModel: ProductContentViewModel,
             listViewModel: ProductsListView.ViewModel? = nil,
             isDividerHiddable: Bool = false) {
            
            self.model = model
            self.title = title
            self.currency = currency
            self.productViewModel = productViewModel
            self.listViewModel = listViewModel
            self.isDividerHiddable = isDividerHiddable
            
            bind()
        }
        
        convenience init(
            _ model: Model,
            currency: Currency,
            productViewModel: ProductContentViewModel,
            listViewModel: ProductsListView.ViewModel? = nil,
            isDividerHiddable: Bool = false) {
            
                self.init(model, title: "", currency: currency, productViewModel: productViewModel, listViewModel: listViewModel, isDividerHiddable: isDividerHiddable)
        }
        
        private func bind() {
            
            model.products
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] productsData in
                    
                    setProductSelectorData(products: productsData, productId: productViewModel.productId)
                    
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
                        productViewModel.isCollapsed = listViewModel == nil ? true : false
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
            
            let productData = model.product(productId: productViewModel.productId)
            
            guard let productData = productData else {
                return nil
            }
            
            let products = Self.reduce(model, currency: currency, productType: productData.productType) {
                self.action.send(ProductSelectorView.ProductAction.Selected(productId: $0))
            }
            
            let listViewModel: ProductsListView.ViewModel = .init(model, currency: currency, productType: productData.productType, products: products)
            
            return listViewModel
        }
        
        static func reduce(_ model: Model, currency: Currency, productType: ProductType, action: @escaping (ProductData.ID) -> Void) -> [ProductView.ViewModel] {
            
            let filterredProducts = model.products(currency: currency, productType: productType)
            
            let products = filterredProducts.map { productData in
                ProductView.ViewModel(with: productData, size: .small, style: .main, model: model) {
                    action(productData.id)
                }
            }
            
            return products
        }
        
        private func setProductSelectorData(products: ProductsData, productId: ProductData.ID) {
            
            let productData = products.values.flatMap { $0 }.first(where: { $0.id == productId })
            
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
                let description = ProductView.ViewModel.name(product: productData, style: .main)
                
                let balance = ProductView.ViewModel.balanceFormatted(product: productData, style: .main, model: model)
                
                self.init(productId: productId, cardIcon: product.smallDesign.image, paymentSystemIcon: product.paymentSystemImage?.image, name: product.displayName, balance: balance, numberCard: numberCard, description: description)
                
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
        }.background(Color.mainColorsGrayLightest)
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
                
                ProductSelectorView.ProductContentView(viewModel: viewModel.productViewModel)
                    .onTapGesture {
                        viewModel.action.send(ProductSelectorView.ProductAction.Toggle())
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
    
    static let sample1 = ProductSelectorView.ViewModel(
        .emptyMock,
        title: "Откуда",
        currency: .rub,
        productViewModel: .init(
            productId: 1,
            cardIcon: Image("Platinum Card"),
            paymentSystemIcon: Image("Platinum Logo"),
            name: "Platinum",
            balance: "2,71 млн ₽",
            numberCard: "2953",
            description: "Все включено"))
    
    static let sample2 = ProductSelectorView.ViewModel(
        .emptyMock,
        title: "Откуда",
        currency: .rub,
        productViewModel: .init(
            productId: 2,
            cardIcon: Image("Platinum Card"),
            paymentSystemIcon: Image("Platinum Logo"),
            name: "Platinum",
            balance: "2,71 млн ₽",
            numberCard: "2953",
            description: "Все включено"),
        listViewModel: .sample)
    
    static let sample3 = ProductSelectorView.ViewModel(
        .emptyMock,
        title: "Куда",
        currency: .usd,
        productViewModel: .init(
            productId: 3,
            cardIcon: Image("Platinum Card"),
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
        .background(Color.mainColorsGrayLightest)
        .padding(.vertical)
    }
}
