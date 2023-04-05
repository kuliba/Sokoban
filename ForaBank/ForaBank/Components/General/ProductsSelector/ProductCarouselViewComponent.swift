//
//  ProductCarouselViewComponent.swift
//  ForaBank
//
//  Created by Igor Malyarov on 07.02.2023.
//

import Combine
import ScrollViewProxy
import SwiftUI

// MARK: - ViewModel

extension ProductCarouselView {
    
    final class ViewModel: ObservableObject {

        let action: PassthroughSubject<Action, Never> = .init()

        @Published var content: Content
        @Published var selector: OptionSelectorView.ViewModel?
        var isScrollChangeSelectorEnable: Bool
  
        enum Content {
            
            case empty
            case placeholders
            case groups([ProductGroupView.ViewModel])
            
            var isEmpty: Bool {
                if case .empty = self { return true }
                else { return false }
            }
        }
        
        private var products: CurrentValueSubject<[ProductType: [ProductView.ViewModel]], Never> = .init([:])
        private var groups: [ProductGroupView.ViewModel] = []

        private let selectedProductId: ProductData.ID?
        private let mode: Mode
        
        let style: Style

        private let model: Model
        private var bindings = Set<AnyCancellable>()
        
        internal init(
            content: Content,
            selector: OptionSelectorView.ViewModel?,
            isScrollChangeSelectorEnable: Bool,
            selectedProductId: ProductData.ID?,
            mode: Mode,
            style: Style,
            model: Model = .emptyMock
        ) {
            self.content = content
            self.selector = selector
            self.isScrollChangeSelectorEnable = isScrollChangeSelectorEnable
            self.selectedProductId = selectedProductId
            self.mode = mode
            self.style = style
            self.model = model
            
            LoggerAgent.shared.log(level: .debug, category: .ui, message: "ProductCarouselView.ViewModel initialized")
        }
        
        deinit {
            
            LoggerAgent.shared.log(level: .debug, category: .ui, message: "ProductCarouselView.ViewModel deinitialized")
        }
        
        convenience init(
            selectedProductId: ProductData.ID? = nil,
            mode: Mode,
            isScrollChangeSelectorEnable: Bool = true,
            style: Style,
            model: Model
        ) {
            let selector = Self.makeSelector(
                products: model.allProducts,
                mode: mode,
                style: style.optionsSelectorStyle
            )
            
            self.init(
                content: .placeholders,
                selector: selector,
                isScrollChangeSelectorEnable: isScrollChangeSelectorEnable,
                selectedProductId: selectedProductId,
                mode: mode,
                style: style,
                model: model
            )
            
            bind()
        }
        
        var selectedType: ProductType? {
            
            guard let selected = selector?.selected,
                  let selectedType = ProductType(rawValue: selected)
            else { return nil }
            
            return selectedType
        }
        
        private func bind() {
            
            model.products
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] productsUpdate in
                    
                    // all existing products view models list
                    let currentProductsViewModels = products.value.values.flatMap { $0 }
                    
                    let updatedProducts: [ProductType: [ProductView.ViewModel]] = mode
                        .filtered(products: productsUpdate)
                        .mapValues {
                            
                            $0.map { product in
                                
                                // check if we already have view model for product data
                                if let currentProductViewModel = currentProductsViewModels.first(where: { $0.id == product.id }) {
                                    
                                    // just update existing view model with product data
                                    currentProductViewModel.update(with: product, model: model)
                                    
                                    return currentProductViewModel
                                    
                                } else {
                                    
                                    // create new product view model
                                    let productViewModel = ProductView.ViewModel(with: product, size: style.productAppearanceSize, style: .main, model: model)
                                    bind(productViewModel)
                                    
                                    return productViewModel
                                }
                            }
                        }
                    
                    self.products.send(updatedProducts)
                }
                .store(in: &bindings)
            
