//
//  ProductProfileCardView.swift
//  ForaBank
//
//  Created by Дмитрий on 24.02.2022.
//

import SwiftUI
import Combine
import PinCodeUI
import CardUI
import ActivateSlider
import Foundation

//MARK: - ViewModel

extension ProductProfileCardView {
    
    class ViewModel: ObservableObject {
        
        typealias CardAction = CardDomain.CardAction
        typealias ShowCVV = (CardDomain.CardId, @escaping (CardInfo.CVV?) -> Void) -> Void

        let action: PassthroughSubject<Action, Never> = .init()
        
        @Published var selector: SelectorViewModel
        @Published var products: [ProductViewModel]
        @Published var activeProductId: ProductData.ID
        
        let productType: ProductType
        
        private let model: Model
        private let cardAction: CardAction?
        private let showCvv: ShowCVV?
        private let event: (Event) -> Void

        private var bindings = Set<AnyCancellable>()
        
        fileprivate init(
            selector: SelectorViewModel,
            products: [ProductViewModel],
            activeProductId: ProductData.ID,
            productType: ProductType,
            model: Model = .emptyMock,
            cardAction: CardAction? = nil,
            showCvv: ShowCVV? = nil,
            event: @escaping (Event) -> Void = {_ in }
        ) {
            self.selector = selector
            self.products = products
            self.activeProductId = activeProductId
            self.productType = productType
            self.model = model
            self.cardAction = cardAction
            self.showCvv = showCvv
            self.event = event
        }
        
        init?(
            _ model: Model,
            productData: ProductData,
            cardAction: CardAction? = nil,
            showCvv: ShowCVV? = nil,
            event: @escaping (Event) -> Void = {_ in }
        ) {
            // fetch app products of type
            guard let productsForType = model.products.value[productData.productType],
                  !productsForType.isEmpty,
                  productsForType.contains(where: { $0.id == productData.id })
            else { return nil }
            
            // generate products view models
            let productsWithRelated = Self.reduce(products: productsForType, with: model.products.value)
            var productsViewModels = [ProductViewModel]()
            for product in productsWithRelated {
                
                let cvvInfo: CvvInfo? = {
                    if let card = product as? ProductCardData {
                        return .init(
                            showCvv: showCvv,
                            cardType: card.cardType,
                            cardStatus: card.statusCard
                        )
                    }
                    return nil
                }()
                
                let productViewModel = ProductViewModel(
                    with: product,
                    size: .large,
                    style: .profile,
                    model: model,
                    cardAction: cardAction,
                    cvvInfo: cvvInfo,
                    event: event
                )
                productsViewModels.append(productViewModel)
            }
                        
            // filter products data with products view models
            let productsViewModelsIds = productsViewModels.map{ $0.id }
            let productsForTypeDisplayed = productsWithRelated.filter({ productsViewModelsIds.contains($0.id)})
            
            self.selector = SelectorViewModel(
                with: productsForTypeDisplayed,
                selected: productData.id,
                getImage: { model.images.value[.init($0)]?.image }
            )
            self.products = productsViewModels
            self.activeProductId = productData.id
            self.productType = productData.productType
            self.model = model
            self.showCvv = showCvv
            self.cardAction = cardAction
            self.event = event
            bind()
            bind(selector)
            
            for product in products {
                
                bind(product)
            }
        }
        
        static func reduce(products: [ProductData], with productsData: ProductsData) -> [ProductData] {
            
            products.flatMap {
                
                switch $0 {
                case let accountProduct as ProductAccountData:
                    if let loansProducts = productsData[.loan] as? [ProductLoanData],
                        let relatedLoanProduct = loansProducts.first(where: { $0.settlementAccountId == accountProduct.id}) {
                        
                        return [accountProduct, relatedLoanProduct]
                        
                    } else {
                        
                        return [accountProduct]
                    }
                    
                case let loanProduct as ProductLoanData:
                    if let accountProducts = productsData[.account] as? [ProductAccountData],
                       let relatedAccountProduct = accountProducts.first(where: { $0.id == loanProduct.settlementAccountId}) {
                        
                        return [relatedAccountProduct, loanProduct]
                        
                    } else {
                        
                        return [loanProduct]
                    }
                    
                default:
                    return [$0]
                }
            }
        }
        
        private func bind() {
            
            // CVV

            action
                .compactMap { $0 as? ProductProfileCardView.ViewModel.CVVPinViewModelAction.ShowCVV }
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] action in
                    
                    let product = self.products.filter {
                        $0.id == action.cardId.rawValue
                    }.first
                    
