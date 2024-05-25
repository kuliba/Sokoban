//
//  sberQRProducts.swift
//  ForaBank
//
//  Created by Igor Malyarov on 09.12.2023.
//

import ProductSelectComponent
import SberQR
import SwiftUI

extension Array where Element == ProductData {
    
    func mapToSberQRProducts(
        response: GetSberQRDataResponse,
        formatBalance: @escaping (ProductData) -> String,
        getImage: @escaping (Md5hash) -> Image?
    ) -> [ProductSelect.Product] {
        
        mapToSberQRProducts(
            productTypes: response.productTypes,
            currencies: response.currencies,
            formatBalance: formatBalance,
            getImage: getImage
        )
    }
    
    func mapToSberQRProducts(
        productTypes: [ProductType],
        currencies: [String],
        formatBalance: @escaping (ProductData) -> String,
        getImage: @escaping (Md5hash) -> Image?

    ) -> [ProductSelect.Product] {
        
        self.filter {
            productTypes.contains($0.productType)
            && currencies.contains($0.currency)
        }
        .compactMap { $0.sberQRProduct(formatBalance: formatBalance, getImage: getImage) }
    }
}

extension ProductData {
    
    func sberQRProduct(
        formatBalance: @escaping (ProductData) -> String,
        getImage: @escaping (Md5hash) -> Image?
    ) -> ProductSelect.Product? {
        
        if let card = self as? ProductCardData {
            
            return .init(
                id: .init(card.id),
                type: .card,
                isAdditional: false, // TODO: add real value for Additional card
                header: "Счет списания",
                title: card.displayName,
                footer: card.displayNumber ?? "",
                amountFormatted: formatBalance(card),
                balance: .init(card.balanceValue),
                look: look(getImage: getImage)
            )
        }
        
        if let account = self as? ProductAccountData {
            
            return .init(
                id: .init(account.id),
                type: .account,
                isAdditional: false,
                header: "Счет списания",
                title: account.displayName,
                footer: account.displayNumber ?? "",
                amountFormatted: formatBalance(account),
                balance: .init(account.balanceValue),
                look: look(getImage: getImage)
            )
        }
        
        return nil
    }
    
    func look(
        getImage: @escaping (Md5hash) -> Image?
    ) -> ProductSelect.Product.Look {
        
        return .init(
            background: .image(getImage(largeDesignMd5Hash) ?? .cardPlaceholder),
            color: backgroundColor.description,
            icon: .image(getImage(smallDesignMd5hash) ?? .cardPlaceholder)
        )
    }
}
