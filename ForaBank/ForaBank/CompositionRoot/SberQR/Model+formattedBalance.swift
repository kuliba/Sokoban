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
        
        if let card = product as? ProductCardData {
            
            return amountFormatted(
                amount: card.balanceValue,
                currencyCode: card.currency,
                style: .clipped
            )
        }
        
        if let account = product as? ProductAccountData {
            
            return amountFormatted(
                amount: account.balanceValue,
                currencyCode: account.currency,
                style: .clipped
            )
        }
        
        return nil
    }
}
