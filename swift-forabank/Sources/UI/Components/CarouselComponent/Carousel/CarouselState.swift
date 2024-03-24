//
//  CarouselState.swift
//
//
//  Created by Disman Dmitry on 22.01.2024.
//

import SwiftUI

public struct CarouselState: Equatable {
    
    public typealias SelectorProductType = CarouselProduct.ProductType
    public typealias ProductGroups = [ProductGroup]
    public typealias ProductSeparators = [CarouselProduct.ProductType: [CarouselProduct]]
    
    var selector: ProductTypeSelector
    var productGroups: ProductGroups
    var sticker: CarouselProduct?
    var separators: ProductSeparators
    
    var selectedProductType: CarouselProduct.ProductType?
    var spoilerUnitPoints: UnitPoint = .zero
    
    var carouselDimensions: CarouselConfig.ProductDimensions
    var numberOfItemsBeforeSpoiler: Int
    
    public init(
        selector: ProductTypeSelector,
        productGroups: ProductGroups,
        sticker: CarouselProduct? = nil,
        separators: ProductSeparators = [:],
        selectedProductType: CarouselProduct.ProductType? = nil,
        carouselDimensions: CarouselConfig.ProductDimensions = .regular,
        numberOfItemsBeforeSpoiler: Int = 3
    ) {
        self.selector = selector
        self.productGroups = productGroups
        self.sticker = sticker
        self.separators = separators
        self.selectedProductType = selectedProductType
        self.carouselDimensions = carouselDimensions
        self.numberOfItemsBeforeSpoiler = numberOfItemsBeforeSpoiler
    }
    
    public struct ProductTypeSelector: Equatable {
        
        public var selected: SelectorProductType?
        public var items: [SelectorProductType]
        
        public init(
            selected: SelectorProductType? = .card,
            items: [SelectorProductType]
        ) {
            self.selected = selected
            self.items = items
        }
    }
}

public extension CarouselState {
    
    init(products: [CarouselProduct], sticker: CarouselProduct? = nil) {
        
        let productsMapper = Self.map(products: products)
        
        let selector = productsMapper.0
        let productGroups = productsMapper.1
        let separators = productsMapper.2
        
        self.init(
            selector: selector,
            productGroups: productGroups,
            sticker: sticker,
            separators: separators
        )
    }
    
    static private func map(
        products: [CarouselProduct]
    ) -> (ProductTypeSelector, ProductGroups, ProductSeparators)  {
        
        let productTypes = products
            .map { $0.type }
            .uniqueValues
            .sorted(by: { $0.order < $1.order })
        
        let groupedByType = Dictionary(
            grouping: products,
            by: { $0.type }
        )
                
        let productGroups = productTypes
            .compactMap { productType -> (CarouselProduct.ProductType, [CarouselProduct])? in
                                
                guard let productsArray = groupedByType[productType] else {
                    return nil
                }
                return (productType, productsArray)
            }
            .reduce(into: ProductGroups()) { productGroups, productsArray in
                
                productGroups.append(
                    
                    ProductGroup(
                        productType: productsArray.0,
                        products: productsArray.1
                    )
                )
            }
        
        let cardProducts = products.filter { $0.type == .card }
        
        let separators = zip(cardProducts, cardProducts.dropFirst())
            .enumerated()
            .map { (pairIndex, products) -> CarouselProduct? in
                
                productIdForSeparator(
                    pairIndex: pairIndex,
                    firstProduct: products.0,
                    secondProduct: products.1
                )
            }
            .compactMap { $0 }
            .reduce(into: ProductSeparators()) { resultingArray, product in
                
                resultingArray.append(
                    element: product,
                    toValueOfKey: product.type
                )
            }
        
        return (
            ProductTypeSelector(items: productTypes),
            ProductGroups(productGroups),
            separators
        )
    }
    
    private static func productIdForSeparator(
        pairIndex: Int,
        firstProduct: CarouselProduct,
        secondProduct: CarouselProduct
    ) -> CarouselProduct? {
        
        if firstProduct.cardType?.isMainOrRegular == true
            && secondProduct.cardType?.isAdditional == true {
            
            guard pairIndex > 0 else { return nil }
            
            return firstProduct
        }

        if firstProduct.cardType?.isAdditional == true
            && secondProduct.cardType?.isMainOrRegular == true {
            
            return firstProduct
        }
        
        return nil
    }
}

extension CarouselState {
    
    func productType(with offset: CGFloat) -> ProductGroup.ID? {
        
        guard offset > 0 else { return nil }
        
        var currentLength: CGFloat = 0
        
        for group in productGroups {
            
            let shouldAddSpoiler = shouldAddSpoiler(for: group)
            
            let productWidth = carouselDimensions.sizes.product.width
            let separatorWidth = carouselDimensions.sizes.separator.width
            let productSpacing = carouselDimensions.spacing
            let spoilerWidth = Int(shouldAddSpoiler ? carouselDimensions.sizes.button.width : 0)
            
            let separatorsCount = separators[group.id]?.count ?? 0
            let visibleProductsCount = group.visibleProducts(count: numberOfItemsBeforeSpoiler).count
            
            let visibleProductsWidth = visibleProductsCount * Int(productWidth)
            let separatorsWidth = separatorsCount * Int(separatorWidth)
            let productsInsets = visibleProductsCount * Int(productSpacing)
            
            currentLength += CGFloat(visibleProductsWidth + separatorsWidth + productsInsets + spoilerWidth)
            
            guard currentLength >= offset else { continue }
            
            return group.id
        }
        
        return nil
    }
}

public extension CarouselState {
    
    subscript(_ groupID: ProductGroup.ID) -> ProductGroup? {
        
        get { productGroups.first(matching: groupID) }
        
        set(newValue) {
            
            guard
                let newValue,
                let index = productGroups.firstIndex(matching: groupID)
            else { return }
            
            productGroups[index] = newValue
        }
    }
}

extension CarouselState {
    
    func shouldAddSeparator(for product: CarouselProduct) -> Bool {
        
        separators[product.type]?.contains(product) == true
    }
    
    func shouldAddGroupSeparator(for productGroup: ProductGroup) -> Bool {
        
        productGroups.last != productGroup
    }
    
    func productGroupIsCollapsed(_ productGroup: ProductGroup) -> Bool {
        
        productGroups
            .contains(where: { $0 == productGroup && $0.state == .collapsed })        
    }
    
    func shouldAddSpoiler(for productGroup: ProductGroup) -> Bool {
        
        productGroups
            .first(where: { $0 == productGroup && $0.products.count > numberOfItemsBeforeSpoiler }) != nil
    }
    
    func shouldAddSticker(for productGroup: ProductGroup) -> Bool {
        
        sticker != nil && productGroup.id == .card
    }
    
    func spoilerTitle(for productGroup: ProductGroup) -> String? {
        
        productGroups
            .first(where: { $0 == productGroup })?
            .spoilerTitle(count: numberOfItemsBeforeSpoiler)
    }
    
    func visibleProducts(for productGroup: ProductGroup) -> [CarouselProduct] {
        
        productGroups
            .first(where: { $0 == productGroup })?
            .visibleProducts(count: numberOfItemsBeforeSpoiler) ?? []
    }
}

public extension ProductGroup.State {
    
    mutating func toggle() {
        
        switch self {
        case .collapsed: self = .expanded
        case .expanded:  self = .collapsed
        }
    }
}
