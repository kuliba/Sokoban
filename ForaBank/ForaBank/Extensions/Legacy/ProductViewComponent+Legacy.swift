//
//  ProductViewComponent+Legacy.swift
//  ForaBank
//
//  Created by Max Gribov on 16.03.2022.
//

import Foundation
import SwiftUI

extension ProductView.ViewModel {
    
    convenience init?(productData: ProductData, action: @escaping () -> Void) {
        
        guard let cardNumber = productData.accountNumber?.suffix(4),
              let backgroundColor = productData.background.first?.color
        else { return nil }
        
        let name = productData.customName ?? productData.mainField
        let balance = (productData.balance ?? 0).currencyFormatter(symbol: productData.currency)
        
        let header = ProductView.ViewModel.HeaderViewModel(logo: nil, number: String(cardNumber), period: nil)
        let footer = ProductView.ViewModel.FooterViewModel(balance: balance, paymentSystem: nil)
        
        let appearance: ProductView.ViewModel.Appearance
        if let backgroundImage = productData.mediumDesign.uiImage {
                
            appearance = ProductView.ViewModel.Appearance(textColor: productData.fontDesignColor.color,
                                                          background: .init(color: backgroundColor,
                                                                            image: Image(uiImage: backgroundImage)),
                                                          size: .small)
        } else {
                
            appearance = ProductView.ViewModel.Appearance(textColor: productData.fontDesignColor.color,
                                                          background: .init(color: backgroundColor, image: nil),
                                                          size: .small)
        }
        
        self.init(id: productData.id,
                  header: header,
                  name: name,
                  footer: footer,
                  statusAction: nil,
                  appearance: appearance,
                  isUpdating: false,
                  productType: productData.productType,
                  action: action)
    }
}
