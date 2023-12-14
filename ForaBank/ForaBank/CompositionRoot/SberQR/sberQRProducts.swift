//
//  sberQRProducts.swift
//  ForaBank
//
//  Created by Igor Malyarov on 09.12.2023.
//

import SberQR

extension Array where Element == ProductData {
    
    func mapToSberQRProducts(
        response: GetSberQRDataResponse,
        formatBalance: @escaping (ProductData) -> String
    ) -> [ProductSelect.Product] {
        
        mapToSberQRProducts(
            productTypes: response.productTypes,
            currencies: response.currencies,
            formatBalance: formatBalance
        )
    }
    
    func mapToSberQRProducts(
        productTypes: [ProductType],
        currencies: [String],
        formatBalance: @escaping (ProductData) -> String
    ) -> [ProductSelect.Product] {
        
        self.filter {
                productTypes.contains($0.productType)
                && currencies.contains($0.currency)
            }
        .compactMap { $0.sberQRProduct(formatBalance: formatBalance) }
    }
}

extension ProductData {
    
    func sberQRProduct(
        formatBalance: @escaping (ProductData) -> String
    ) -> ProductSelect.Product? {
        
        if let card = self as? ProductCardData {
            
            return .init(
                id: .init(card.id),
                type: .card,
                icon: "",
                title: card.displayName,
                footer: card.displayNumber ?? "",
                amountFormatted: formatBalance(card),
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
                amountFormatted: formatBalance(account),
                color: account.backgroundColor.description
            )
        }
        
        return nil
    }
}
