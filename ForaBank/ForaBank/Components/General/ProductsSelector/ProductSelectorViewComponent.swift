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
        @Published var list: ProductsListView.ViewModel?
        
        let id: UUID = .init()
        let context: CurrentValueSubject<Context, Never>
        
        private let model: Model
        private var bindings = Set<AnyCancellable>()
        
        enum Content {
            
            case product(ProductViewModel)
            case placeholder(PlaceholderViewModel)
        }
        
        init(_ model: Model, content: Content, listViewModel: ProductsListView.ViewModel?, context: Context) {
            
            self.model = model
            self.content = content
            self.list = listViewModel
            self.context = .init(context)
        }
        
        convenience init(_ model: Model, productData: ProductData, context: Context) {
            
            let productViewModel = Self.makeProduct(model, productData: productData)
            self.init(model, content: .product(productViewModel), listViewModel: nil, context: context)
            
            bind()
        }
        
        convenience init(_ model: Model, context: Context) {
            
            self.init(model, content: .placeholder(.init()), listViewModel: nil, context: context)
            bind()
        }
        
        private func bind() {
            
            $content
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] content in
                    
                    switch content {
                    case let .product(productViewModel):
                        
                        productViewModel.action
                            .receive(on: DispatchQueue.main)
                            .sink { [unowned self] action in
                                
                                switch action {
                                case _ as ProductSelectorAction.Collapsed.Product:
                                    
                                    withAnimation {
                                        
                                        switch list == nil {
                                        case true:
                                            
                                            list = Self.makeList(model, context: context.value)
                                            bindList()
                                            
                                        case false: list = nil
                                        }
                                    }
                                    
                                default:
                                    break
                                }
                                
                            }.store(in: &bindings)
                        
                    case let .placeholder(placeholderViewModel):
                        
                        placeholderViewModel.action
                            .receive(on: DispatchQueue.main)
                            .sink { [unowned self] action in
                                
                                switch action {
                                case _ as ProductSelectorAction.Collapsed.Placeholder:
                                    
                                    withAnimation {
                                        
                                        switch list == nil {
                                        case true:
                                            
                                            list = Self.makeList(model, context: context.value)
                                            bindList()
                                            
                                        case false: list = nil
                                        }
                                    }
                                    
                                default:
                                    break
                                }
                                
                            }.store(in: &bindings)
                    }
                    
                }.store(in: &bindings)
        }
        
        private func bindList() {
            
            if let list = list {
                
                list.action
                    .receive(on: DispatchQueue.main)
                    .sink { [unowned self] action in
                        
                        switch action {
                            
                        case let payload as ProductsListAction.SelectedProduct:
                            
                            if let product = model.product(productId: payload.id) {
                                
                                let productViewModel = Self.makeProduct(model, productData: product)
                                content = .product(productViewModel)
                            }
                            
                        default:
                            break
                        }
                        
                    }.store(in: &bindings)
                
                $list
                    .receive(on: DispatchQueue.main)
                    .sink { [unowned self] list in
                        
                        let isCollapsed = list == nil
                        
                        withAnimation {
                            
                            switch content {
                            case let .product(productViewModel):
                                productViewModel.isCollapsed = isCollapsed
                            case let .placeholder(placeholderViewModel):
                                placeholderViewModel.isCollapsed = isCollapsed
                            }
                        }
                        
                    }.store(in: &bindings)
            }
        }
        
        private func bindContext() {
            
            context
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] context in
                    
                    switch content {
                    case let .product(productViewModel):
                        productViewModel.update(context: context)
                    case .placeholder:
                        break
                    }
                    
                    list?.update(context: context)
                    
                }.store(in: &bindings)
        }
    }
}

// MARK: - Make

extension ProductSelectorView.ViewModel {
    
    static func makeProduct(_ model: Model, productData: ProductData) -> ProductViewModel {
        
        let name = ProductView.ViewModel.name(product: productData, style: .main)
        let balance = ProductView.ViewModel.balanceFormatted(product: productData, style: .main, model: model)
        
        var paymentSystemImage: SVGImageData?
        
        if let product = productData as? ProductCardData {
            paymentSystemImage = product.paymentSystemImage
        }
  
        return .init(id: productData.id, cardIcon: productData.smallDesign.image, paymentIcon: paymentSystemImage?.image, name: name, balance: balance, numberCard: productData.displayNumber, description: productData.additionalField)
    }
    
    static func makeList(_ model: Model, context: Context) -> ProductsListView.ViewModel? {
        .init(model: model, context: context)
    }
}

extension ProductSelectorView.ViewModel {
    
    // MARK: - Context
    
    struct Context {
        
        // Product
        var title: String
        var direction: Direction
        var titleIndent: TitleIndent = .normal
        var isUserInteractionEnabled: Bool = true
        
        // ProductsList
        var excludeTypes: [ProductType]?
        var excludeProductId: ProductData.ID?
        var isAdditionalProducts: Bool = false
        
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
        
        let action: PassthroughSubject<Action, Never> = .init()
        
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
        
        func update(context: Context) {}
    }
    
    // MARK: - Placeholder
    
    class PlaceholderViewModel: ObservableObject {
        
        let action: PassthroughSubject<Action, Never> = .init()
        
        @Published var isCollapsed: Bool
        let description: String
        
        init(description: String = "Номер карты или счета", isCollapsed: Bool = true) {
            
            self.description = description
            self.isCollapsed = isCollapsed
        }
    }
}

// MARK: - View

struct ProductSelectorView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 14) {
            
            Text(viewModel.context.value.title)
                .font(.textBodySR12160())
                .foregroundColor(.mainColorsBlack)
            
            switch viewModel.content {
            case let .product(productViewModel):
                ProductView(viewModel: productViewModel)
            case let .placeholder(placeholderViewModel):
                ProductPlaceholderView(viewModel: placeholderViewModel)
            }
            
            if let listViewModel = viewModel.list {
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
                        
                        viewModel.action.send(ProductSelectorAction.Collapsed.Product())
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
                    
                    viewModel.action.send(ProductSelectorAction.Collapsed.Placeholder())
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
    
    enum Collapsed {

        struct Product: Action {}
        
        struct Placeholder: Action {}
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
        }
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
