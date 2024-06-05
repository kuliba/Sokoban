//
//  ProductGroupViewComponent.swift
//  ForaBank
//
//  Created by Max Gribov on 18.05.2022.
//

import Foundation
import SwiftUI
import Combine
import ScrollViewProxy
import Shimmer

//MARK: - ViewModel

extension ProductGroupView {
    
    final class ViewModel: Identifiable, ObservableObject {
        
        typealias GetProduct = (ProductData.ID) -> ProductCardData?

        let action: PassthroughSubject<Action, Never> = .init()
        
        var id: String { productType.rawValue }
        let productType: ProductType
        @Published var visible: [ProductViewModel]
        @Published var groupButton: GroupButtonViewModel?
        @Published var isCollapsed: Bool
        @Published var isSeparator: Bool
        @Published var isUpdating: Bool
        @Published var isOpeningProduct: Bool
        let dimensions: Dimensions
        
        private var products: CurrentValueSubject<[ProductViewModel], Never> = .init([])
        private let settings: ProductsGroupSettings
        private let model: Model
        private let getProduct: GetProduct
        private var bindings = Set<AnyCancellable>()
        
        init(productType: ProductType, visible: [ProductViewModel], groupButton: GroupButtonViewModel?, isCollapsed: Bool, isSeparator: Bool, isUpdating: Bool, isOpeningProduct: Bool, settings: ProductsGroupSettings = .base, dimensions: Dimensions, model: Model = .emptyMock, getProduct: @escaping GetProduct) {
            
            self.productType = productType
            self.visible = visible
            self.groupButton = groupButton
            self.isCollapsed = isCollapsed
            self.isSeparator = isSeparator
            self.isUpdating = isUpdating
            self.isOpeningProduct = isOpeningProduct
            self.products.value = visible
            self.settings = settings
            self.dimensions = dimensions
            self.model = model
            self.getProduct = getProduct
        }
        
        convenience init(
            productType: ProductType,
            products: [ProductViewModel],
            settings: ProductsGroupSettings = .base,
            dimensions: Dimensions,
            model: Model
        ) {
            self.init(
                productType: productType,
                visible: [],
                groupButton: nil,
                isCollapsed: true,
                isSeparator: true,
                isUpdating: false,
                isOpeningProduct: false,
                settings: settings,
                dimensions: dimensions,
                model: model,
                getProduct: { model.product(productId: $0)?.asCard }
            )
            
            self.products.value = products
            
            bind()
        }
        
        func update(with products: [ProductViewModel]) {
            
            self.products.value = products
        }
        
        var width: CGFloat {
            
            var result: CGFloat = 0
            
            // Opening product
            if isOpeningProduct {
                
                result += dimensions.sizes.product.width
            }
            
            // products width
            result += CGFloat(visible.count) * dimensions.sizes.product.width
            result += CGFloat(max(visible.count - 1, 0)) * dimensions.spacing
            
            // group button width
            if groupButton != nil {
                
                result += dimensions.spacing
                result += dimensions.sizes.button.width
            }
            
            // separator width
            if isSeparator {
                
                result += dimensions.spacing
                result += dimensions.sizes.separator.width
            }

            return result
        }
        
        private func bind() {
            
            typealias ProductGroupButtonDidTapped = ProductGroupAction.GroupButtonDidTapped
            typealias ProductGroupCollapsed = ProductGroupAction.Group.Collapsed
            
            action
                .compactMap { $0 as? ProductGroupButtonDidTapped }
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] _ in
                    
                    self.isCollapsed.toggle()
                    
                    if self.isCollapsed {
                        
                        self.action.send(ProductGroupCollapsed())
                    }
                }
                .store(in: &bindings)
            
            let reduce: (
                [ProductViewModel],
                Bool
            ) -> (
                products: [ProductViewModel],
                groupButton: GroupButtonViewModel?
            ) = { [unowned self] products, isCollapsed in
                
                let groupButtonAction: () -> Void = { [weak self] in
                    
                    self?.action.send(ProductGroupButtonDidTapped())
                }
                let (products, groupButton) = products
                    .reduce(
                        isCollapsed: isCollapsed,
                        minVisibleCount: self.settings.minVisibleProductsAmount,
                        groupButtonAction: groupButtonAction
                    )
                
                products.reduce(isUpdating: self.isUpdating)
                
                return (products, groupButton)
            }
            
