//
//  CarouselState.swift
//
//
//  Created by Disman Dmitry on 22.01.2024.
//

import SwiftUI
import Foundation

public struct CarouselState<Product: CarouselProduct & Equatable>: Equatable {
    
    var selector: ProductTypeSelector
    var productGroups: ProductGroups
    var needShowSticker: Bool
    var separators: ProductSeparators
    
    var selectedProductType: ProductType?
    var spoilerUnitPoints: UnitPoint = .zero
    
    var carouselDimensions: CarouselConfig.ProductDimensions
    var numberOfItemsBeforeSpoiler: Int
    
    init(
        selector: ProductTypeSelector,
        productGroups: ProductGroups,
        needShowSticker: Bool,
        separators: ProductSeparators = [:],
        selectedProductType: ProductType? = nil,
        carouselDimensions: CarouselConfig.ProductDimensions = .regular,
        numberOfItemsBeforeSpoiler: Int = 3
    ) {
        self.selector = selector
        self.productGroups = productGroups
        self.needShowSticker = needShowSticker
        self.separators = separators
        self.selectedProductType = selectedProductType
        self.carouselDimensions = carouselDimensions
        self.numberOfItemsBeforeSpoiler = numberOfItemsBeforeSpoiler
    }
}

public extension CarouselState {
    
    init(products: [Product], needShowSticker: Bool) {
        
        let productsMapper = Self.map(products: products)
        
        let selector = productsMapper.0
        let productGroups = productsMapper.1
        let separators = productsMapper.2
        
        self.init(
            selector: selector,
            productGroups: productGroups,
            needShowSticker: needShowSticker,
            separators: separators
        )
    }
    
    static private func map(
        products: [Product]
    ) -> (ProductTypeSelector, ProductGroups, ProductSeparators)  {
        
        let productTypes = products
            .map { $0.productType }
            .uniqueValues
            .sorted(by: { $0.order < $1.order })
        
        let groupedByType = Dictionary(
            grouping: products,
            by: { $0.productType }
        )
        
        let productGroups = productTypes
            .compactMap { productType -> (ProductType, [Product])? in
                
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
        
        let cardProducts = products.filter { $0.productType == .card }
        
        let separators = zip(cardProducts, cardProducts.dropFirst())
            .enumerated()
            .map { (pairIndex, products) -> Product? in
                
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
                    toValueOfKey: product.productType
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
    ) -> Product? {
        
        if firstProduct.isAdditional == false
            && secondProduct.isAdditional == true {
            
            guard pairIndex > 0 else { return nil }
            
            return firstProduct
        }
        
        if firstProduct.isAdditional == true
            && secondProduct.isAdditional == false {
            
            return firstProduct
        }
        
        return nil
    }
}

struct ProductTypeSelector: Equatable {
    
    public var selected: ProductType?
    public var items: [ProductType]
    
    public init(
        selected: ProductType? = .card,
        items: [ProductType]
    ) {
        self.selected = selected
        self.items = items
    }
}

extension CarouselState {
    
    var needShowAddNewProduct: Bool {
        if let cards = productGroups.first(where: { $0.productType == .card }), cards.products.count > 1 {
            return false
        }
        return true
    }
}

extension CarouselState {
    
    func productType(with offset: CGFloat) -> ProductType? {
        
        guard offset > 0 else { return nil }
        
        var currentLength: CGFloat = 0
        let productWidth = carouselDimensions.sizes.product.width
        let separatorWidth = carouselDimensions.sizes.separator.width
        let productSpacing = carouselDimensions.spacing
        var newGroupId: ProductType? = nil
        
        for group in productGroups {
            
            var currentLengthGroup: CGFloat = 0
            
            let shouldAddSticker = shouldAddSticker(for: group)
            let stickerWidth = Int(shouldAddSticker ? carouselDimensions.sizes.product.width : 0)

            let shouldAddSpoiler = shouldAddSpoiler(for: group)
            
            let spoilerWidth = Int(shouldAddSpoiler ? carouselDimensions.sizes.button.width : 0)
            
            let separatorsCount = separators[group.id]?.count ?? 0
            let visibleProductsCount = group.visibleProducts(count: numberOfItemsBeforeSpoiler).count
            
            let visibleProductsWidth = visibleProductsCount * Int(productWidth)
            let separatorsWidth = separatorsCount * Int(separatorWidth)
            let productsInsets = visibleProductsCount * Int(productSpacing)
            
            currentLengthGroup = CGFloat(visibleProductsWidth + separatorsWidth + productsInsets + spoilerWidth + stickerWidth)
            
            currentLength += currentLengthGroup

            print("group.id - \(group.id) offset - \(offset) currentLengthGroup - \(currentLengthGroup) currentLength - \(currentLength) ")
            
            if (currentLength >= offset) {
                newGroupId = group.id
                break
            }

            guard currentLength >= offset else { continue }
            newGroupId = group.id
        }
        
        return newGroupId
    }
}

public extension CarouselState {
    
    subscript(_ productType: ProductType) -> Group? {
        
        get { productGroups.first(matching: productType) }
        
        set(newValue) {
            
            guard
                let newValue,
                let index = productGroups.firstIndex(matching: productType)
            else { return }
            
            productGroups[index] = newValue
        }
    }
}

extension CarouselState {
    
    func shouldAddSeparator(for product: Product) -> Bool {
        
        separators[product.productType]?.contains(product) == true
    }
    
    func shouldAddGroupSeparator(for productGroup: Group) -> Bool {
        
        productGroups.last != productGroup
    }
    
    func productGroupIsCollapsed(_ productGroup: Group) -> Bool {
        
        productGroups
            .contains(where: { $0 == productGroup && $0.state == .collapsed })
    }
    
    func shouldAddSpoiler(for productGroup: Group) -> Bool {
        
        productGroups
            .first(where: { $0 == productGroup && $0.products.count > numberOfItemsBeforeSpoiler }) != nil
    }
    
    func shouldAddSticker(for productGroup: Group) -> Bool {
        
        needShowSticker && productGroup.id == .card
    }
    
    func spoilerTitle(for productGroup: Group) -> String? {
        
        productGroups
            .first(where: { $0 == productGroup })?
            .spoilerTitle(count: numberOfItemsBeforeSpoiler)
    }
    
    func visibleProducts(for productGroup: Group) -> [Product] {
        
        productGroups
            .first(where: { $0 == productGroup })?
            .visibleProducts(count: numberOfItemsBeforeSpoiler) ?? []
    }
}

public extension CarouselState {
    
    typealias Group = ProductGroup<Product>
    typealias ProductGroups = [ProductGroup<Product>]
    typealias ProductSeparators = [ProductType: [Product]]
}