                    product?.action.send(ProductViewModelAction.ShowCVV(cardId: .init(action.cardId.rawValue), cvv: action.cvv))
                    
                }.store(in: &bindings)

            
            model.products
                .receive(on: DispatchQueue.main)
                .sink {[unowned self] productsData in
                    
                    if let productsForType = productsData[productType], productsForType.isEmpty == false {
                        
                        let productsWithRelated = Self.reduce(products: productsForType, with: productsData)
                        
                        // update products view models
                        var updatedProducts = [ProductViewModel]()
                        for product in productsWithRelated {
                            
                            if let productViewModel = self.products.first(where: { $0.id == product.id }) {
                                
                                productViewModel.update(with: product, model: model)
                                updatedProducts.append(productViewModel)
                                
                            } else {
                                
                                let cvvInfo: CvvInfo? = {
                                    if let card = product as? ProductCardData {
                                        return .init(
                                            showCvv: showCvv,
                                            cardType: card.cardType,
                                            cardStatus: card.statusCard
                                        )
                                    }
                                    return nil
                                }()
                                
                                let productViewModel = ProductViewModel(
                                    with: product,
                                    size: .large,
                                    style: .profile,
                                    model: model,
                                    cardAction: cardAction,
                                    cvvInfo: cvvInfo,
                                    event: event
                                )
                                bind(productViewModel)
                                updatedProducts.append(productViewModel)
                            }
                        }
                        
                        products = updatedProducts
                        
                        // update selector
                        let productsViewModelsIds = updatedProducts.map{ $0.id }
                        let productsForTypeDisplayed = productsWithRelated.filter({ productsViewModelsIds.contains($0.id)})
                        selector = SelectorViewModel(
                            with: productsForTypeDisplayed,
                            selected: activeProductId,
                            getImage: { self.model.images.value[.init($0)]?.image }
                        )
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
                            model.handleProductUpdateDynamicParamsList(payload.cardId, productType: .card)
                            
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
                    
                    products.forEach { product in
                        
                        guard product.id != active else { return }
                        
                        product.resetToFront()
                    }
                    
                }.store(in: &bindings)
        }
        