            products
                .map { [unowned self, reduce] in
                    reduce($0, self.isCollapsed)
                }
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] (products, groupButton) in
                    
                    withAnimation {
                        
                        self.visible = products
                        self.groupButton = groupButton
                    }
                }
                .store(in: &bindings)
            
            $isCollapsed
                .map { [unowned self, reduce] in
                    reduce(self.products.value, $0)
                }
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] (products, groupButton) in
                    
                    withAnimation {
                        self.visible = products
                        self.groupButton = groupButton
                    }
                }
                .store(in: &bindings)
            
            $isUpdating
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] isUpdating in
                    
                    withAnimation {
                        
                        self.visible.reduce(isUpdating: isUpdating)
                    }
                }
                .store(in: &bindings)
        }
        
        func needSeparator(for index: Int) -> Bool {
            
            if productType == .card, index + 1 < visible.count {
                let current = visible[index]
                let next = visible[index+1]
                if let currentCard = getProduct(current.id),
                   let nextCard = getProduct(next.id) {
                    
                    switch (currentCard.isAdditional, nextCard.isAdditional) {
                    case (false, true), (true, false):
                        return true
                        
                    case (true, true):
                        if currentCard.parentID != nextCard.parentID {
                            return true
                        }
                        
                    default:
                        return false
                    }
                }
            }
            return false
        }
    }
}

// MARK: - Array of ProductViewModel Helpers

extension Array where Element == ProductViewModel {
    
    func reduce(
        isCollapsed: Bool,
        minVisibleCount: Int,
        groupButtonAction: @escaping () -> Void
    ) -> (
        products: [Element],
        groupButton: ProductGroupView.ViewModel.GroupButtonViewModel?
    ) {
        
        guard count > minVisibleCount else {
            
            return (self, nil)
        }
        
        guard isCollapsed else {
            
            return (
                self,
                .init(
                    content: .icon(.ic24ChevronsLeft),
                    action: groupButtonAction
                )
            )
        }
        
        let visibleProducts = Array(prefix(minVisibleCount))
        let hiddenProductsCount = count - minVisibleCount
        
        return (
            visibleProducts,
            .init(
                content: .title("+\(hiddenProductsCount)"),
                action: groupButtonAction
            )
        )
    }
    
    func reduce(isUpdating: Bool) {
        
        forEach { $0.isUpdating = isUpdating }
    }
    
    var countsByType: [ProductType: Int] {
        
        reduce(into: [ProductType: Int]()) { dict, element in
            dict[element.productType, default: 0] += 1
        }
    }
}

//MARK: - Action

enum ProductGroupAction {
    
    struct GroupButtonDidTapped: Action {}
    
    enum Group {
    
        struct Expanded: Action {}
        
        struct Collapsed: Action {}
    }
}

//MARK: - ViewModel Types

extension ProductGroupView.ViewModel {
    
    struct Dimensions {
        
        let spacing: CGFloat
        let frameHeight: CGFloat
        let bottomPadding: CGFloat
        let sizes: Sizes
        
        struct Sizes {
            
            let product: CGSize
            let productShadow: CGSize
            let new: CGSize
            let button: CGSize
            let separator: CGSize
        }
    }
}

extension ProductGroupView.ViewModel.Dimensions {
    
    static let regular: Self = .init(
        spacing: 8,
        frameHeight: 127,
        bottomPadding: 0,
        sizes: .init(
            product:       .init(width: 164, height: 104),
            productShadow: .init(width: 120, height: 104),
            new:           .init(width: 112, height: 104),
            button:        .init(width:  48, height: 104),
            separator:     .init(width:   1, height: 48)
        )
    )
    static let small: Self = .init(
        spacing: 8,
        frameHeight: 92,
        bottomPadding: 20,
        sizes: .init(
            product:       .init(width: 112, height: 72),
            productShadow: .init(width:  62, height: 64),
            new:           .init(width: 112, height: 72),
            button:        .init(width:  40, height: 72),
            separator:     .init(width:   1, height: 48)
        )
    )
}

