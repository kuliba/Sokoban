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
    
    class ViewModel: ObservableObject {
        
        let action: PassthroughSubject<Action, Never> = .init()
        
        @Published var productViewModel: ProductViewModel?
        @Published var placeholderViewModel: PlaceholderViewModel?
        @Published var listViewModel: ProductsListView.ViewModel?
        @Published var context: Context
        
        let id: UUID = .init()
        
        private let model: Model
        private var bindings = Set<AnyCancellable>()
        
        init(model: Model, productViewModel: ProductViewModel?, placeholderViewModel: PlaceholderViewModel?, listViewModel: ProductsListView.ViewModel?, context: Context) {
            
            self.model = model
            self.productViewModel = productViewModel
            self.placeholderViewModel = placeholderViewModel
            self.listViewModel = listViewModel
            self.context = context
        }
        
        convenience init(model: Model, productViewModel: ProductViewModel, context: Context) {
            
            self.init(model: model,
                      productViewModel: productViewModel,
                      placeholderViewModel: nil,
                      listViewModel: nil,
                      context: context)
            
            bindProduct()
        }
        
        convenience init(model: Model, context: Context) {
            
            let placeholderViewModel: PlaceholderViewModel = .init()
            
            self.init(model: model,
                      productViewModel: nil,
                      placeholderViewModel: placeholderViewModel,
                      listViewModel: nil,
                      context: context)
            
            bindPlaceholder()
        }
        
        private func bindProduct() {
            
            guard let productViewModel = productViewModel else {
                return
            }

            productViewModel.$isCollapsed
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] isCollapsed in
                    
                    withAnimation {
                        
                        switch isCollapsed {
                        case true: listViewModel = nil
                        case false:
                            listViewModel = Self.makeList(model, context: context)
                            bindList()
                        }
                    }
                    
                }.store(in: &bindings)
        }
        
        private func bindList() {
            
            if let listViewModel = listViewModel {
                
                listViewModel.action
                    .receive(on: DispatchQueue.main)
                    .sink { [unowned self] action in
                        
                        switch action {
                            
                        case let payload as ProductsListAction.SelectedProduct:
                            
                            if let product = model.product(productId: payload.id) {
                                productViewModel = Self.makeProduct(model, productData: product)
                            }
                            
                        default:
                            break
                        }
                        
                    }.store(in: &bindings)
            }
        }
        
        private func bindPlaceholder() {
            
            guard let placeholderViewModel = placeholderViewModel else {
                return
            }

            placeholderViewModel.$isCollapsed
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] isCollapsed in
                    
                    withAnimation {
                        
                        switch isCollapsed {
                        case true: listViewModel = nil
                        case false:
                            listViewModel = Self.makeList(model, context: context)
                            bindList()
                        }
                    }
                    
                }.store(in: &bindings)
        }
    }
}

extension ProductSelectorView.ViewModel {
    
    // MARK: - Context
    
    struct Context {
        
        let title: String
        let currency: Currency
        let direction: Direction
        let products: [ProductData]?
        let productType: ProductType
        let excludeTypes: [ProductType]?
        let selectedProductId: ProductData.ID?
        let excludeProductId: ProductData.ID?
        let titleIndent: TitleIndent
        let isDividerHiddable: Bool
        let isAdditionalProducts: Bool
        let isUserInteractionEnabled: Bool
        
        init(title: String, currency: Currency = .rub, direction: Direction = .from, products: [ProductData]? = nil, productType: ProductType = .card, excludeTypes: [ProductType]? = nil, selectedProductId: ProductData.ID? = nil, excludeProductId: ProductData.ID? = nil, titleIndent: TitleIndent = .normal, isDividerHiddable: Bool = false,  isAdditionalProducts: Bool = false, isUserInteractionEnabled: Bool = true) {
            
            self.title = title
            self.currency = currency
            self.direction = direction
            self.products = products
            self.productType = productType
            self.excludeTypes = excludeTypes
            self.selectedProductId = selectedProductId
            self.excludeProductId = excludeProductId
            self.titleIndent = titleIndent
            self.isDividerHiddable = isDividerHiddable
            self.isAdditionalProducts = isAdditionalProducts
            self.isUserInteractionEnabled = isUserInteractionEnabled
        }
        
        enum Direction {
            
            case from
            case to
        }
        
        enum TitleIndent {
            
            case normal
            case left
        }
    }
    
    // MARK: - Product
    
    class ProductViewModel: ObservableObject {
        
        @Published var id: Int
        @Published var cardIcon: Image?
        @Published var paymentIcon: Image?
        @Published var name: String
        @Published var balance: String
        @Published var numberCard: String?
        @Published var description: String?
        @Published var isCollapsed: Bool
        
