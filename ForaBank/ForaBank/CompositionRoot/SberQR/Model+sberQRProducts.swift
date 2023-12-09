//
//  Model+sberQRProducts.swift
//  ForaBank
//
//  Created by Igor Malyarov on 09.12.2023.
//

import SberQR

extension Model {
    
    func sberQRProducts(
        response: GetSberQRDataResponse
    ) -> [ProductSelect.Product] {
        
        sberQRProducts(
            productTypes: response.productTypes,
            currencies: response.currencies
        )
    }
    
    func sberQRProducts(
        productTypes: [ProductType],
        currencies: [String]
    ) -> [ProductSelect.Product] {
        
        allProducts
            .filter {
                productTypes.contains($0.productType)
                && currencies.contains($0.currency)
            }
            .compactMap(\.sberQRProduct)
    }
}

extension ProductData {
    
    var sberQRProduct: ProductSelect.Product? {
        
        if let card = self as? ProductCardData {
            
            return .init(
                id: .init(card.id),
                type: .card,
                icon: "",
                title: "",
                amountFormatted: "",
                color: ""
            )
        }
        
        if let account = self as? ProductAccountData {
            
            return .init(
                id: .init(account.id),
                type: .account,
                icon: "",
                title: "",
                amountFormatted: "",
                color: ""
            )
        }
        
        return nil
    }
}
