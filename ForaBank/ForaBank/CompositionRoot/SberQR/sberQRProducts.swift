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
        .compactMap { $0.productSelectProduct(formatBalance: formatBalance, getImage: getImage) }
    }
}
