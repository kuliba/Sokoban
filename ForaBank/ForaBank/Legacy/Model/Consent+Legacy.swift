//
//  Consent+Legacy.swift
//  ForaBank
//
//  Created by Дмитрий on 26.07.2022.
//

import Foundation

extension ConsentMe2MeDebitData {
    
    func getConcentLegacy() -> GetMe2MeDebitConsentDecodableModel {
        return .init(statusCode: 0,
                     errorMessage: nil,
                     data: .init(cardId: self.cardId,
                                 accountId: self.accountId,
                                 amount: self.amount,
                                 fee: self.fee,
                                 bankRecipientID: self.bankRecipientID,
                                 recipientID: self.recipientID,
                                 rcvrMsgId: self.rcvrMsgId,
                                 refTrnId: self.refTrnId))
    }
}