            products
                .combineLatest(model.productsUpdating)
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] (products, productsUpdating) in
                    
                    if model.isAllProductsHidden {
                        
                        withAnimation {
                        
                            content = .empty
                        }
                        
                    } else {
                    
                        let updatedGroups = model.update(
                            groups: groups,
                            products: products,
                            productsUpdating: productsUpdating,
                            productGroupDimensions: style.productGroupDimensions
                        )
                    
                        updatedGroups.last?.isSeparator = false
                        groups = updatedGroups
                    
                        content = content(with: groups)
                    
                        bind(groups)
                    
                        // create product type selector
                        let selectedOptionID = selector?.selected
                        let productTypes = products.keys.sorted(by: \.order)
                        
                        withAnimation {
                            
                            self.selector = Self.makeSelector(
                                productTypes: productTypes,
                                style: self.style.optionsSelectorStyle
                            )
                            self.selector?.select(selectedOptionID)
                        }
                        
                        bind(selector)
                        
                    } //if visibility empty
                    
                }.store(in: &bindings)
            
            typealias CarouselHorizontalOffsetDidChanged = ProductCarouselViewModelAction.Products.HorizontalOffsetDidChanged
            
            action
                .compactMap { $0 as? CarouselHorizontalOffsetDidChanged }
                .map(\.offset)
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] offset in
                    
                    self.updateSelector(with: offset)
                }
                .store(in: &bindings)
            
            typealias CarouselScrollToFirstGroup = ProductCarouselViewModelAction.Products.ScrollToFirstGroup
            
            action
                .compactMap { $0 as? CarouselScrollToFirstGroup }
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] _ in
                    
                    guard let id = content.firstGroup?.id else { return }
                    
                    selector?.selected = id
                }
                .store(in: &bindings)
            
            model.productsOpening
                .map { $0.contains(.account) }
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] accountOpening in
                    
                    guard let accountsGroup = content.firstGroup(ofType: .account)
                    else { return }
                    
                    withAnimation {
                        accountsGroup.isOpeningProduct = accountOpening
                    }
                }
                .store(in: &bindings)
        }
        
        private func bind(_ product: ProductView.ViewModel) {
            
            typealias ProductDidTapped = ProductViewModelAction.ProductDidTapped
            typealias CarouselProductDidTapped = ProductCarouselViewModelAction.Products.ProductDidTapped
            
            product.action
                .compactMap { $0 as? ProductDidTapped }
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] _ in
                    
                    self.action.send(CarouselProductDidTapped(productId: product.id))
                }
                .store(in: &bindings)
        }
        
        private func bind(_ selector: OptionSelectorView.ViewModel?) {
            
            typealias OptionDidSelected = OptionSelectorAction.OptionDidSelected
            typealias CarouselScrollToGroup = ProductCarouselViewModelAction.Products.ScrollToGroup
            
            selector?.action
                .compactMap { $0 as? OptionDidSelected }
                .map(\.optionId)
                .compactMap(ProductType.init(rawValue:))
                .compactMap { [unowned self] productType in
                    
                    self.groups.first(where: { $0.productType == productType })
                }
                .map(\.id)
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] id in
                    
                    self.action.send(CarouselScrollToGroup(groupId: id))
                }
                .store(in: &bindings)
        }
        
        private func bind(_ groups: [ProductGroupView.ViewModel]) {
            
            groups.forEach(bind)
        }
        
        private func bind(_ group: ProductGroupView.ViewModel) {
            
            typealias CarouselScrollToGroup = ProductCarouselViewModelAction.Products.ScrollToGroup

            group.action
                .compactMap { $0 as? ProductGroupAction.Group.Collapsed }
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] _ in
                    
                    self.action.send(CarouselScrollToGroup(groupId: group.id))
                }
                .store(in: &bindings)
        }
        
        private func updateSelector(with offset: CGFloat) {
            
            guard let selector = selector,
                  let productType = productType(with: offset)
            else { return }
            
            if selector.selected != productType.rawValue {
                
                withAnimation {
                    
                    self.selector?.selected = productType.rawValue
                }
            }
        }

        private func content(with groups: [ProductGroupView.ViewModel]) -> Content {
            
            groups.isEmpty ? .placeholders : .groups(groups)
        }

        private func productType(with offset: CGFloat) -> ProductType? {
            
            guard groups.count > 0 else {
                return nil
            }
            
            var currentLength: CGFloat = 0
            for group in groups {
                
                currentLength += group.width
                guard currentLength >= offset else {
                    continue
                }
                
                return group.productType
            }
            
            return groups.last?.productType
        }
    }
}