extension ProductGroupView.ViewModel {
    
    struct GroupButtonViewModel {
        
        let content: Content
        let action: () -> Void
        
        enum Content: Equatable {
            
            case title(String)
            case icon(Image)
        }
    }
}

// MARK: - Helpers

private extension View {
    
    typealias Dimensions = ProductGroupView.ViewModel.Dimensions
    
    /// SwiftUI `frame` overload.
    ///
    /// Example:
    ///
    /// ```swift
    /// .frame(viewModel.dimensions, for: \.new)
    /// ```
    @ViewBuilder
    func frame(
        _ dimensions: Dimensions,
        for keyPath: KeyPath<Dimensions.Sizes, CGSize>
    ) -> some View {
        
        let size: CGSize = dimensions.sizes[keyPath: keyPath]
        self.frame(width: size.width, height: size.height)
    }
}

//MARK: - View

struct ProductGroupView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        HStack(alignment: .top, spacing: viewModel.dimensions.spacing) {
            
            if viewModel.isOpeningProduct {
                
                OpeningProductView(dimensions: viewModel.dimensions)
            }
            
            ForEach(0..<viewModel.visible.count, id: \.self) { index in
                
                HStack {
                    ShadowedProductView(
                        productViewModel: viewModel.visible[index],
                        dimensions: viewModel.dimensions
                    )
                    
                    if viewModel.needSeparator(for: index) { separator() }
                }
            }
            
            viewModel.groupButton.map {
                
                GroupButtonView(viewModel: $0)
                    .frame(viewModel.dimensions, for: \.button)
            }
            
            if viewModel.isSeparator { separator() }
        }
        .frame(
            height: viewModel.dimensions.frameHeight,
            alignment: .top
        )
    }
    
    private func separator() -> some View {
        
        Capsule(style: .continuous)
            .foregroundColor(.bordersDivider)
            .frame(viewModel.dimensions, for: \.separator)
            // wrap in another frame to centre align
            .frame(height: viewModel.dimensions.sizes.product.height)
    }
}

extension ProductGroupView {
    
    fileprivate struct OpeningProductView: View {
        
        let dimensions: Dimensions
        
        var body: some View {
            
            ZStack(alignment: .leading) {
                
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.cardAccount)
                    .frame(dimensions, for: \.product)
                
                VStack(alignment: .leading, spacing: 20) {
                    
                    HStack {
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.mainColorsGray)
                            .frame(width: 24, height: 24)
                            .shimmering()
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.mainColorsGray)
                            .frame(width: 44, height: 8)
                            .shimmering()
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.mainColorsGray)
                            .frame(width: 122, height: 8)
                            .shimmering()
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.mainColorsGray)
                            .frame(width: 58, height: 8)
                            .shimmering()
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    fileprivate struct ShadowedProductView: View {
        
        let productViewModel: ProductViewModel
        let dimensions: Dimensions
        
        var body: some View {
            ZStack {
                
                RoundedRectangle(cornerRadius: 12)
                    .frame(dimensions, for: \.productShadow)
                    .foregroundColor(.mainColorsBlack)
                    .opacity(0.15)
                    .offset(x: 0, y: 13)
                    .blur(radius: 8)
                
                ProductView(viewModel: productViewModel)
                    .frame(dimensions, for: \.product)
                    .accessibilityIdentifier("mainProduct")
            }
        }
    }

    struct GroupButtonView: View {
        
        let viewModel: ProductGroupView.ViewModel.GroupButtonViewModel
        
        var body: some View {
            
            ZStack {
                
                RoundedRectangle(cornerRadius: 12)
                    .foregroundColor(.bordersDivider)
                
                switch viewModel.content {
                case .title(let title):
                    Text(title)
                        .font(.textBodyMM14200())
                        .foregroundColor(.textSecondary)
                    
                case .icon(let icon):
                    icon
                        .foregroundColor(.iconBlack)
                }
                
            }.onTapGesture { viewModel.action() }
        }
    }
}

//MARK: - Preview

struct ProductGroupView_Previews: PreviewProvider {
    
