//
//  PaymentsProductSelectorViewComponent+Legacy.swift
//  ForaBank
//
//  Created by Max Gribov on 16.03.2022.
//

import Foundation

extension PaymentsProductSelectorView.ViewModel {
    
    convenience init(
        productsData: [ProductData],
        model: Model
    ) {
        self.init(categories: nil, products: [])
        
        var products = [ProductViewModel]()
        for product in productsData {
            // для маленьких карт action не нужны - нет функционал CVV/PIN
            let productViewModel = ProductViewModel(
                with: product,
                size: .small,
                style: .main,
                model: model
            )
            products.append(productViewModel)
        }
        
        let productTypesFromProducts = products.reduce(Set<ProductType>()) { partialResult, productViewModel in
            
            var result = partialResult
            result.insert(productViewModel.productType)
            return result
        }
        
        let productTypesAllowed: [ProductType] = [.card, .account, .deposit]
        let productTypesFilterred = productTypesAllowed.filter({ productTypesFromProducts.contains($0)})
        if productTypesFilterred.isEmpty == false {
            
            self.categories = .init(options: productTypesFilterred.map{ .init(id: $0.rawValue, name: $0.pluralName)}, selected: productTypesFilterred[0].rawValue, style: .productsSmall)
            bindCategories()
        }
        self.products = products
        
        bind()
        bind(products)
    }
}