extension ProductCarouselView.ViewModel.Content {
    
    var firstGroup: ProductGroupView.ViewModel? {
        
        guard case let .groups(groups) = self,
              let firstGroup = groups.first
        else { return nil }
        
        return firstGroup
    }
    
    func firstGroup(
        ofType productType: ProductType
    ) -> ProductGroupView.ViewModel? {
        
        guard case let .groups(groups) = self,
              let firstGroup = groups.first(where: { $0.productType == productType })
        else { return nil }
        
        return firstGroup
    }
}

// MARK: - Helper

private extension Model {
    
    func update(
        groups: [ProductGroupView.ViewModel],
        products: [ProductType : [ProductView.ViewModel]],
        productsUpdating: [ProductType],
        productGroupDimensions: ProductGroupView.ViewModel.Dimensions
    ) -> [ProductGroupView.ViewModel] {
        
        ProductType.allCases.compactMap { productType in
            
            guard let productsForType = products[productType] else {
                return nil
            }

            let isGroupUpdating = productsUpdating.contains(productType)
            let group = groups.first(where: { $0.productType == productType}) ?? .init(
                productType: productType,
                products: [],
                dimensions: productGroupDimensions,
                model: self
            )
            group.update(with: productsForType)
            group.isSeparator = true
            group.isUpdating = isGroupUpdating
            
            return group
        }
    }
}

private extension OptionSelectorView.ViewModel {
    
    func select(_ optionID: Option.ID?) {
        
        guard let optionID = optionID,
              isSelectable(optionID)
        else {
            
            if let firstID = options.map(\.id).first {
                selected = firstID
            }
            return
        }
        
        selected = optionID
    }
    
    private func isSelectable(_ option: Option.ID) -> Bool {
        
        options.map(\.id).contains(option)
    }
}

// MARK: - Style

extension ProductCarouselView.ViewModel {
    
    enum Style {
        
        case regular, small
    }
    
    enum Mode {
        
        case main
        case filtered(ProductData.Filter)
    }
}

private extension ProductCarouselView.ViewModel.Mode {
    
    func filteredProductsTypes(
        for products: ProductsData
    ) -> [ProductType] {
        
        filteredProductsTypes(for: products.values.flatMap { $0 })
    }
    
    func filteredProductsTypes(
        for products: [ProductData]
    ) -> [ProductType] {
        
        switch self {
        case .main:
            let visibleProducts = products.filter { $0.isVisible }
            let uniqueTypes = Set(visibleProducts.map(\.productType))
            return uniqueTypes.sorted(by: \.order)

        case let .filtered(filter):
            return filter.filterredProductsTypes(products)
        }
    }
    
    func filtered(
        products: ProductsData
    ) -> ProductsData {
        
        products
            .mapValues(filtered)
            .filter { !$0.value.isEmpty }
    }
    
    private func filtered(
        products: [ProductData]
    ) -> [ProductData] {
        
        switch self {
        case .main:
            return products.filter { $0.isVisible }
            
        case let .filtered(filter):
            return filter.filterredProducts(products)
        }
    }
}

private extension ProductCarouselView.ViewModel.Style {
    
    var stackSpacing: CGFloat {
        
        switch self {
        case .small:   return 13
        case .regular: return 13
        }
    }
    
