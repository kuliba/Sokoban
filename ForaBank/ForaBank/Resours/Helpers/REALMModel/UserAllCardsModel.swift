//
//  UserAllCardsModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 25.08.2021.
//

import Foundation
import RealmSwift

// MARK: - UserAllCardsModel
class UserAllCardsModel: Object {

    @objc dynamic var number: String?
    @objc dynamic var numberMasked: String?
    @objc dynamic var balance = 0.0
    @objc dynamic var currency: String?
    @objc dynamic var productType: String?
    @objc dynamic var productName: String?
    @objc dynamic var ownerID = 0
    @objc dynamic var accountNumber: String?
    @objc dynamic var allowDebit = false
    @objc dynamic var allowCredit = false
    @objc dynamic var customName: String?
    @objc dynamic var cardID = 0
    @objc dynamic var name: String?
    @objc dynamic var validThru = 0
    @objc dynamic var status: String?
    @objc dynamic var holderName: String?
    @objc dynamic var product: String?
    @objc dynamic var branch: String?
    @objc dynamic var miniStatement: String?
    @objc dynamic var mainField: String?
    @objc dynamic var additionalField: String?
    @objc dynamic var smallDesign: String?
    @objc dynamic var mediumDesign: String?
    @objc dynamic var largeDesign: String?
    @objc dynamic var paymentSystemName: String?
    @objc dynamic var paymentSystemImage: String?
    @objc dynamic var fontDesignColor: String?
    @objc dynamic var id: Int = 0
    
}

// MARK: - Save REALM
struct AddAllUserCardtList {
    
    static func add() {
        
        /// Общая информация об поставщике услуг
        var cardsArray     = [UserAllCardsModel]()
        var tempcardsArray = [UserAllCardsModel]()
        var tempCard = UserAllCardsModel()
        let param = ["isCard": "true", "isAccount": "true", "isDeposit": "false", "isLoan": "false"]
        
        NetworkManager<GetProductListDecodableModel>.addRequest(.getProductListByFilter, param, [:]) { model, error in
            
            if error != nil {
                print("DEBUG: error", error!)
            } else {
                guard let model = model else { return }
                guard let cardList = model.data else { return }
                
                cardList.forEach { card in
                    
                    let cards      = UserAllCardsModel()
                    cards.number             = card.number
                    cards.numberMasked       = card.numberMasked
                    cards.balance            = card.balance ?? 0.0
                    cards.currency           = card.currency
                    cards.productType        = card.productType
                    cards.productName        = card.productName
                    cards.ownerID            = card.ownerID ?? 0
                    cards.accountNumber      = card.accountNumber
                    cards.allowDebit         = card.allowDebit ?? false
                    cards.allowCredit        = card.allowCredit ?? false
                    cards.customName         = card.customName
                    cards.cardID             = card.cardID ?? 0
                    cards.name               = card.name
                    cards.validThru          = card.validThru ?? 0
                    cards.status             = card.status
                    cards.holderName         = card.holderName
                    cards.product            = card.product
                    cards.branch             = card.branch
                    cards.mainField          = card.mainField
                    cards.additionalField    = card.additionalField
                    cards.smallDesign        = card.smallDesign
                    cards.mediumDesign       = card.mediumDesign
                    cards.largeDesign        = card.largeDesign
                    cards.paymentSystemName  = card.paymentSystemName
                    cards.paymentSystemImage = card.paymentSystemImage
                    cards.fontDesignColor    = card.fontDesignColor
                    cards.id                 = card.id ?? 0
                    tempCard = cards
                    tempcardsArray.append(tempCard)
                }
                tempcardsArray.forEach { value in
                    cardsArray.append(value)
                }
//                tempcardsArray.removeAll()
                /// Сохраняем в REALM
                let realm = try? Realm()
                do {
                    let operators = realm?.objects(UserAllCardsModel.self)
                    realm?.beginWrite()
                    realm?.delete(operators!)
                    realm?.add(cardsArray)
                    try realm?.commitWrite()
                    print("REALM",realm?.configuration.fileURL?.absoluteString ?? "")
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
}


