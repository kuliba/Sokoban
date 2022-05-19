//
//  ProductViewComponent+Legacy.swift
//  ForaBank
//
//  Created by Max Gribov on 16.03.2022.
//

import Foundation
import SwiftUI

extension ProductView.ViewModel {
    
    convenience init?(data: UserAllCardsModel, action: @escaping () -> Void) {
        
        guard let cardNumber = data.accountNumber?.suffix(4),
        let name = data.customName ?? data.mainField,
        let currency = data.currency,
        let fontColor = data.fontDesignColor,
        let backgroundColor = data.background.first?.color,
        let productTypeData = data.productType,
        let productType = ProductType(rawValue: productTypeData) else {
            
            return nil
        }
        
        let balance = data.balance.currencyFormatter(symbol: currency)
      
        let productId = data.id
        let header = ProductView.ViewModel.HeaderViewModel(logo: nil, number: String(cardNumber), period: nil)
        let footer = ProductView.ViewModel.FooterViewModel(balance: balance, paymentSystem: nil)
        
        func appearance(fontColorData: String, backgroundColorData: String, backgroundImage: UIImage?) -> ProductView.ViewModel.Appearance {
            
            if let backgroundImage = backgroundImage {
                
                return ProductView.ViewModel.Appearance(textColor: Color(hex: fontColorData), background: .init(color: Color(hex: backgroundColorData), image: Image(uiImage: backgroundImage)), size: .small)
                
            } else {
                
                return ProductView.ViewModel.Appearance(textColor: Color(hex: fontColorData), background: .init(color: Color(hex: backgroundColorData), image: nil), size: .small)
            }
        }
        
        self.init(id: productId,
                  header: header,
                  name: name,
                  footer: footer,
                  statusAction: nil,
                  appearance: appearance(fontColorData: fontColor, backgroundColorData: backgroundColor, backgroundImage: data.mediumDesign?.convertSVGStringToImage()),
                  isUpdating: false,
                  productType: productType,
                  action: action)
    }
}
