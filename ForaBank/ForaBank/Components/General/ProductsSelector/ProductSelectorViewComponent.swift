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
        
        @Published var cardIcon: Image?
        @Published var paymentSystemIcon: Image?
        @Published var name: String
        @Published var balance: String
        @Published var number: NumberViewModel
        
        @Published var listViewModel: ProductsListView.ViewModel?
        
        var bindings = Set<AnyCancellable>()
        
        private let model: Model
        private let productType: ProductType
        let title: String
        let isDividerHiddable: Bool
        
        init(_ model: Model,
             title: String,
             cardIcon: Image?,
             paymentSystemIcon: Image?,
             name: String,
             balance: String,
             number: NumberViewModel,
             productType: ProductType = .card,
             listViewModel: ProductsListView.ViewModel? = nil,
             isDividerHiddable: Bool = false) {
            
            self.model = model
            self.title = title
            self.cardIcon = cardIcon
            self.paymentSystemIcon = paymentSystemIcon
            self.name = name
            self.balance = balance
            self.number = number
            self.productType = productType
            self.listViewModel = listViewModel
            self.isDividerHiddable = isDividerHiddable
            
            bind()
        }
        
        private func bind() {
            
            action
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] action in
                    
                    switch action {
                        
                    case _ as ProductSelectorView.ProductAction.Toggle:
                        
                        withAnimation {
                            
                            switch listViewModel == nil {
                            case true: listViewModel = makeProductsList()
                            case false: listViewModel = nil
                            }
                        }
                        
                    case let payload as ProductSelectorView.ProductAction.Selected:
                        
                        withAnimation { listViewModel = nil }
                        setProductDataWith(productId: payload.productId, productType: productType)
                        
                    default:
                        break
                    }
                    
                }.store(in: &bindings)
        }
        
        private func makeProductsList() -> ProductsListView.ViewModel? {
 
            switch productType {
            case .card:
                
                return Self.makeProductsCardList(model) {
                    self.action.send(ProductSelectorView.ProductAction.Selected(productId: $0))
                }
                
            case .account:
                
                return Self.makeProductsAccountList(model) {
                    self.action.send(ProductSelectorView.ProductAction.Selected(productId: $0))
                }
                
            case .deposit: return nil
            case .loan: return nil
            }
        }
        
        private func setProductDataWith(productId: ProductData.ID, productType: ProductType) {
            
            let product = model.products.value.values.flatMap { $0 }.first(where: { $0.id == productId })
            
            switch productType {
            case .card:
                
                guard let product = product as? ProductCardData,
                      let numberCard = product.number,
                      let description = product.additionalField else {
                    return
                }
                
                cardIcon = product.smallDesign.image
                paymentSystemIcon = product.paymentSystemImage?.image
                name = product.displayName
                balance = NumberFormatter.decimal(product.balanceValue)
                number = .init(numberCard: numberCard, description: description)
                
            case .account:
                
                guard let product = product as? ProductAccountData,
                      let numberCard = product.number else {
                    return
                }
                
                cardIcon = product.smallDesign.image
                name = product.displayName
                balance = NumberFormatter.decimal(product.balanceValue)
                number = .init(numberCard: numberCard)
                
            case .deposit: break
            case .loan: break
            }
        }
        
        static func makeProductsCardList(_ model: Model, action: @escaping (ProductData.ID) -> Void) -> ProductsListView.ViewModel? {
            
            guard let productCards = model.products.value[.card] else {
                return nil
            }
            
            let products = productCards.compactMap { productData -> ProductView.ViewModel? in
                
                guard let productCard = productData as? ProductCardData else {
                    return nil
                }
                
                return ProductView.ViewModel(with: productCard, size: .small, style: .main, model: model) { action(productCard.id)
                }
            }
            
            return .init(products: products)
        }
        
        static func makeProductsAccountList(_ model: Model, action: @escaping (ProductData.ID) -> Void) -> ProductsListView.ViewModel? {
            
            guard let productCards = model.products.value[.account] else {
                return nil
            }
            
            let products = productCards.compactMap { productData -> ProductView.ViewModel? in
                
                guard let productCard = productData as? ProductAccountData else {
                    return nil
                }
                
                return ProductView.ViewModel(with: productCard, size: .small, style: .main, model: model) {
                    action(productCard.id)
                }
            }
            
            return .init(products: products)
        }
    }
}

extension ProductSelectorView.ViewModel {
    
    // MARK: - NumberCard
    
    class NumberViewModel: ObservableObject {
        
        let numberCard: String
        let description: String?
        
        var numberCardLast: String {
            "\(numberCard.suffix(4))"
        }
        
        init(numberCard: String, description: String? = nil) {
            
            self.numberCard = numberCard
            self.description = description
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
                    .padding(.top)
                
            } else {
                
                if viewModel.isDividerHiddable == false {
                    
                    Divider()
                        .padding(.top, 2)
                        .padding(.horizontal, 20)
                }
            }
        }.background(Color.mainColorsGrayLightest)
    }
}

extension ProductSelectorView {
    
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
                                .rotationEffect(viewModel.listViewModel == nil ? .degrees(0) : .degrees(-90))
                        }
                        
                        HStack {
                            ProductSelectorView.NumberCardView(viewModel: viewModel.number)
                        }
                    }
                }.onTapGesture {
                    
                    viewModel.action.send(ProductSelectorView.ProductAction.Toggle())
                }
            }.padding(.horizontal, 20)
        }
    }
    
    // MARK: - NumberCard
    
    struct NumberCardView: View {
        
        @ObservedObject var viewModel: ViewModel.NumberViewModel
        
        var body: some View {
            
            HStack {
                
                if viewModel.numberCard.isEmpty == false {
                    
                    Circle()
                        .frame(width: 3, height: 3)
                        .foregroundColor(.mainColorsGray)
                    
                    Text(viewModel.numberCardLast)
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

// MARK: - Preview Content

extension ProductSelectorView.ViewModel {
    
    static let sample1 = ProductSelectorView.ViewModel(
        .emptyMock,
        title: "Откуда",
        cardIcon: Image("Platinum Card"),
        paymentSystemIcon: Image("Platinum Logo"),
        name: "Platinum",
        balance: "2,71 млн ₽",
        number: .init(
            numberCard: "4444555566662953",
            description: "Все включено"),
        listViewModel: nil)
    
    static let sample2 = ProductSelectorView.ViewModel(
        .emptyMock,
        title: "Откуда",
        cardIcon: Image("Platinum Card"),
        paymentSystemIcon: Image("Platinum Logo"),
        name: "Platinum",
        balance: "2,71 млн ₽",
        number: .init(
            numberCard: "4444555566662953",
            description: "Все включено"),
        listViewModel: .sample)
    
    static let sample3 = ProductSelectorView.ViewModel(
        .emptyMock,
        title: "Куда",
        cardIcon: Image("Platinum Card"),
        paymentSystemIcon: nil,
        name: "Текущий счет",
        balance: "0 $",
        number: .init(
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
                .padding()
            
            ProductSelectorView(viewModel: .sample2)
                .previewLayout(.sizeThatFits)
                .padding()
            
            ProductSelectorView(viewModel: .sample3)
                .previewLayout(.sizeThatFits)
                .padding()
            
        }.background(Color.mainColorsGrayLightest)
    }
}
