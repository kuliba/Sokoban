//
//  sberQRProducts.swift
//  ForaBank
//
//  Created by Igor Malyarov on 09.12.2023.
//

import ProductSelectComponent
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
                isAdditional: nil, // TODO: add real value for Additional card
                header: "Счет списания",
                title: card.displayName,
                footer: card.displayNumber ?? "",
                amountFormatted: formatBalance(card),
                balance: .init(card.balanceValue),
                look: .init(
                    background: .svg(card.largeDesign.description),
                    color: card.backgroundColor.description,
                    icon: .svg(card.smallDesign.description)
                )
            )
        }
        
        if let account = self as? ProductAccountData {
            
            return .init(
                id: .init(account.id),
                type: .account,
                isAdditional: nil,
                header: "Счет списания",
                title: account.displayName,
                footer: account.displayNumber ?? "",
                amountFormatted: formatBalance(account),
                balance: .init(account.balanceValue),
                look: .init(
                    background: .svg(account.largeDesign.description),
                    color: account.backgroundColor.description,
                    icon: .svg(account.smallDesign.description)
                )
            )
        }
        
        return nil
    }
}
