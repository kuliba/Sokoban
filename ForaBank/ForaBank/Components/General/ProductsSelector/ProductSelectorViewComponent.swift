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
        
        var productViewModel: ProductViewModel? {
            
            guard case let .product(productViewModel) = content else {
                return nil
            }
            
            return productViewModel
        }
        
        var selectedProductId: ProductData.ID? { productViewModel?.id }
        
        init(_ model: Model, content: Content, listViewModel: ProductsListView.ViewModel?, context: Context) {
            
            self.model = model
            self.content = content
            self.list = listViewModel
            self.context = .init(context)
        }
        
        convenience init(_ model: Model, productData: ProductData, context: Context, isListOpen: Bool = false) {
            
            let productViewModel: ProductViewModel = .init(model, productData: productData, context: context)

            if isListOpen == false {
                
                self.init(model, content: .product(productViewModel), listViewModel: nil, context: context)
                
            } else {
                
                let list = ProductsListView.ViewModel(selectedProductId: productData.id, filter: context.filter, model: model)
                self.init(model, content: .product(productViewModel), listViewModel: list, context: context)
            }
            
            bind()
            bind(list: list)
        }
        
        convenience init(_ model: Model, context: Context) {
            
            self.init(model, content: .placeholder(.init(context)), listViewModel: nil, context: context)
            bind()
        }
        
        convenience init(_ model: Model, parameterProduct: Payments.ParameterProduct) {
            
            let context = Context(title: parameterProduct.title, direction: .from, style: .regular, filter: parameterProduct.filter)
            
            if let productId = parameterProduct.productId,
               let productData = model.product(productId: productId) {
                
                self.init(model, productData: productData, context: context)
                
            } else {
                
                self.init(model, context: context)
            }
        }
        
        private func bind() {
            
            action
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] action in
                    
                    switch action {
                    case _ as ProductSelectorAction.Product.Tap:
                        
                        if list == nil {
         
                            withAnimation {
                                
                                self.list = ProductsListView.ViewModel(selectedProductId: selectedProductId, filter: context.value.filter, model: model)
                            }
                            
                            bind(list: list)
                            
                        } else {
                            
                            collapseList()
                        }
                        
                    default:
                        break
                    }
                    
                }.store(in: &bindings)
            
            context
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] context in
                    
                    // Update content
                    switch content {
                    case let .product(productViewModel):
                        productViewModel.update(context: context)
                        
                    case let .placeholder(placeholderViewModel):
                        placeholderViewModel.update(context: context)
                    }
                    
                }.store(in: &bindings)
        }
        
        func bind(list: ProductsListView.ViewModel?) {
            
            list?.action
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] action in
                    
                    switch action {
                    case let payload as ProductsListViewModelAction.Product.Tap:
                        
                        if let product = model.product(productId: payload.id) {

                            let productViewModel: ProductViewModel = .init(
                                model,
                                productData: product,
                                context: context.value)

                            content = .product(productViewModel)
                            collapseList()
                            
                            self.action.send(ProductSelectorAction.Selected(id: product.id))
                        }
                        
                    case _ as ProductsListViewModelAction.CloseList:
                        collapseList()
                        
                    default:
                        break
                    }
                    
                }.store(in: &bindings)
            
            $list
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] list in

                    withAnimation {

                        switch content {
                        case let .product(productViewModel):
                            productViewModel.isCollapsed = list == nil
                            
                        case let .placeholder(placeholderViewModel):
                            placeholderViewModel.isCollapsed = list == nil
                        }
                    }

                }.store(in: &bindings)
        }
        
        func collapseList() {

            withAnimation {
                list = nil
            }
        }
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
            
            let name = ProductView.ViewModel.name(product: productData, style: .main)
            let balance = ProductView.ViewModel.balanceFormatted(product: productData, style: .main, model: model)
            
            var paymentSystemImage: SVGImageData?
            
            if let product = productData as? ProductCardData {
                paymentSystemImage = product.paymentSystemImage
            }
            
            self.init(id: productData.id, title: context.title, cardIcon: productData.smallDesign.image, paymentIcon: paymentSystemImage?.image, name: name, balance: balance, numberCard: productData.displayNumber, description: productData.additionalField, isUserInteractionEnabled: context.isUserInteractionEnabled, style: context.style)
        }
        
        func update(context: ProductSelectorView.ViewModel.Context) {
            title = context.title
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
        
        VStack(alignment: .leading, spacing: 12) {

            switch viewModel.content {
            case let .product(productViewModel):
                ProductView(viewModel: productViewModel)
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
            
            VStack(alignment: .leading, spacing: 0) {
                
                switch viewModel.style {
                case .regular:
                    Text(viewModel.title)
                        .font(.textBodySR12160())
                        .foregroundColor(.textPlaceholder)
                        .padding(.leading, 48)
                        .padding(.bottom, 4)
                    
                case .me2me:
                    Text(viewModel.title)
                        .font(.textBodySR12160())
                        .foregroundColor(.mainColorsBlack)
                        .padding(.bottom, 12)
                }

                HStack(alignment: .top, spacing: 16) {
                    
                    if let cardIcon = viewModel.cardIcon {
                        
                        cardIcon
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 32, height: 22)
             
                    } else {
                        
                        RoundedRectangle(cornerRadius: 3)
                            .foregroundColor(.mainColorsGrayLightest)
                            .frame(width: 32, height: 22)
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
                            
                            if viewModel.isUserInteractionEnabled == true {
                                
                                Image.ic24ChevronDown
                                    .renderingMode(.template)
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(.mainColorsGray)
                                    .rotationEffect(viewModel.isCollapsed == false ? .degrees(0) : .degrees(-90))
                            }
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
                    }
                }
            }
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
                    
                    Image.ic24ChevronDown
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.mainColorsGray)
                        .rotationEffect(viewModel.isCollapsed == false ? .degrees(0) : .degrees(-90))
                }
            }
        }
    }
}

// MARK: - Previews

struct ProductSelectorView_Previews: PreviewProvider {
    
    static var previews: some View {

        Group {

            ProductSelectorView(viewModel: .sampleRegularCollapsed)
            ProductSelectorView(viewModel: .sampleMe2MeCollapsed)
            ProductSelectorView(viewModel: .sample2)
            ProductSelectorView(viewModel: .sample3)
        }
        .previewLayout(.sizeThatFits)
        .padding()
    }
}

// MARK: - Preview Content

extension ProductSelectorView.ViewModel.ProductViewModel {
    
    static let sample1: ProductSelectorView.ViewModel.ProductViewModel = .init(
        id: 10002585801,
        title: "Откуда",
        cardIcon: .init("Platinum Card"),
        paymentIcon: .init("Platinum Logo"),
        name: "Platinum",
        balance: "2,71 млн ₽",
        numberCard: "2953",
        description: "Все включено",
        style: .me2me)
    
    static let sample2: ProductSelectorView.ViewModel.ProductViewModel = .init(
        id: 10002585802,
        title: "Куда",
        cardIcon: .init("Platinum Card"),
        paymentIcon: .init("Platinum Logo"),
        name: "Platinum",
        balance: "2,71 млн ₽",
        numberCard: "2953",
        description: "Все включено",
        style: .me2me)
    
    static let sampleRegular: ProductSelectorView.ViewModel.ProductViewModel = .init(
        id: 10002585801,
        title: "Счет списания",
        cardIcon: .init("Platinum Card"),
        paymentIcon: .init("Platinum Logo"),
        name: "Platinum",
        balance: "2,71 млн ₽",
        numberCard: "2953",
        description: "Все включено",
        style: .regular)
}
