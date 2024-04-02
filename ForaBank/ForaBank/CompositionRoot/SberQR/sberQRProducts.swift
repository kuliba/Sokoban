//
//  sberQRProducts.swift
//  ForaBank
//
//  Created by Igor Malyarov on 09.12.2023.
//

import ProductSelectComponent
import SberQR
import SwiftUI
import UIPrimitives

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
                isAdditional: card.isAdditional,
                header: "Счет списания",
                title: card.displayName,
                footer: card.displayNumber ?? "",
                amountFormatted: formatBalance(card),
                balance: .init(card.balanceValue),
                look: .init(
                    background: .image(getImage(card.largeDesignMd5Hash) ?? .cardPlaceholder),
                    color: card.backgroundColor.description,
                    icon: clover
                )
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
                look: .init(
                    background: .image(getImage(account.largeDesignMd5Hash) ?? .cardPlaceholder),
                    color: account.backgroundColor.description,
                    icon: .svg("")
                )
            )
        }
        
        return nil
    }
}

extension ProductData {
    
    var clover: Icon {
        
        if let cloverImage {
            return .image(cloverImage)
        }
        return .svg("")
    }
    
    var cloverImage: Image? {
        
        if let card = self as? ProductCardData {
            let isDark = (background.first?.description == "F6F6F7")
            switch card.cardType {
            case .main:
                return isDark ? .ic16MainCardGrey : .ic16MainCardWhite
            case .additionalOther, .additionalSelf, .additionalSelfAccOwn:
                return isDark ? .ic16AdditionalCardGrey : .ic16AdditionalCardWhite
            default:
                return nil
            }
        }
        return nil
    }
}