        init(id: Int, cardIcon: Image? = nil, paymentIcon: Image? = nil, name: String, balance: String, numberCard: String? = nil, description: String? = nil, isCollapsed: Bool = true) {
            
            self.id = id
            self.cardIcon = cardIcon
            self.paymentIcon = paymentIcon
            self.name = name
            self.balance = balance
            self.numberCard = numberCard
            self.description = description
            self.isCollapsed = isCollapsed
        }
    }
    
    // MARK: - Placeholder
    
    class PlaceholderViewModel: ObservableObject {
        
        @Published var isCollapsed: Bool
        let description: String
        
        init(description: String = "Номер карты или счета", isCollapsed: Bool = true) {
            
            self.description = description
            self.isCollapsed = isCollapsed
        }
    }
}

extension ProductSelectorView.ViewModel {
    
    static func makeProduct(_ model: Model, productData: ProductData) -> ProductViewModel {
        
        let name = ProductView.ViewModel.name(product: productData, style: .main)
        let balance = ProductView.ViewModel.balanceFormatted(product: productData, style: .main, model: model)
        
        var paymentSystemImage: SVGImageData?
        
        if let product = productData as? ProductCardData {
            paymentSystemImage = product.paymentSystemImage
        }
  
        let productViewModel: ProductViewModel = .init(id: productData.id, cardIcon: productData.smallDesign.image, paymentIcon: paymentSystemImage?.image, name: name, balance: balance, numberCard: productData.displayNumber, description: productData.additionalField)
        
        return productViewModel
    }
    
    static func makeList(_ model: Model, context: Context) -> ProductsListView.ViewModel? {
        
        guard let products = context.products else {
            return nil
        }
        
        return .init(model: model, products: products, productType: context.productType)
    }
}

// MARK: - View

struct ProductSelectorView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 14) {
            
            Text(viewModel.context.title)
                .font(.textBodySR12160())
                .foregroundColor(.mainColorsBlack)
            
            if let productViewModel = viewModel.productViewModel {
                ProductView(viewModel: productViewModel)
            } else if let placeholderViewModel = viewModel.placeholderViewModel {
                ProductPlaceholderView(viewModel: placeholderViewModel)
            }
            
            if let listViewModel = viewModel.listViewModel {
                ProductsListView(viewModel: listViewModel)
            }
        }
    }
}

extension ProductSelectorView {
    
    // MARK: - Product
    
    struct ProductView: View {
        
        @ObservedObject var viewModel: ViewModel.ProductViewModel
        
        var body: some View {
            
            HStack(alignment: .top, spacing: 16) {
                
                if let cardIcon = viewModel.cardIcon {
                    
                    cardIcon
                        .resizable()
                        .frame(width: 32, height: 32)
                        .offset(y: -3)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    
                    HStack(alignment: .center, spacing: 10) {
                        
                        if let paymentIcon = viewModel.paymentIcon {
                            
                            paymentIcon
                                .resizable()
                                .frame(width: 24, height: 24)
                        }
                        
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
                        
                        if let numberCard = viewModel.numberCard {
                            
                            Circle()
                                .frame(width: 3, height: 3)
                                .foregroundColor(.mainColorsGray)
                            
                            Text(numberCard)
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
                    
                }.onTapGesture {
                    
                    withAnimation {
                        
                        viewModel.isCollapsed.toggle()
                    }
                }
            }
        }
    }
    
    // MARK: - Placeholder
    
    struct ProductPlaceholderView: View {
        
        @ObservedObject var viewModel: ViewModel.PlaceholderViewModel
        
        var body: some View {
            
            HStack {

                Text(viewModel.description)
                    .font(.textBodyMR14200())
                    .foregroundColor(.mainColorsGray)
                
                Spacer()
                
                Image.ic24ChevronDown
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.mainColorsGray)
                    .rotationEffect(viewModel.isCollapsed == false ? .degrees(0) : .degrees(-90))
            
            }.onTapGesture {
                
                withAnimation {
                    
                    viewModel.isCollapsed.toggle()
                }
            }
        }
    }
}

// MARK: - Action

enum ProductSelectorAction {
    
    struct Selected: Action {
        
        let id: ProductData.ID
    }
}

extension ProductSelectorView.ViewModel.ProductViewModel {
    
    static let sample: ProductSelectorView.ViewModel.ProductViewModel = .init(
        id: 10002585800,
        cardIcon: .init("Platinum Card"),
        paymentIcon: .init("Platinum Logo"),
        name: "Platinum",
        balance: "2,71 млн ₽",
        numberCard: "2953",
        description: "Все включено")
}

// MARK: - Previews

struct ProductSelectorView_Previews: PreviewProvider {
    
    static var previews: some View {

        Group {

            ProductSelectorView(viewModel: .sample1)
            ProductSelectorView(viewModel: .sample2)
            ProductSelectorView(viewModel: .sample3)
            ProductSelectorView(viewModel: .sample4)
        }
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
