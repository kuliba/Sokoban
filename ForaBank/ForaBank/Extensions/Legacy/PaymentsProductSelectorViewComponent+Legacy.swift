//
//  PaymentsProductSelectorViewComponent+Legacy.swift
//  ForaBank
//
//  Created by Max Gribov on 16.03.2022.
//

import Foundation

extension PaymentsProductSelectorView.ViewModel {
    
    convenience init(productsData: [ProductData], model: Model) {
        
        self.init(categories: nil, products: [])

        var products = [ProductView.ViewModel]()
        for cardData in productsData {
            
            let productId = cardData.id
            
            guard let productViewModel = ProductView.ViewModel(productData: cardData, action:  { [weak self] in self?.action.send(PaymentsProductSelectorView.ViewModelAction.SelectedProduct(productId: productId))})
            else { continue }
            
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
    }
}
