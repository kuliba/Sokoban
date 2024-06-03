//
//  Model+formattedBalance.swift
//  ForaBank
//
//  Created by Igor Malyarov on 25.05.2024.
//

extension Model {
    
    func formattedBalance(
        of product: ProductData
    ) -> String? {
        
        return amountFormatted(
            amount: product.balanceValue,
            currencyCode: product.currency,
            style: .clipped
        )
    }
}
