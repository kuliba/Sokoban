//
//  RequestMeToMeModel.swift
//  ForaBank
//
//  Created by Mikhail on 03.09.2021.
//

import UIKit
import RealmSwift

struct RequestMeToMeModel {
    var amount: Double
    var fee: Double
    var bank: BankFullInfoList?
    var card: UserAllCardsModel?
    var RecipientID: String
    var RcvrMsgId: String
    var RefTrnId: String
    
    var userInfo: [AnyHashable : Any]?
    var model: GetMe2MeDebitConsentDecodableModel?
    
    lazy var realm = try? Realm()
    
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
        self.bank = findBank(with: bank)
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
        
        self.bank = findBank(with: bank)
        self.card = findProduct(with: cardId, with: accountId)
        
    }
    
    init(bank: String) {
//        self.model = model
        
        self.amount =  0
        self.fee =  0
//        let cardId = model.data?.cardId
//        let accountId = model.data?.accountId
//        let bank = bank
        self.RefTrnId = ""
        self.RcvrMsgId =  ""
        self.RecipientID =  ""
        
        self.bank = findBank(with: bank)
        self.card = findProduct(with: nil, with: nil)
        
    }
    
    private func findBank(with bankId: String) -> BankFullInfoList? {
        let bankList = Dict.shared.bankFullInfoList
        var bankForReturn: BankFullInfoList?
        bankList?.forEach({ bank in
            if bank.memberID == bankId {
                bankForReturn = bank
            }
        })
        return bankForReturn
    }
    
    private mutating func findProduct(with cardId: Int?, with accountId: Int?) -> UserAllCardsModel? {
        let cardList = realm?.objects(UserAllCardsModel.self)
        var card: UserAllCardsModel?
        cardList?.forEach { product in
            if cardId != nil {
                if product.id == cardId {
                    card = product
                }
            } else if accountId != nil {
                if product.id == accountId {
                    card = product
                }
            } else {
                card = cardList?.first
            }
        }
        return card
    }
    
}
