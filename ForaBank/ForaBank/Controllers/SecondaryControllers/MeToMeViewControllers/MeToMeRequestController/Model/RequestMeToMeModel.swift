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
    var RecipientID: String?
    var RcvrMsgId: String?
    var RefTrnId: String?
    
    lazy var realm = try? Realm()
    
    init(amount: Double, bankId: String, fee: Double, cardId: Int?, accountId: Int?) {
        self.amount = amount
        self.fee = fee
        self.bank = findBank(with: bankId)
        self.card = findProduct(with: cardId, with: accountId)
    }
    
    init(userInfo: [AnyHashable : Any]) {
        
        let amount = userInfo["amount"] as? String ?? ""
        let fee = userInfo["fee"] as? String ?? ""
        let cardId = userInfo["cardId"] as? String ?? ""
        let accountId = userInfo["accountId"] as? String ?? ""
        let bank = userInfo["BankRecipientID"] as? String ?? ""
       
        self.amount = Double(amount) ?? 0
        self.fee = Double(fee) ?? 0
        self.bank = findBank(with: bank)
        self.card = findProduct(with: Int(cardId), with: Int(accountId))
        self.RefTrnId = userInfo["RefTrnId"] as? String ?? ""
        self.RcvrMsgId = userInfo["RcvrMsgId"] as? String ?? ""
        self.RecipientID = userInfo["RecipientID"] as? String ?? ""
        
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
            } else {
                if product.id == accountId {
                    card = product
                }
            }
        }
        return card
    }
    
}