        private func bind(_ product: ProductViewModel) {
            
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
                        self.activateCard(cardProduct, cardNumber)
                        
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
        
        func activateCard(
            _ cardProduct: ProductCardData?,
            _ cardNumber: String?
        ) {
            guard let cardProduct, let cardNumber else { return }
            
            model.action.send(ModelAction.Card.Unblock.Request(cardId: cardProduct.id, cardNumber: cardNumber))
        }
        
        func needSlider(_ product: ProductViewModel) -> Bool {
            
            guard let productData = model.product(productId: product.id),
                  let cardProduct = productData.asCard 
            else { return false }
                    
            return cardProduct.statusCard == .notActivated
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
    
    typealias Event = AlertEvent
}

extension ProductProfileCardView.ViewModel {
    
    class SelectorViewModel: ObservableObject {
        
        let action: PassthroughSubject<Action, Never> = .init()
        
        let productSize: CGSize = .init(width: 48, height: 48)
        let spacing: CGFloat = 8
        var groupingCards: Array.Products = [:]
        
        @Published var thumbnails: [ThumbnailViewModel]
        @Published var selected: ThumbnailViewModel.ID
        
        lazy var moreButton: MoreButtonViewModel = .init(action: { [weak self] in self?.action.send(SelectorViewModelAction.MoreButtonTapped()) })
        
        init(
            thumbnails: [ThumbnailViewModel],
            selected: ThumbnailViewModel.ID
        ) {
            
            self.thumbnails = thumbnails
            self.selected = selected
        }
        
        init(with products: [ProductData], selected: ProductData.ID, getImage: @escaping (MD5Hash) -> Image?) {
            
            self.thumbnails = []
            self.selected = selected
            self.groupingCards = products.groupingCards()
            self.thumbnails = products.map { product in
                
                ThumbnailViewModel(
                    with: product,
                    action: { [weak self] productId in
                        self?.selected = productId
                        self?.action.send(ProductProfileCardView.ViewModel.SelectorViewModelAction.ThumbnailSelected(thunmbnailId: productId))
                    },
                    getImage: getImage)
            }
        }
        
        func widthWithColor(by id: Int) -> (CGFloat, Color) {
            
            if let values = groupingCards[id] {
                let additionalSpacing = values.count == 1 ? 0 : spacing
                let width = CGFloat(values.count) * (productSize.width + spacing) - additionalSpacing
        
                return values.count == 1 ? (width, .clear) : (width, .black.opacity(0.2))
            }
            return (0, .clear)
        }
        
        struct ThumbnailViewModel: Identifiable {
 
            let id: ProductData.ID
            let background: Background
            let action: (ProductData.ID) -> Void
            let getImage: (MD5Hash) -> Image?
            
            init(id: ProductData.ID, background: Background, action: @escaping (ProductData.ID) -> Void, getImage: @escaping (MD5Hash) -> Image?) {
                
                self.id = id
                self.background = background
                self.action = action
                self.getImage = getImage
            }
            
            init(with productData: ProductData, action: @escaping (ProductData.ID) -> Void, getImage: @escaping (MD5Hash) -> Image?) {
                
                self.id = productData.id
                self.getImage = getImage

                if let backgroundImage = getImage(.init(productData.smallDesignMd5hash)) {
                    
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
    
    enum CVVPinViewModelAction {
        
        struct ShowCVV: Action {
            let cardId: CardDomain.CardId
            let cvv: CardInfo.CVV
        }
    }
}

struct ProductProfileCardView: View {
    
    @ObservedObject var viewModel: ProductProfileCardView.ViewModel
    let makeSliderActivateView: MakeActivateSliderView
    let makeSliderViewModel: ActivateSliderViewModel
    let sliderConfig: SliderConfig = .config
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            SelectorView(viewModel: viewModel.selector)
            
            TabView(selection: $viewModel.activeProductId) {
                
                ForEach(viewModel.products) { product in
                    
                    ZStack {
                        // shadow
                        RoundedRectangle(cornerRadius: 12)
                            .offset(.init(x: 0, y: 6))
                            .foregroundColor(.mainColorsBlackMedium)
                            .opacity(0.3)
                            .blur(radius: 10)
                            .frame(width: 268 - 20, height: 165)

                        if viewModel.needSlider(product)  {
                            GenericProductView<ActivateSliderStateWrapperView>(viewModel: product, factory: .init(
                                makeSlider: {
                                    makeSliderActivateView(
                                        product.id,
                                        makeSliderViewModel,
                                        sliderConfig
                                    )}))
                            .frame(width: 268, height: 160)

                        } else {
                            ProductView(viewModel: product)
                                  .frame(width: 268, height: 160)
                        }
                        
                    }.tag(product.id)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 210)
        }
    }
}

//MARK: - Internal Views

extension ProductProfileCardView {
    
    struct SelectorView: View {
        
        @ObservedObject var viewModel: ProductProfileCardView.ViewModel.SelectorViewModel
        
        var body: some View {

            ScrollView(.horizontal, showsIndicators: false) { proxy in
                
                ZStack {
                    
                    SelectorsView(viewModel: viewModel)

                    HStack(alignment: .center, spacing: 8) {
                        
                        ForEach(viewModel.thumbnails) { thumbnail in
                            
                            ProductProfileCardView.ThumbnailView(viewModel: thumbnail, isSelected: viewModel.selected == thumbnail.id)
                                .scrollId(thumbnail.id)
                        }
                        
                        ProductProfileCardView.MoreButtonView(viewModel: viewModel.moreButton)
                    }
                    .padding(.horizontal, UIScreen.main.bounds.size.width / 2 - viewModel.productSize.width + viewModel.productSize.width / 2)
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
    }
    
    struct SelectorsView: View {
        
        let viewModel: ProductProfileCardView.ViewModel.SelectorViewModel
        
        var body: some View {
            
            HStack(alignment: .center, spacing: 0) {
                
                ForEach(viewModel.thumbnails) { thumbnail in
                    
                    let (width, color) = viewModel.widthWithColor(by: thumbnail.id)
                    Capsule()
                        .foregroundColor(color)
                        .frame(width: width, height: viewModel.productSize.height)
                }
                Spacer()
            }
            .padding(.horizontal, UIScreen.main.bounds.size.width / 2 - viewModel.productSize.width + viewModel.productSize.width / 2)
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
            .accessibilityIdentifier("thumbnailButton")
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
            .accessibilityIdentifier("moreButton")
        }
    }
}

//MARK: - Preview

struct ProductProfileCardView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            ProductProfileCardView(
                viewModel: .sample,
                makeSliderActivateView: ActivateSliderStateWrapperView.init(payload:viewModel:config:),
                makeSliderViewModel: .previewActivateSuccess
            )
                .previewLayout(.fixed(width: 375, height: 500))
            
            ProductProfileCardView.SelectorView(viewModel: .sample)
                .previewLayout(.fixed(width: 375, height: 60))
        }
    }
}

//MARK: - Preview Content

extension ProductProfileCardView.ViewModel {
    
    static let sample = ProductProfileCardView.ViewModel(
        selector: .sample,
        products: [.notActivateProfile, .classicProfile, .accountProfile, .blockedProfile, .depositProfile],
        activeProductId: 4,
        productType: .account,
        model: .emptyMock,
        cardAction: { _ in },
        showCvv: nil)
}

extension ProductProfileCardView.ViewModel.SelectorViewModel.ThumbnailViewModel {
    
    static let sampleColorPurpule = ProductProfileCardView.ViewModel.SelectorViewModel.ThumbnailViewModel(id: 0, background: .color(.purple), action: { _ in  }, getImage: { _ in  .none})
    
    static let sampleColorBlue = ProductProfileCardView.ViewModel.SelectorViewModel.ThumbnailViewModel(id: 1, background: .color(.blue), action: { _ in  }, getImage: { _ in  .none})
    
    static let sampleColorOrange = ProductProfileCardView.ViewModel.SelectorViewModel.ThumbnailViewModel(id: 2, background: .color(.orange), action: { _ in  }, getImage: { _ in  .none})
}

extension ProductProfileCardView.ViewModel.SelectorViewModel {
    
    static let sample = ProductProfileCardView.ViewModel.SelectorViewModel(thumbnails: [.sampleColorPurpule, .sampleColorBlue, .sampleColorOrange], selected: 0)
}

