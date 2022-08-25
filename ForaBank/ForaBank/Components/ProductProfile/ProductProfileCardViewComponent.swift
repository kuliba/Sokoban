//
//  ProductProfileCardView.swift
//  ForaBank
//
//  Created by Дмитрий on 24.02.2022.
//

import SwiftUI
import Combine

//MARK: - ViewModel

extension ProductProfileCardView {
    
    class ViewModel: ObservableObject {
        
        let action: PassthroughSubject<Action, Never> = .init()
        
        @Published var selector: SelectorViewModel
        @Published var products: [ProductView.ViewModel]
        @Published var activeProductId: ProductData.ID
        
        let productType: ProductType
        
        private let model: Model
        private var bindings = Set<AnyCancellable>()
        
        init(selector: SelectorViewModel, products: [ProductView.ViewModel], activeProductId: ProductData.ID, productType: ProductType, model: Model = .emptyMock) {
 
            self.selector = selector
            self.products = products
            self.activeProductId = activeProductId
            self.productType = productType
            self.model = model
        }
        
        init?(_ model: Model, productData: ProductData) {
            
            // fetch app products of type
            guard let productsForType = model.products.value[productData.productType],
                  productsForType.isEmpty == false,
                  productsForType.contains(where: { $0.id == productData.id }) else {
                
                return nil
            }
            
            // generate products view models
            let productsWithRelated = Self.reduce(products: productsForType, with: model.products.value)
            var productsViewModels = [ProductView.ViewModel]()
            for product in productsWithRelated {
                
                let productViewModel = ProductView.ViewModel(with: product, size: .large, style: .profile, model: model)
                productsViewModels.append(productViewModel)
            }
            
            // check if generated products view models list is not empty
            guard productsViewModels.isEmpty == false else {
                return nil
            }
            
            // filter products data with products view models
            let productsViewModelsIds = productsViewModels.map{ $0.id }
            let productsForTypeDisplayed = productsWithRelated.filter({ productsViewModelsIds.contains($0.id)})
            
            self.selector = SelectorViewModel(with: productsForTypeDisplayed, selected: productData.id)
            self.products = productsViewModels
            self.activeProductId = productData.id
            self.productType = productData.productType
            self.model = model
            
            bind()
            bind(selector)
            
            for product in products {
                
                bind(product)
            }
        }
        
        static func reduce(products: [ProductData], with productsData: ProductsData) -> [ProductData] {
            
            var result = [ProductData]()
            
            for product in products {
                
                switch product {
                case let accountProduct as ProductAccountData:
                    if let loansProducts = productsData[.loan] as? [ProductLoanData],
                        let relatedLoanProduct = loansProducts.first(where: { $0.settlementAccountId == accountProduct.id}) {
                        
                        result.append(relatedLoanProduct)
                        result.append(accountProduct)
                        
                    } else {
                        
                        result.append(accountProduct)
                    }
                    
                case let loanProduct as ProductLoanData:
                    if let accountProducts = productsData[.account] as? [ProductAccountData],
                       let relatedAccountProduct = accountProducts.first(where: { $0.id == loanProduct.settlementAccountId}) {
                        
                        result.append(loanProduct)
                        result.append(relatedAccountProduct)
                        
                    } else {
                        
                        result.append(loanProduct)
                    }
                    
                default:
                    result.append(product)
                }
            }
            
            return result
        }
        