    var optionsSelectorStyle: OptionSelectorView.ViewModel.Style {
        
        switch self {
        case .regular: return .products
        case .small: return .productsSmall
        }
    }
    
    var productGroupDimensions: ProductGroupView.ViewModel.Dimensions {
        
        switch self {
        case .regular: return .regular
        case .small: return .small
        }
    }
    
    var productAppearanceSize: ProductView.ViewModel.Appearance.Size {
        
        switch self {
        case .regular: return .normal
        case .small: return .small
        }
    }
    
    var selectorFrameHeight: CGFloat? {
        
        switch self {
        case .regular: return 24
        case .small: return nil
        }
    }
    
    var horizontalPadding: CGFloat {
        
        switch self {
        case .regular: return 20
        case .small: return 12
        }
    }
    
    var frameHeight: CGFloat {
        
        productGroupDimensions.sizes.product.height
    }
    
    var bottomPadding: CGFloat {
        
        switch self {
        case .regular: return 0
        case .small: return 16 + 9 + 3
        }
    }
    
    var productGroupOffsetY: CGFloat {
        
        switch self {
        case .regular: return 0
        case .small: return -2
        }
    }
}

//MARK: - Action

enum ProductCarouselViewModelAction {
    
    enum Products {
        
        struct ProductDidTapped: Action {
            
            let productId: ProductData.ID
        }
        
        struct ScrollToGroup: Action {
            
            let groupId: ProductGroupView.ViewModel.ID
        }
        
        struct ScrollToFirstGroup: Action {}
        
        struct HorizontalOffsetDidChanged: Action {
            
            let offset: CGFloat
        }
    }
}

//MARK: - Make Selector

extension ProductCarouselView.ViewModel {

    static func makeSelector(
        products: [ProductData],
        mode: Mode,
        style: OptionSelectorView.ViewModel.Style
    ) -> OptionSelectorView.ViewModel? {
        
        let availableProductTypes = mode.filteredProductsTypes(for: products)
        
        guard let firstType = availableProductTypes.first,
              availableProductTypes.count > 1
        else { return nil }
        
        let options = availableProductTypes.map {
            Option(id: $0.rawValue, name: $0.pluralName)
        }
        
        return .init(
            options: options,
            selected: firstType.rawValue,
            style: style,
            mode: .action
        )
    }

    static func makeSelector(
        productTypes: [ProductType],
        style: OptionSelectorView.ViewModel.Style
    ) -> OptionSelectorView.ViewModel? {
        
        guard let firstType = productTypes.first,
              productTypes.count > 1
        else { return nil }
        
        let options = productTypes.map {
            Option(id: $0.rawValue, name: $0.pluralName)
        }
        
        return .init(
            options: options,
            selected: firstType.rawValue,
            style: style,
            mode: .action
        )
    }
}

//MARK: - View

struct ProductCarouselView: View {
    
    @ObservedObject private var viewModel: ViewModel
    
    private let buttonNewProduct: () -> ButtonNewProduct?
    
    init(
        viewModel: ViewModel,
        buttonNewProduct: @escaping () -> ButtonNewProduct?
    ) {
        self.viewModel = viewModel
        self.buttonNewProduct = buttonNewProduct
    }
    
    init(viewModel: ViewModel) {
        self.init(viewModel: viewModel, buttonNewProduct: { nil })
    }
    
    private let newProductButtonHeight = ProductGroupView.ViewModel.Dimensions.regular.sizes.product.height
    
    @State private var scrollView: UIScrollView? = nil
    
