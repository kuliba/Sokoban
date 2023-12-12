//
//  sberQRProducts.swift
//  ForaBank
//
//  Created by Igor Malyarov on 09.12.2023.
//

import SberQR

extension Model {
    
    func sberQRProducts(
        response: GetSberQRDataResponse
    ) -> [ProductSelect.Product] {
        
        allProducts.mapToSberQRProducts(response: response)
    }
    
    func sberQRProducts(
        productTypes: [ProductType],
        currencies: [String]
    ) -> [ProductSelect.Product] {
        
        allProducts.mapToSberQRProducts(
            productTypes: productTypes,
            currencies: currencies
        )
    }
}

extension Array where Element == ProductData {
    
    func mapToSberQRProducts(
        response: GetSberQRDataResponse
    ) -> [ProductSelect.Product] {
        
        mapToSberQRProducts(
            productTypes: response.productTypes,
            currencies: response.currencies
        )
    }
    
    func mapToSberQRProducts(
        productTypes: [ProductType],
        currencies: [String]
    ) -> [ProductSelect.Product] {
        
        self.filter {
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
                title: card.displayName,
                footer: card.displayNumber ?? "",
                amountFormatted: "",
                color: card.backgroundColor.description
            )
        }
        
        if let account = self as? ProductAccountData {
            
            return .init(
                id: .init(account.id),
                type: .account,
                icon: "",
                title: account.displayName,
                footer: account.displayNumber ?? "",
                amountFormatted: "",
                color: account.backgroundColor.description
            )
        }
        
        return nil
    }
}
