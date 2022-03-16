//
//  PaymentsProductSelectorViewComponent+Legacy.swift
//  ForaBank
//
//  Created by Max Gribov on 16.03.2022.
//

import Foundation

extension PaymentsProductSelectorView.ViewModel {
    
    convenience init(data: [UserAllCardsModel]) {
        
        let productTypes: [ProductType] = [.card, .account, .deposit]
        self.init(categories: .init(options: productTypes.map{ .init(id: $0.rawValue, name: $0.pluralName)}, selected: productTypes[0].rawValue, style: .productsSmall), products: [])
        
        var products = [ProductView.ViewModel]()
        for cardData in data {
            
            let productId = cardData.id
            guard let productViewModel = ProductView.ViewModel(data: cardData, action: { [weak self] in self?.action.send(PaymentsProductSelectorView.ViewModelAction.SelectedProduct(productId: productId))}) else {
               continue
            }
            products.append(productViewModel)
        }
    }
}