        private func bind() {
            
            model.products
                .receive(on: DispatchQueue.main)
                .sink {[unowned self] productsData in
                    
                    if let productsForType = productsData[productType], productsForType.isEmpty == false {
                        
                        let productsWithRelated = Self.reduce(products: productsForType, with: productsData)
                        
                        // update products view models
                        var updatedProducts = [ProductView.ViewModel]()
                        for product in productsWithRelated {
                            
                            if let productViewModel = self.products.first(where: { $0.id == product.id }) {
                                
                                productViewModel.update(with: product, model: model)
                                updatedProducts.append(productViewModel)
                                
                            } else {
                                
                                let productViewModel = ProductView.ViewModel(with: product, size: .large, style: .profile, model: model)
                                bind(productViewModel)
                                updatedProducts.append(productViewModel)
                            }
                        }
                        
                        products = updatedProducts
                        
                        // update selector
                        let productsViewModelsIds = updatedProducts.map{ $0.id }
                        let productsForTypeDisplayed = productsWithRelated.filter({ productsViewModelsIds.contains($0.id)})
                        selector = SelectorViewModel(with: productsForTypeDisplayed, selected: activeProductId)
                        bind(selector)
                        
                        // update selected product
                        if products.contains(where: { $0.id == activeProductId }) == false {
                            
                            activeProductId = products[0].id
                        }
                        
                    } else {
                        
                        // nothing to display
                        //TODO: dismiss action
                    }
       
                }.store(in: &bindings)
            
            model.productsUpdating
                .combineLatest(model.productsFastUpdating)
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] data in
                    
                    let totalUpdating = data.0
                    let fastUpdating = data.1
                    
                    withAnimation {
                        
                        if totalUpdating.contains(productType) {
                            
                            for product in products {
                                
                                product.isUpdating = true
                            }
                            
                        } else {
                            
                            for product in products {
                                
                                if fastUpdating.contains(product.id) {
                                    
                                    product.isUpdating = true
                                    
                                } else {
                                    
                                    product.isUpdating = false
                                }
                            }
                        }
                    }
                    
                    
                }.store(in: &bindings)
            
            model.action
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] action in
                    
                    switch action {
                    case let payload as ModelAction.Card.Unblock.Response:
                        
                        let productViewModel = products.first(where: { $0.id == payload.cardId})
                        
                        switch payload.result {
                        case .success:
                            productViewModel?.action.send(ProductViewModelAction.CardActivation.Complete())
                            model.action.send(ModelAction.Products.Update.ForProductType(productType: .card))
                            
                        case .failure(message: let message):
                            productViewModel?.action.send(ProductViewModelAction.CardActivation.Failed())
                            self.action.send(ProductProfileCardViewModelAction.ShowAlert(title: "Ошибка", message: message))
                        }
                        
                    default:
                        break
                    }
                    
                }.store(in: &bindings)
            
            $activeProductId
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] active in
                    
                    withAnimation {
                        
                        selector.selected = active
                    }
                    
                }.store(in: &bindings)
            
        }
        
        private func bind(_ product: ProductView.ViewModel) {
            
            product.action
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] action in
                    
                    switch action {
                    case _ as ProductViewModelAction.CardActivation.Started:
                        
                        let products = model.products.value.values.flatMap({$0})
                        
                        guard let productData = products.first(where: { $0.id == product.id}),
                              let cardProduct = productData as? ProductCardData,
                              let cardNumber = cardProduct.number else {
                            
                            return
                        }
                        model.action.send(ModelAction.Card.Unblock.Request(cardId: cardProduct.id, cardNumber: cardNumber))
                        
                    default:
                        break
                    }
                    
                }.store(in: &bindings)
        }
        
        func bind(_ selector: SelectorViewModel?) {
            
            guard let selector = selector else {
                return
            }
            
            selector.action
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] action in
                    
                    switch action {
                    case let payload as ProductProfileCardView.ViewModel.SelectorViewModelAction.ThumbnailSelected:
                        withAnimation {
                            
                            activeProductId = payload.thunmbnailId
                        }
                        
                    case _ as ProductProfileCardView.ViewModel.SelectorViewModelAction.MoreButtonTapped:
                        self.action.send(ProductProfileCardViewModelAction.MoreButtonTapped())
    
                    default:
                        break
                    }
                    
                }.store(in: &bindings)
        }
    }
}

enum ProductProfileCardViewModelAction {

    struct MoreButtonTapped: Action {}
    
