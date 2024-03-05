//
//  CarouselState.swift
//
//
//  Created by Disman Dmitry on 22.01.2024.
//

import SwiftUI

public struct CarouselState: Equatable {
    
    public typealias SelectorProductType = Product.ID.ProductType
    public typealias ProductGroups = [ProductGroup]
    public typealias ProductSeparators = [Product.ID.ProductType: [Product.ID]]
    
    var selector: ProductTypeSelector
    var productGroups: ProductGroups
    var separators: ProductSeparators
    
    var selectedProductType: Product.ID.ProductType?
    var spoilerUnitPoints: UnitPoint = .zero
    
    public init(
        selector: ProductTypeSelector,
        productGroups: ProductGroups,
        separators: ProductSeparators = [:],
        selectedProductType: Product.ID.ProductType? = nil
    ) {
        self.selector = selector
        self.productGroups = productGroups
        self.separators = separators
        self.selectedProductType = selectedProductType
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
    
    init(products: [Product]) {
        
        let productsMapper = Self.map(products: products)
        
        let selector = productsMapper.0
        let productGroups = productsMapper.1
        let separators = productsMapper.2
        
        self.init(
            selector: selector,
            productGroups: productGroups,
            separators: separators
        )
    }
    
    static private func map(
        products: [Product]
    ) -> (ProductTypeSelector, ProductGroups, ProductSeparators)  {
        
        let productTypes = products
            .map { $0.id.type }
            .uniqueValues
            .sorted(by: { $0.order < $1.order })
        
        let groupedByType = Dictionary(
            grouping: products,
            by: { $0.id.type }
        )
                
        let productGroups = productTypes
            .compactMap { productType -> (Product.ID.ProductType, [Product])? in
                                
                guard let productsArray = groupedByType[productType] else {
                    return nil
                }
                return (productType, productsArray)
            }
            .reduce(into: ProductGroups()) { productGroups, productsArray in
                
                productGroups.append(
                    
                    ProductGroup(
                        id: productsArray.0,
                        products: productsArray.1
                    )
                )
            }
        
        let cardProducts = products.filter { $0.id.type == .card }
        
        let separators = zip(cardProducts, cardProducts.dropFirst())
            .enumerated()
            .map { (pairIndex, products) -> Product.ID? in
                
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
        firstProduct: Product,
        secondProduct: Product
    ) -> Product.ID? {
        
        if firstProduct.id.cardType?.isMainOrRegular == true
            && secondProduct.id.cardType?.isAdditional == true {
            
            guard pairIndex > 0 else { return nil }
            
            return firstProduct.id
        }

        if firstProduct.id.cardType?.isAdditional == true
            && secondProduct.id.cardType?.isMainOrRegular == true {
            
            return firstProduct.id
        }
        return nil
    }
}

extension CarouselState {
    
    func productType(with offset: CGFloat) -> ProductGroup.ID? {
        
        guard offset > 0 else { return nil }
        
        var currentLength: CGFloat = 0
        
        for group in productGroups {
            
            // TODO: - Вынести в конфигурацию
            let productWidth = 120
            let productInset = 0
            let separatorWidth = 10
            
            let visibleProductsWidth = group.visibleProducts.count * productWidth
            let separatorsWidth = (separators[group.id]?.count ?? 0) * separatorWidth
            let productsInsets = group.visibleProducts.count * productInset * 2
            
            currentLength += CGFloat(visibleProductsWidth + separatorsWidth + productsInsets)
            
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
    
    func shouldAddSeparator(for product: Product) -> Bool {
        
        separators[product.id.type]?.contains(product.id) == true
    }
    
    func shouldAddGroupSeparator(for productGroup: ProductGroup) -> Bool {
        
        productGroups.last != productGroup
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
