//
//  ConsentMe2MeDebitData.swift
//  ForaBank
//
//  Created by Дмитрий on 20.01.2022.
//

import Foundation

struct ConsentMe2MeDebitData: Codable, Equatable {
    
    let accountId: Int
    let amount: Double
    let bankRecipientID: String?
    let cardId: Int
    let fee: Double
    let rcvrMsgId: String?
    let recipientID: String?
    let refTrnId: String?
}