    var body: some View {
        
        VStack(spacing: viewModel.style.stackSpacing) {
            
            viewModel.selector.map {
                
                OptionSelectorView(viewModel: $0)
                    .frame(height: selectorFrameHeight)
                    .accessibilityIdentifier("optionProductTypeSelection")
                    .padding(
                        .leading,
                        viewModel.style.horizontalPadding
                    )
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                
                ScrollViewReader { proxy in
                    
                    HStack(alignment: .top, spacing: 8) {
                        
                        switch viewModel.content {
                            
                        case .empty:
                            EmptyView()
                            
                        case .placeholders:
                            PlaceholdersView(style: viewModel.style)
                            
                        case let .groups(groups):
                            
                            HStack(spacing: 8) {
                                
                                ForEach(groups) { groupViewModel in
                                    ProductGroupView(viewModel: groupViewModel)
                                        .accessibilityIdentifier("productScrollView")
                                }
                            }
                        }
                        
                        buttonNewProduct().map {
                            $0.frame(height: newProductButtonHeight)
                        }
                    }
                    .onReceive(viewModel.action, perform: scrollFor)
                    .onReceive(proxy.offset, perform: onOffsetChange)
                }
                .padding(.horizontal, viewModel.style.horizontalPadding)
                .introspectScrollView(customize: { scrollView in

                    self.scrollView = scrollView
                })
            }
        }
    }
        
    func scrollFor(action: Action) -> Void {
        
        typealias CarouselScrollToGroup = ProductCarouselViewModelAction.Products.ScrollToGroup
        typealias CarouselScrollToFirstGroup = ProductCarouselViewModelAction.Products.ScrollToFirstGroup

        switch action {
        case let payload as CarouselScrollToGroup:
            scrollToGroup(groupId: payload.groupId)
            
        case _ as CarouselScrollToFirstGroup:
            scrollToFirstGroup()
            
        default:
            break
        }
    }
}

extension ProductCarouselView {
    
    private var selectorFrameHeight: CGFloat? {
        
        viewModel.style.selectorFrameHeight
    }
    
    private var frameHeight: CGFloat {
        
        viewModel.style.frameHeight
    }
    
    private var bottomPadding: CGFloat {
        
        viewModel.style.bottomPadding
    }
    
    private var productGroupOffsetY: CGFloat {
        
        viewModel.style.productGroupOffsetY
    }
}

extension ProductCarouselView {

    func scrollToGroup(groupId: ProductGroupView.ViewModel.ID) {
        
        guard let scrollView = scrollView,
              case .groups(let groups) = viewModel.content
        else { return }
        
        viewModel.isScrollChangeSelectorEnable = false
        
        var offset: CGFloat = 0
        for group in groups {
            
            guard group.id != groupId else {
                break
            }
            
            offset += group.width
            offset += group.dimensions.spacing
        }
        
        let targetRect = CGRect(
            x: offset,
            y: 0,
            width: scrollView.bounds.width,
            height: scrollView.bounds.height
        )
        scrollView.scrollRectToVisible(targetRect, animated: false)

        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
            viewModel.isScrollChangeSelectorEnable = true
        }
    }
    
    func scrollToFirstGroup() {
        
        guard let scrollView = scrollView else {
            return
        }
        
        let targetRect = CGRect(
            x: 0,
            y: 0,
            width: scrollView.bounds.width,
            height: scrollView.bounds.height
        )
        scrollView.scrollRectToVisible(targetRect, animated: false)
    }
    
    func onOffsetChange(offset: CGPoint) {
        
        if viewModel.isScrollChangeSelectorEnable == true {
            
            typealias OffsetDidChanged = ProductCarouselViewModelAction.Products.HorizontalOffsetDidChanged
            
            viewModel.action.send(OffsetDidChanged(offset: offset.x))
        }
    }
}

//MARK: - Views

extension ProductCarouselView {
    
    struct PlaceholdersView: View {
        
        let style: ProductCarouselView.ViewModel.Style
        
        var body: some View {
            
            HStack(spacing: 8) {
                
                ForEach(0..<3) { _ in
                    
                    RoundedRectangle(cornerRadius: 12)
                        .frame(style.productGroupDimensions.sizes.product)
                        .foregroundColor(.mainColorsGrayLightest)
                        .shimmering(active: true, bounce: false)
                }
            }
        }
    }
    
}

