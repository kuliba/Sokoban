//
//  PaymentsCardViewComponent+Legacy.swift
//  ForaBank
//
//  Created by Max Gribov on 16.03.2022.
//

import Foundation
import SwiftUI
import RealmSwift

extension PaymentsCardView.ViewModel {
    
    convenience init?(parameterCard: Payments.ParameterCard) {
        
        guard let realm = try? Realm(),
        let productObject = realm.objects(UserAllCardsModel.self).first,
        let cardIconImage = productObject.smallDesign?.convertSVGStringToImage(),
        let name = productObject.customName ?? productObject.mainField,
        let currency = productObject.currency,
        let cardNumber = productObject.accountNumber?.suffix(4) else {
            return nil
        }
        
        let title = "Счет списания"
        let cardIcon = Image(uiImage: cardIconImage)
        var paymentSystemIcon: Image? = nil
        if let paymentSystemImage = productObject.paymentSystemImage?.convertSVGStringToImage() {
            paymentSystemIcon = Image(uiImage: paymentSystemImage)
        }
        let amount = productObject.balance.currencyFormatter(symbol: currency)
 
        self.init(title: title, cardIcon: cardIcon, paymentSystemIcon: paymentSystemIcon, name: name, amount: amount, captionItems: [.init(title: String(cardNumber))], state: .normal, model: .emptyMock, parameterCard: parameterCard)
        
        bindLegacy()
    }
    
    func bindLegacy() {
        
        
    }
    
}
