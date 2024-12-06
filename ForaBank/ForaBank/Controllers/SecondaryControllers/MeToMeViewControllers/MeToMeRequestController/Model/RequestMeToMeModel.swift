//
//  RequestMeToMeModel.swift
//  Vortex
//
//  Created by Mikhail on 03.09.2021.
//

import UIKit
import RealmSwift

struct RequestMeToMeModel {
    var amount: Double
    var fee: Double
    var bank: String?
    var card: UserAllCardsModel?
    var RecipientID: String
    var RcvrMsgId: String
    var RefTrnId: String
    
    var userInfo: [AnyHashable : Any]?
    var model: GetMe2MeDebitConsentDecodableModel?
    
    init(userInfo: [AnyHashable : Any]) {
        self.userInfo = userInfo
        
        let amount = userInfo["amount"] as? String ?? ""
        let fee = userInfo["fee"] as? String ?? ""
        let cardId = userInfo["cardId"] as? String ?? ""
        let accountId = userInfo["accountId"] as? String ?? ""
        let bank = userInfo["BankRecipientID"] as? String ?? ""
        self.RefTrnId = userInfo["RefTrnId"] as? String ?? ""
        self.RcvrMsgId = userInfo["RcvrMsgId"] as? String ?? ""
        self.RecipientID = userInfo["RecipientID"] as? String ?? ""
        
        self.amount = Double(amount) ?? 0
        self.fee = Double(fee) ?? 0
        self.bank = bank
        self.card = findProduct(with: Int(cardId), with: Int(accountId))
        
    }
    
    init(model: GetMe2MeDebitConsentDecodableModel) {
        self.model = model
        
        self.amount = model.data?.amount ?? 0
        self.fee = model.data?.fee ?? 0
        let cardId = model.data?.cardId
        let accountId = model.data?.accountId
        let bank = model.data?.bankRecipientID ?? ""
        self.RefTrnId = model.data?.refTrnId ?? ""
        self.RcvrMsgId = model.data?.rcvrMsgId ?? ""
        self.RecipientID = model.data?.recipientID ?? ""
        
        self.bank = bank
        self.card = findProduct(with: cardId, with: accountId)
        
    }
    
    init(bank: String) {
        self.amount =  0
        self.fee =  0
        self.RefTrnId = ""
        self.RcvrMsgId =  ""
        self.RecipientID =  ""
        
        self.bank = bank
        self.card = findProduct(with: nil, with: nil)
    }
    
    func cards() ->  [UserAllCardsModel] {

        var products: [UserAllCardsModel] = []
        let types: [ProductType] = [.card, .account]
        types.forEach { type in

            products.append(contentsOf: AppDelegate.shared.model.products.value[type]?.map({ $0.userAllProducts()}) ?? [])
        }

        return products
    }
    
    private mutating func findProduct(with cardId: Int?, with accountId: Int?) -> UserAllCardsModel? {
        let cardList = cards()
        var card: UserAllCardsModel?
        cardList.forEach { product in
            if cardId != nil {
                if product.id == cardId {
                    card = product
                }
            } else {
                if product.id == accountId {
                    card = product
                }
            }
        }
        if card == nil {
            card = cardList.first
        }
        return card
    }
}