    struct ShowAlert: Action {
        
        let title: String
        let message: String
    }
}

extension ProductProfileCardView.ViewModel {
    
    class SelectorViewModel: ObservableObject {
        
        let action: PassthroughSubject<Action, Never> = .init()
        
        @Published var thumbnails: [ThumbnailViewModel]
        @Published var selected: ThumbnailViewModel.ID
        lazy var moreButton: MoreButtonViewModel = .init(action: { [weak self] in self?.action.send(SelectorViewModelAction.MoreButtonTapped())})
        
        init(thumbnails: [ThumbnailViewModel], selected: ThumbnailViewModel.ID) {
            
            self.thumbnails = thumbnails
            self.selected = selected
        }
        
        init(with products: [ProductData], selected: ProductData.ID) {
            
            self.thumbnails = []
            self.selected = selected
            
            self.thumbnails = products.map { product in
                
                ThumbnailViewModel(with: product) { [weak self] productId in
                    self?.selected = productId
                    self?.action.send(ProductProfileCardView.ViewModel.SelectorViewModelAction.ThumbnailSelected(thunmbnailId: productId))
                }
            }
        }
        
        struct ThumbnailViewModel: Identifiable {
 
            let id: ProductData.ID
            let background: Background
            let action: (ProductData.ID) -> Void
            
            init(id: ProductData.ID, background: Background, action: @escaping (ProductData.ID) -> Void) {
                
                self.id = id
                self.background = background
                self.action = action
            }
            
            init(with productData: ProductData, action: @escaping (ProductData.ID) -> Void) {
                
                self.id = productData.id
   
                if let backgroundImage = productData.smallDesign.image {
                    
                    self.background = .image(backgroundImage)
                    
                } else {
                    
                    self.background = .color(productData.backgroundColor)
                }
                
                self.action = action
            }
            
            enum Background {
                
                case image(Image)
                case color(Color)
            }
        }
        
        struct MoreButtonViewModel {
            
            let action: () -> Void
        }
    }
    
    enum SelectorViewModelAction {
        
        struct ThumbnailSelected: Action {
            
            let thunmbnailId: SelectorViewModel.ThumbnailViewModel.ID
        }
        
        struct MoreButtonTapped: Action {}
    }
}

struct ProductProfileCardView: View {
    
    @ObservedObject var viewModel: ProductProfileCardView.ViewModel
        
    var body: some View {
        
        VStack(spacing: 0) {
            
            SelectorView(viewModel: viewModel.selector)
            
            if #available(iOS 14.0, *) {
                
                TabView(selection: $viewModel.activeProductId) {
                    
                    ForEach(viewModel.products) { product in
                        
                        ZStack {
                            // shadow
                            RoundedRectangle(cornerRadius: 12)
                                .offset(.init(x: 0, y: 6))
                                .foregroundColor(.mainColorsBlackMedium)
                                .opacity(0.3)
                                .blur(radius: 12)
                                .frame(width: shadowWidth(for: product), height: 160)
                            
                            ProductView(viewModel: product)
                                .frame(width: productWidth(for: product), height: 160)
                            
                        }.tag(product.id)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 210)
                
            } else {
                
                // Fallback on earlier versions
            }
        }
    }
    
    func productWidth(for product: ProductView.ViewModel) -> CGFloat {
        
        switch product.productType {
        case .deposit: return 228
        default: return 268
        }
    }
    
    func shadowWidth(for product: ProductView.ViewModel) -> CGFloat {
        
        switch product.productType {
        case .deposit: return 228 - 20
        default: return 268 - 20
        }
    }
}

//MARK: - Internal Views

extension ProductProfileCardView {
    
    struct SelectorView: View {
        
        @ObservedObject var viewModel: ProductProfileCardView.ViewModel.SelectorViewModel
        