    private static func preview(_ viewModel: ProductGroupView.ViewModel) -> some View {
        ProductGroupView(viewModel: viewModel)
    }

    static func previewsGroup() -> some View {
        
        Group {
            Group {
                
                preview(.previewNewAndOpening)
                    .previewDisplayName("previewNewAndOpening")
                
                preview(.sampleProductsOne)
                    .previewDisplayName("sampleProductsOne")
                
                preview(.sampleProductsOneSmall)
                    .previewDisplayName("sampleProductsOne Small")
            }
            
            ScrollView(.horizontal) {
                
                preview(.sampleProducts)
            }
            .previewDisplayName("scroll with sampleProducts")
            
            ScrollView(.horizontal) {
                
                preview(.sampleProductsSmall)
            }
            .previewDisplayName("scroll with sampleProductsSmall")
            
            preview(.sampleWant)
                .previewDisplayName("sampleWant")
            
            ScrollView(.horizontal) {
                
                preview(.sampleGroup)
            }
            .previewDisplayName("sampleGroup")
            
            preview(.sampleGroupCollapsed)
                .previewDisplayName("sampleGroupCollapsed")
            
            Group {
                ProductGroupView.GroupButtonView(viewModel: .init(content: .title("+5"), action: {}))
                    .previewDisplayName("GroupButtonView +5")
                
                ProductGroupView.GroupButtonView(viewModel: .init(content: .icon(.ic24ChevronsLeft), action: {}))
                    .previewDisplayName("GroupButtonView chevron")
            }
            .previewLayout(.fixed(width: 200, height: 100))
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

extension ProductGroupView.ViewModel {
    
    static let previewNewAndOpening = makeModel(
        groupButton: nil,
        isOpeningProduct: true,
        dimensions: .regular
    )
    
    static let sampleWant = makeModel(
        groupButton: nil,
        dimensions: .regular
    )
    
    static let sampleGroup = makeModel(
        groupButton: .init(content: .title("+5"), action: {}),
        isCollapsed: false,
        isSeparator: true,
        isUpdating: false,
        isOpeningProduct: true,
        dimensions: .regular
    )
    
    static let sampleGroupCollapsed = makeModel(
        groupButton: .init(content: .title("+5"), action: {}),
        isCollapsed: true,
        isSeparator: true,
        isUpdating: false,
        isOpeningProduct: false,
        dimensions: .regular
    )
    
    static let sampleProducts = makeWithMock(
        products: [.classic, .account, .blocked],
        dimensions: .regular
    )
    
    static let sampleProductsSmall = makeWithMock(
        products: [.classicSmall, .accountSmall, .blockedSmall],
        dimensions: .small
    )
    
    static let sampleProductsOne = makeWithMock(
        products: [.classic],
        dimensions: .regular
    )
    
    static let sampleProductsOneSmall = makeWithMock(
        products: [.classicSmall],
        dimensions: .small
    )
    
    private static func makeModel(
        productType: ProductType = .card,
        visible: [ProductViewModel] = [.classic],
        groupButton: GroupButtonViewModel? = nil,
        isCollapsed: Bool = false,
        isSeparator: Bool = false,
        isUpdating: Bool = false,
        isOpeningProduct: Bool = false,
        dimensions: Dimensions,
        getProduct: @escaping GetProduct = { _ in nil }
    ) -> ProductGroupView.ViewModel {
        
        ProductGroupView.ViewModel(
            productType: .card,
            visible: visible,
            groupButton: groupButton,
            isCollapsed: isCollapsed,
            isSeparator: isSeparator,
            isUpdating: isUpdating,
            isOpeningProduct: isOpeningProduct,
            dimensions: dimensions,
            getProduct: getProduct
        )
    }
    
    private static func makeWithMock(
        productType: ProductType = .card,
        products: [ProductViewModel] = [.classic],
        settings: ProductsGroupSettings = .base,
        dimensions: Dimensions
    ) -> ProductGroupView.ViewModel {
        
        ProductGroupView.ViewModel(
            productType: productType,
            products: products,
            settings: settings,
            dimensions: dimensions,
            model: .emptyMock
        )
    }
}