//MARK: - Preview

struct ProdCarouselView_Previews: PreviewProvider {
    
    static func previewsGroup() -> some View {
        
        Group {
            
            ProductCarouselView(viewModel: .placeholders)
                .previewDisplayName("placeholders")
            ProductCarouselView(viewModel: .placeholdersSmall)
                .previewDisplayName("placeholdersSmall")
            ProductCarouselView(viewModel: .placeholdersSmallWithSelector)
                .previewDisplayName("placeholdersSmallWithSelector")
            ProductCarouselView(viewModel: .preview)
                .previewDisplayName("preview")
            ProductCarouselView(viewModel: .previewSmall)
                .previewDisplayName("previewSmall")
            ProductCarouselView(viewModel: .sampleProducts)
                .previewDisplayName("sampleProducts")
            ProductCarouselView(viewModel: .sampleProductsSmall)
                .previewDisplayName("sampleProductsSmall")
            ProductCarouselView(viewModel: .oneProductSmall)
                .previewDisplayName("oneProductSmall")
        }
        .previewLayout(.sizeThatFits)
    }

    static var previews: some View {
        
        Group {
            previewsGroup()
            
            // Xcode 14
            VStack(content: previewsGroup)
                .previewDisplayName("For Xcode 14 and later")
                .previewLayout(.sizeThatFits)
        }
    }
}

//MARK: - Preview Content

extension ProductCarouselView.ViewModel {
    
    static let placeholders = ProductCarouselView.ViewModel(
        content: .placeholders,
        selector: nil,
        isScrollChangeSelectorEnable: true,
        selectedProductId: nil,
        mode: .filtered(.generalFrom),
        style: .regular
    )
    
    static let placeholdersSmall = ProductCarouselView.ViewModel(
        content: .placeholders,
        selector: nil,
        isScrollChangeSelectorEnable: true,
        selectedProductId: nil,
        mode: .filtered(.generalFrom),
        style: .small
    )
    
    static let placeholdersSmallWithSelector = ProductCarouselView.ViewModel(
        content: .placeholders,
        selector: .mainSampleSmall,
        isScrollChangeSelectorEnable: true,
        selectedProductId: nil,
        mode: .filtered(.generalFrom),
        style: .small
    )
    
    static let preview = ProductCarouselView.ViewModel(
        content: .groups([.sampleWant]),
        selector: nil,
        isScrollChangeSelectorEnable: true,
        selectedProductId: nil,
        mode: .filtered(.generalFrom),
        style: .regular
    )
    
    static let previewSmall = ProductCarouselView.ViewModel(
        content: .groups([.sampleWant]),
        selector: nil,
        isScrollChangeSelectorEnable: true,
        selectedProductId: nil,
        mode: .filtered(.generalFrom),
        style: .small
    )
    
    static let sampleProducts = ProductCarouselView.ViewModel(
        content: .groups([.sampleProducts]),
        selector: .mainSample,
        isScrollChangeSelectorEnable: true,
        selectedProductId: nil,
        mode: .main,
        style: .regular
    )
    
    static let sampleProductsSmall = ProductCarouselView.ViewModel(
        content: .groups([.sampleProductsSmall]),
        selector: .mainSampleSmall,
        isScrollChangeSelectorEnable: true,
        selectedProductId: nil,
        mode: .main,
        style: .small
    )
    
    static let oneProductSmall = ProductCarouselView.ViewModel(
        mode: .filtered(.generalFrom),
        style: .small,
        model: .productsMock
)
}

extension ButtonNewProduct.ViewModel {
    
    static let sampleWantCard = ButtonNewProduct.ViewModel(id: "CARD", icon: .ic24NewCardColor, title: "Хочу карту", subTitle: "Бесплатно", action: {})
}