        var body: some View {

            ScrollView(.horizontal, showsIndicators: false) { proxy in
                
                HStack(alignment: .center, spacing: 8) {
                    
                    ForEach(viewModel.thumbnails) { thumbnail in
                        
                        ProductProfileCardView.ThumbnailView(viewModel: thumbnail, isSelected: viewModel.selected == thumbnail.id)
                            .scrollId(thumbnail.id)
                    }
                    
                    ProductProfileCardView.MoreButtonView(viewModel: viewModel.moreButton)
                }
                .padding(.horizontal, UIScreen.main.bounds.size.width / 2 - 48 + 48 / 2)
                .onReceive(viewModel.$selected) { selected in
                    proxy.scrollTo(selected, alignment: .center, animated: true)
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(10)) {
                        proxy.scrollTo(viewModel.selected, alignment: .center, animated: false)
                        
                    }
                }
            }
        }
    }
    
    struct ThumbnailView: View {
        
        let viewModel: ProductProfileCardView.ViewModel.SelectorViewModel.ThumbnailViewModel
        let isSelected: Bool
        
        var body: some View {
            
            Button {
                
                viewModel.action(viewModel.id)
                
            } label: {
                
                ZStack {
                    
                    if isSelected {
                        
                        Circle()
                            .foregroundColor(.black.opacity(0.2))
     
                    }
                    
                    switch viewModel.background {
                    case .image(let image):
                        
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 32, height: 22)
                            .cornerRadius(3)
                            .opacity(isSelected ? 1 : 0.3)
                        
                    case .color(let color):
                        
                        color
                            .frame(width: 32, height: 22)
                            .cornerRadius(3)
                            .opacity(isSelected ? 1 : 0.3)
                    }
                }
                .frame(width: 48, height: 48)
            }
        }
    }
    
    struct MoreButtonView: View {
        
        let viewModel: ProductProfileCardView.ViewModel.SelectorViewModel.MoreButtonViewModel
        
        var body: some View {
            
            Button(action: viewModel.action) {
                
                ZStack {
                    
                    Color.white
                        .frame(width: 32, height: 22)
                        .cornerRadius(3)
                    
                    HStack(spacing: 3) {
                        
                        ForEach(0..<3) { _ in
                            
                            Circle()
                                .foregroundColor(.iconBlack)
                                .frame(width: 2, height: 2)
                        }
                    }
                }
                .frame(width: 48, height: 48)
                .opacity(0.4)
            }
        }
    }
}

//MARK: - Preview

struct ProductProfileCardView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            ProductProfileCardView(viewModel: .sample)
                .previewLayout(.fixed(width: 375, height: 500))
            
            ProductProfileCardView.SelectorView(viewModel: .sample)
                .previewLayout(.fixed(width: 375, height: 60))
        }
    }
}

//MARK: - Preview Content

extension ProductProfileCardView.ViewModel {
    
    static let sample = ProductProfileCardView.ViewModel(selector: .sample, products: [.notActivateProfile, .classicProfile, .accountProfile, .blockedProfile, .depositProfile], activeProductId: 4, productType: .account, model: .emptyMock)
}

extension ProductProfileCardView.ViewModel.SelectorViewModel.ThumbnailViewModel {
    
    static let sampleColorPurpule = ProductProfileCardView.ViewModel.SelectorViewModel.ThumbnailViewModel(id: 0, background: .color(.purple), action: { _ in  })
    
    static let sampleColorBlue = ProductProfileCardView.ViewModel.SelectorViewModel.ThumbnailViewModel(id: 1, background: .color(.blue), action: { _ in  })
    
    static let sampleColorOrange = ProductProfileCardView.ViewModel.SelectorViewModel.ThumbnailViewModel(id: 2, background: .color(.orange), action: { _ in  })
}

extension ProductProfileCardView.ViewModel.SelectorViewModel {
    
    static let sample = ProductProfileCardView.ViewModel.SelectorViewModel(thumbnails: [.sampleColorPurpule, .sampleColorBlue, .sampleColorOrange], selected: 0)
}

