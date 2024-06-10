//
//  ProductData+productSelectProduct.swift
//  ForaBank
//
//  Created by Igor Malyarov on 25.05.2024.
//

import ProductSelectComponent
import SwiftUI

extension ProductData {
    
    func productSelectProduct(
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
            color: backgroundColor,
            icon: .image(getImage(smallDesignMd5hash) ?? .cardPlaceholder)
        )
    }
}
